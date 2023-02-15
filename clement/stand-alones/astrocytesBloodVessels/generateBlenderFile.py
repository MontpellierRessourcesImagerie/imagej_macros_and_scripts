import bpy
from mathutils import Vector
import sys
import os
import json
import random


def main():

    # Getting the state from the command line arguments (JSON)
    state = json.loads(sys.argv[5].replace('#', '"'))
    mainCollection = bpy.context.scene.collection
    bpy.data.collections.remove(mainCollection.children[0])

    # = = = = Creating materials assigned to each object = = = =

    # Surface material

    surfaceMaterialName = "surfaceMaterial"
    surfaceMaterial = bpy.data.materials.new(surfaceMaterialName)
    surfaceMaterial.use_nodes = True
    nodes = surfaceMaterial.node_tree.nodes
    links = surfaceMaterial.node_tree.links

    output   = nodes['Material Output']
    diffuse  = nodes.new('ShaderNodeBsdfDiffuse')
    ramp     = nodes.new('ShaderNodeValToRGB')
    mapRange = nodes.new('ShaderNodeMapRange')
    geometry = nodes.new('ShaderNodeNewGeometry')

    mapRange.inputs[3].default_value = 0.5
    mapRange.inputs[4].default_value = 0.9

    ramp.color_ramp.interpolation = 'CONSTANT'
    ramp.color_ramp.elements[0].color = (0.007, 0.436, 1.0, 1.0)
    ramp.color_ramp.elements[1].color = (1.0, 0.022, 0.136, 1.0)
    ramp.color_ramp.elements[0].position = 0.0
    ramp.color_ramp.elements[1].position = 0.5

    mapRange.clamp = True

    links.new(geometry.outputs[6], mapRange.inputs[0])
    links.new(geometry.outputs[6], ramp.inputs[0])

    links.new(mapRange.outputs[0], diffuse.inputs[1])

    links.new(ramp.outputs[0], diffuse.inputs[0])

    links.new(diffuse.outputs[0], output.inputs[0])

    # Cage material

    cageMaterialName = "cageMaterial"
    cageMaterial = bpy.data.materials.new(cageMaterialName)
    cageMaterial.use_nodes = True
    cageMaterial.blend_method = 'BLEND'
    cageMaterial.shadow_method = 'NONE'
    nodes = cageMaterial.node_tree.nodes
    links = cageMaterial.node_tree.links

    output    = nodes['Material Output']
    wireframe = nodes.new('ShaderNodeWireframe')
    math      = nodes.new('ShaderNodeMath')
    diffuse   = nodes.new('ShaderNodeBsdfDiffuse')
    transp    = nodes.new('ShaderNodeBsdfTransparent')
    mixshader = nodes.new('ShaderNodeMixShader')

    math.operation = 'LESS_THAN'
    math.use_clamp = True
    math.inputs[1].default_value = 0.5
    wireframe.inputs[0].default_value = 0.003

    links.new(wireframe.outputs[0], math.inputs[0])

    links.new(math.outputs[0], mixshader.inputs[0])
    links.new(diffuse.outputs[0], mixshader.inputs[1])
    links.new(transp.outputs[0], mixshader.inputs[2])

    links.new(mixshader.outputs[0], output.inputs[0])

    # Background material

    bgMaterialName = "bgMaterial"
    bgMaterial = bpy.data.materials.new(bgMaterialName)
    bgMaterial.use_nodes = True
    nodes = bgMaterial.node_tree.nodes
    links = bgMaterial.node_tree.links

    output   = nodes['Material Output']
    emission = nodes.new('ShaderNodeEmission')

    emission.inputs[0].default_value = (0.002, 0.002, 0.002, 1.0)

    links.new(emission.outputs[0], output.inputs[0])

    # Importing each couple of contact surfaces into separate collections

    widest = 0

    for idx, production in enumerate(state['produced']):

        collection = bpy.data.collections.new(f"contact-{str(idx+1).zfill(2)}")
        mainCollection.children.link(collection)

        center_object = bpy.ops.import_scene.obj(
            filepath=production['center'],
            split_mode='OFF',
            axis_forward='Y',
            axis_up='Z'
        )

        center_ref = bpy.context.selected_objects[0] if center_object == {'FINISHED'} else None

        cleaned_object = bpy.ops.import_scene.obj(
            filepath=production['cleaned'],
            split_mode='OFF',
            axis_forward='Y',
            axis_up='Z'
        )

        cleaned_ref = bpy.context.selected_objects[0] if cleaned_object == {'FINISHED'} else None
        
        if center_ref is None:
            return
        
        widest = max(widest, max(center_ref.dimensions))
        center_ref.name = f"Cage-{str(idx+1).zfill(2)}"
        mainCollection.objects.unlink(center_ref)
        collection.objects.link(center_ref)
        center_ref.data.polygons.foreach_set('use_smooth',  [False] * len(center_ref.data.polygons))
        center_ref.display_type = 'WIRE'

        if center_ref.data.materials:
            center_ref.data.materials[0] = cageMaterial
        else:
            center_ref.data.materials.append(cageMaterial)
        

        if center_ref is None:
            return
        
        cleaned_ref.name = f"Surface-{str(idx+1).zfill(2)}"
        mainCollection.objects.unlink(cleaned_ref)
        collection.objects.link(cleaned_ref)
        cleaned_ref.parent = center_ref

        if cleaned_ref.data.materials:
            cleaned_ref.data.materials[0] = surfaceMaterial
        else:
            cleaned_ref.data.materials.append(surfaceMaterial)

    # Activating the face orientation coloration
    for area in bpy.context.screen.areas:
        if area.type == 'VIEW_3D':
            for space in area.spaces:
                if space.type == 'VIEW_3D':
                    # space.overlay.show_face_orientation = True
                    space.shading.type = 'MATERIAL'
                    break


    # Adding a camera
    extrasCollection = bpy.data.collections.new("Extras")
    mainCollection.children.link(extrasCollection)
    bpy.context.view_layer.layer_collection.children["Extras"].hide_viewport = True
    bpy.context.scene.render.resolution_x = 2000
    bpy.context.scene.render.resolution_y = 2000

    camera_data = bpy.data.cameras.new(name='Camera')
    camera_object = bpy.data.objects.new('Camera', camera_data)
    extrasCollection.objects.link(camera_object)

    direction = Vector((random.random(), random.random(), random.random()))
    direction.normalize()
    camera_object.location = 2 * widest * direction

    constraint = camera_object.constraints.new(type='TRACK_TO')
    tgt = None

    for obj in bpy.data.objects:
        if obj.name.startswith('Cage'):
            tgt = obj
            break

    constraint.target = tgt

    # Adding a background

    bpy.ops.mesh.primitive_ico_sphere_add(
        subdivisions=3,
        radius=4*widest
    )

    sphere = bpy.context.selected_objects[0]

    if sphere.data.materials:
        sphere.data.materials[0] = bgMaterial
    else:
        sphere.data.materials.append(bgMaterial)
    
    extrasCollection.objects.link(sphere)
    mainCollection.objects.unlink(sphere)

    # Adding light sources

    main_light_data = bpy.data.lights.new(name="main_source", type='AREA')
    main_light_data.energy = widest * 1500
    main_light_object = bpy.data.objects.new(name="main_source", object_data=main_light_data)
    extrasCollection.objects.link(main_light_object)
    main_light_object.location = 2 * widest * direction
    main_light_data.size = 8
    main_light_data.color = (1.0, 0.65, 0.55)
    
    constraint = main_light_object.constraints.new(type='TRACK_TO')
    constraint.target = tgt

    # Adding keyframes

    center_ref.rotation_euler = (0.0, 0.0, 0.0)
    center_ref.keyframe_insert(data_path="rotation_euler", frame=1)

    center_ref.rotation_euler = (0.0, 0.0, 6.265731811)
    center_ref.keyframe_insert(data_path="rotation_euler", frame=bpy.context.scene.frame_end)

    # Exporting in a .blend file, aside produced .obj files.
    baseName = os.path.basename(state['current']).split('.')[0]
    outPath = os.path.join(state['outputDirectory'], baseName) + ".blend"
    bpy.ops.wm.save_as_mainfile(filepath=outPath)


main()
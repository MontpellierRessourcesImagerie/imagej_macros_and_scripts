import os

os.system("clear")

#######################################


import bpy


def castDefaults(sourceSocket):
    if type(sourceSocket.default_value) in [float, int, bool, str]:
        return f"{sourceSocket.default_value} # {sourceSocket.name}"
    
    if type(sourceSocket.default_value) in [bpy.types.bpy_prop_array]:
        cl = sourceSocket.default_value
        if len(sourceSocket.default_value) == 3:
            return f"({cl[0]}, {cl[1]}, {cl[2]}) # {sourceSocket.name}"
        else:
            return f"({cl[0]}, {cl[1]}, {cl[2]}, {cl[3]}) # {sourceSocket.name}"
    
    return f"NOT HANDLED"


def copyDefaultValues(sourceNode, destNodeName, production):
    for input in sourceNode.inputs:
        if ('default_value' in dir(input)) and (input.default_value is not None):
            casted = castDefaults(input)
            if casted == "NOT HANDLED":
                production.append(f"# {destNodeName}.inputs['{input.name}'].default_value = {casted}")
            else:
                production.append(f"{destNodeName}.inputs['{input.name}'].default_value = {casted}")


def replicateSpecificities(sourceNode, destNodeName, production):
    if sourceNode.bl_idname == 'ShaderNodeMath':
        production.append(f"{destNodeName}.operation = '{sourceNode.operation}'")
        production.append(f"{destNodeName}.use_clamp = {sourceNode.use_clamp}")
    
    if sourceNode.bl_idname == 'ShaderNodeValToRGB':
        elements = sourceNode.color_ramp.elements
        production.append(f"{destNodeName}.color_ramp.elements.remove({destNodeName}.color_ramp.elements[0])")
        production.append(f"{destNodeName}.color_ramp.interpolation = '{sourceNode.color_ramp.interpolation}'")
        
        for idx, e in enumerate(sourceNode.color_ramp.elements):
            if idx > 0:
                production.append(f"nE = {destNodeName}.color_ramp.elements.new(position={e.position})")
            else:
                production.append(f"{destNodeName}.color_ramp.elements[0].position = {e.position}")
                production.append(f"nE = {destNodeName}.color_ramp.elements[0]")
            production.append(f"nE.color = {tuple(e.color)}")


def copyDrivers(sourceNodeTree, production):
    if sourceNodeTree.animation_data is None:
        return
    
    if sourceNodeTree.animation_data.drivers is None:
        return
    
    production.append(f"nodetree.animation_data_create()")
    
    for d in sourceNodeTree.animation_data.drivers:
        production.append(f"d = nodetree.animation_data.drivers.new(data_path='{d.data_path}')")
        production.append(f"vars = d.driver.variables")
        production.append(f"while len(vars) > 0:")
        production.append(f"    vars.remove(vars[0])")
        production.append(f"d.driver.expression = '{d.driver.expression}'")
        
        for v in d.driver.variables:
            production.append(f"v = vars.new()")
            production.append(f"v.name = '{v.name}'")
            production.append(f"v.type = '{v.type}'")
            production.append(f"v.targets[0].data_path = '{v.targets[0].data_path}'")
            production.append(f"v.targets[0].id_type = '{v.targets[0].id_type}'")
            production.append(f"v.targets[0].id = bpy.data.objects['{v.targets[0].id.name}']")


def materialToScript(targetMaterial, varName, matName):
    if not targetMaterial.use_nodes:
        return None
    
    production = []
    nodes = targetMaterial.node_tree.nodes
    links = targetMaterial.node_tree.links
    
    nodesLut = {}
    
    production.append(f"{varName} = bpy.data.materials.new('{matName}')")
    production.append(f"{varName}.blend_method = '{targetMaterial.blend_method}'")
    production.append(f"{varName}.shadow_method = '{targetMaterial.shadow_method}'")
    production.append(f"{varName}.use_backface_culling = {targetMaterial.use_backface_culling}")
    production.append(f"{varName}.show_transparent_back = {targetMaterial.show_transparent_back}")
    production.append(f"{varName}.use_nodes = True")
    production.append(f"nodetree = {varName}.node_tree")
    production.append(f"nodes = {varName}.node_tree.nodes")
    production.append(f"links = {varName}.node_tree.links")
    production.append(f"nodes.clear()")
    
    for idx in range(len(nodes)):
            
        nodesLut[nodes[idx].name] = f"node_{idx}"
        production.append(f"node_{idx} = nodes.new('{nodes[idx].bl_idname}')")
        production.append(f"node_{idx}.name = '{nodes[idx].name}'")
        
        replicateSpecificities(nodes[idx], f"node_{idx}", production)
        

        copyDefaultValues(nodes[idx], f"node_{idx}", production)
        
    
    for node in targetMaterial.node_tree.nodes:
        for idxO, out in enumerate(node.outputs):
            for idxL, link in enumerate(out.links):
                dest = link.to_socket
                inputs = link.to_node.inputs
                for idx in range(len(inputs)):
                    if dest == inputs[idx]:
                        production.append(f"links.new({nodesLut[node.name]}.outputs[{idxO}], {nodesLut[link.to_node.name]}.inputs[{idx}])")
                        break
                
                    
    
    copyDrivers(targetMaterial.node_tree, production)
    
    return production
        
    
print("\n".join(materialToScript(bpy.data.materials['cageMaterial'], "cageMaterial", "cageMaterial")))

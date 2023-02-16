import os

os.system("clear")

#######################################


import bpy


def castDefaults(sourceSocket):
    if sourceSocket.name in ['Value', 'From Min', 'From Max', 'To Min', 'To Max', 'Steps', 'Roughness']:
        return f"{sourceSocket.default_value} # {sourceSocket.name}"
    
    if sourceSocket.name in ['Color', 'Normal', 'Displacement']:
        cl = sourceSocket.default_value
        if len(sourceSocket.default_value) == 3:
            return f"({cl[0]}, {cl[1]}, {cl[2]}) # {sourceSocket.name}"
        else:
            return f"({cl[0]}, {cl[1]}, {cl[2]}, {cl[3]}) # {sourceSocket.name}"
    
    return f"{sourceSocket.name} NOT HANDLED"

def copyDefaultValues(sourceNode, destNodeName, production):
    for input in sourceNode.inputs:
        if ('default_value' in dir(input)) and (input.default_value is not None):
            production.append(f"{destNodeName}.inputs['{input.name}'].default_value = {castDefaults(input)}")


def materialToScript(targetMaterial, varName, matName):
    if not targetMaterial.use_nodes:
        return None
    
    production = []
    nodes = targetMaterial.node_tree.nodes
    links = targetMaterial.node_tree.links
    
    nodesLut = {}
    
    production.append(f"{varName} = bpy.data.materials.new('{matName}')")
    production.append(f"{varName}.use_nodes = True")
    production.append(f"nodes = {varName}.node_tree.nodes")
    production.append(f"links = {varName}.node_tree.links")
    
    for idx in range(len(nodes)):
        nodesLut[nodes[idx].name] = f"node_{idx}"
        production.append(f"node_{idx} = nodes.new('{nodes[idx].bl_idname}')")
        copyDefaultValues(nodes[idx], f"node_{idx}", production)
        
    for link in links:
        sourceNode = nodesLut[link.from_node.name]
        destNode   = nodesLut[link.to_node.name]
        srcSocket  = link.from_socket.name
        destSocket = link.to_socket.name
        production.append(f"links.new({sourceNode}.outputs['{srcSocket}'], {destNode}.inputs['{destSocket}'])")
    
    return production
        
    
print("\n".join(materialToScript(bpy.data.materials['surfaceMaterial'], "repMat", "replicate")))

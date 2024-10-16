import bpy
from mathutils import Vector
import sys
import os
import json
import random


fire_lut = [(0.0, 0.0, 0.0, 1.0), (0.0, 0.0, 0.027450980392156862, 1.0), (0.0, 0.0, 0.058823529411764705, 1.0), (0.0, 0.0, 0.08627450980392157, 1.0), (0.0, 0.0, 0.11764705882352941, 1.0), (0.0, 0.0, 0.14901960784313725, 1.0), (0.0, 0.0, 0.17647058823529413, 1.0), (0.0, 0.0, 0.20784313725490197, 1.0), (0.0, 0.0, 0.23921568627450981, 1.0), (0.0, 0.0, 0.2549019607843137, 1.0), (0.0, 0.0, 0.27058823529411763, 1.0), (0.0, 0.0, 0.2901960784313726, 1.0), (0.0, 0.0, 0.3058823529411765, 1.0), (0.0, 0.0, 0.3215686274509804, 1.0), (0.0, 0.0, 0.3411764705882353, 1.0), (0.0, 0.0, 0.3568627450980392, 1.0), (0.00392156862745098, 0.0, 0.3764705882352941, 1.0), (0.01568627450980392, 0.0, 0.39215686274509803, 1.0), (0.027450980392156862, 0.0, 0.40784313725490196, 1.0), (0.0392156862745098, 0.0, 0.4235294117647059, 1.0), (0.050980392156862744, 0.0, 0.44313725490196076, 1.0), (0.06274509803921569, 0.0, 0.4588235294117647, 1.0), (0.07450980392156863, 0.0, 0.4745098039215686, 1.0), (0.08627450980392157, 0.0, 0.49019607843137253, 1.0), (0.09803921568627451, 0.0, 0.5098039215686274, 1.0), (0.10980392156862745, 0.0, 0.5254901960784314, 1.0), (0.12156862745098039, 0.0, 0.5411764705882353, 1.0), (0.13333333333333333, 0.0, 0.5607843137254902, 1.0), (0.1450980392156863, 0.0, 0.5764705882352941, 1.0), (0.1568627450980392, 0.0, 0.592156862745098, 1.0), (0.16862745098039217, 0.0, 0.611764705882353, 1.0), (0.1803921568627451, 0.0, 0.6274509803921569, 1.0), (0.19215686274509805, 0.0, 0.6470588235294118, 1.0), (0.20392156862745098, 0.0, 0.6588235294117647, 1.0), (0.21568627450980393, 0.0, 0.6705882352941176, 1.0), (0.22745098039215686, 0.0, 0.6862745098039216, 1.0), (0.23921568627450981, 0.0, 0.6980392156862745, 1.0), (0.25098039215686274, 0.0, 0.7098039215686275, 1.0), (0.2627450980392157, 0.0, 0.7254901960784313, 1.0), (0.27450980392156865, 0.0, 0.7372549019607844, 1.0), (0.28627450980392155, 0.0, 0.7529411764705882, 1.0), (0.2980392156862745, 0.0, 0.7647058823529411, 1.0), (0.30980392156862746, 0.0, 0.7803921568627451, 1.0), (0.3215686274509804, 0.0, 0.792156862745098, 1.0), (0.3333333333333333, 0.0, 0.807843137254902, 1.0), (0.34509803921568627, 0.0, 0.8196078431372549, 1.0), (0.3568627450980392, 0.0, 0.8352941176470589, 1.0), (0.3686274509803922, 0.0, 0.8470588235294118, 1.0), (0.3843137254901961, 0.0, 0.8627450980392157, 1.0), (0.396078431372549, 0.0, 0.8627450980392157, 1.0), (0.40784313725490196, 0.0, 0.8666666666666667, 1.0), (0.4196078431372549, 0.0, 0.8705882352941177, 1.0), (0.43137254901960786, 0.0, 0.8745098039215686, 1.0), (0.44313725490196076, 0.0, 0.8784313725490196, 1.0), (0.4549019607843137, 0.0, 0.8823529411764706, 1.0), (0.4666666666666667, 0.0, 0.8862745098039215, 1.0), (0.47843137254901963, 0.0, 0.8901960784313725, 1.0), (0.49019607843137253, 0.0, 0.8784313725490196, 1.0), (0.5019607843137255, 0.0, 0.8705882352941177, 1.0), (0.5137254901960784, 0.0, 0.8627450980392157, 1.0), (0.5254901960784314, 0.0, 0.8549019607843137, 1.0), (0.5372549019607843, 0.0, 0.8470588235294118, 1.0), (0.5490196078431373, 0.0, 0.8392156862745098, 1.0), (0.5607843137254902, 0.0, 0.8313725490196079, 1.0), (0.5725490196078431, 0.0, 0.8235294117647058, 1.0), (0.5803921568627451, 0.0, 0.807843137254902, 1.0), (0.5882352941176471, 0.0, 0.792156862745098, 1.0), (0.596078431372549, 0.0, 0.7803921568627451, 1.0), (0.6039215686274509, 0.0, 0.7647058823529411, 1.0), (0.611764705882353, 0.0, 0.7490196078431373, 1.0), (0.6196078431372549, 0.0, 0.7372549019607844, 1.0), (0.6274509803921569, 0.0, 0.7215686274509804, 1.0), (0.6352941176470588, 0.0, 0.7098039215686275, 1.0), (0.6392156862745098, 0.0, 0.6941176470588235, 1.0), (0.6431372549019608, 0.0, 0.6784313725490196, 1.0), (0.6509803921568628, 0.0, 0.6627450980392157, 1.0), (0.6549019607843137, 0.0, 0.6509803921568628, 1.0), (0.6588235294117647, 0.0, 0.6352941176470588, 1.0), (0.6666666666666666, 0.0, 0.6196078431372549, 1.0), (0.6705882352941176, 0.0, 0.6039215686274509, 1.0), (0.6784313725490196, 0.0, 0.592156862745098, 1.0), (0.6823529411764706, 0.0, 0.5764705882352941, 1.0), (0.6862745098039216, 0.0, 0.5607843137254902, 1.0), (0.6941176470588235, 0.0, 0.5490196078431373, 1.0), (0.6980392156862745, 0.0, 0.5333333333333333, 1.0), (0.7019607843137254, 0.0, 0.5176470588235295, 1.0), (0.7098039215686275, 0.0, 0.5058823529411764, 1.0), (0.7137254901960784, 0.0, 0.49019607843137253, 1.0), (0.7215686274509804, 0.0, 0.47843137254901963, 1.0), (0.7254901960784313, 0.0, 0.4627450980392157, 1.0), (0.7294117647058823, 0.0, 0.4470588235294118, 1.0), (0.7372549019607844, 0.0, 0.43529411764705883, 1.0), (0.7411764705882353, 0.0, 0.4196078431372549, 1.0), (0.7450980392156863, 0.0, 0.403921568627451, 1.0), (0.7529411764705882, 0.0, 0.39215686274509803, 1.0), (0.7568627450980392, 0.0, 0.3764705882352941, 1.0), (0.7647058823529411, 0.0, 0.36470588235294116, 1.0), (0.7686274509803922, 0.00392156862745098, 0.34901960784313724, 1.0), (0.7764705882352941, 0.011764705882352941, 0.3333333333333333, 1.0), (0.7803921568627451, 0.0196078431372549, 0.3215686274509804, 1.0), (0.788235294117647, 0.027450980392156862, 0.3058823529411765, 1.0), (0.792156862745098, 0.03137254901960784, 0.2901960784313726, 1.0), (0.8, 0.0392156862745098, 0.2784313725490196, 1.0), (0.803921568627451, 0.047058823529411764, 0.2627450980392157, 1.0), (0.8117647058823529, 0.054901960784313725, 0.25098039215686274, 1.0), (0.8156862745098039, 0.06274509803921569, 0.23529411764705882, 1.0), (0.8196078431372549, 0.07450980392156863, 0.2196078431372549, 1.0), (0.8235294117647058, 0.08235294117647059, 0.20784313725490197, 1.0), (0.8313725490196079, 0.09411764705882353, 0.19215686274509805, 1.0), (0.8352941176470589, 0.10588235294117647, 0.17647058823529413, 1.0), (0.8392156862745098, 0.11372549019607843, 0.16470588235294117, 1.0), (0.8431372549019608, 0.12549019607843137, 0.14901960784313725, 1.0), (0.8509803921568627, 0.13725490196078433, 0.13725490196078433, 1.0), (0.8549019607843137, 0.1450980392156863, 0.12156862745098039, 1.0), (0.8627450980392157, 0.1568627450980392, 0.10588235294117647, 1.0), (0.8666666666666667, 0.16862745098039217, 0.09019607843137255, 1.0), (0.8745098039215686, 0.1803921568627451, 0.0784313725490196, 1.0), (0.8784313725490196, 0.18823529411764706, 0.06274509803921569, 1.0), (0.8862745098039215, 0.2, 0.047058823529411764, 1.0), (0.8901960784313725, 0.21176470588235294, 0.03137254901960784, 1.0), (0.8980392156862745, 0.2235294117647059, 0.0196078431372549, 1.0), (0.9019607843137255, 0.23137254901960785, 0.01568627450980392, 1.0), (0.9058823529411765, 0.24313725490196078, 0.011764705882352941, 1.0), (0.9137254901960784, 0.2549019607843137, 0.011764705882352941, 1.0), (0.9176470588235294, 0.26666666666666666, 0.00784313725490196, 1.0), (0.9215686274509803, 0.27450980392156865, 0.00392156862745098, 1.0), (0.9294117647058824, 0.28627450980392155, 0.00392156862745098, 1.0), (0.9333333333333333, 0.2980392156862745, 0.0, 1.0), (0.9411764705882353, 0.30980392156862746, 0.0, 1.0), (0.9450980392156862, 0.3176470588235294, 0.0, 1.0), (0.9529411764705882, 0.32941176470588235, 0.0, 1.0), (0.9568627450980393, 0.3411764705882353, 0.0, 1.0), (0.9647058823529412, 0.35294117647058826, 0.0, 1.0), (0.9686274509803922, 0.3607843137254902, 0.0, 1.0), (0.9764705882352941, 0.37254901960784315, 0.0, 1.0), (0.9803921568627451, 0.3843137254901961, 0.0, 1.0), (0.9882352941176471, 0.396078431372549, 0.0, 1.0), (0.9882352941176471, 0.403921568627451, 0.0, 1.0), (0.9882352941176471, 0.4117647058823529, 0.0, 1.0), (0.9921568627450981, 0.4196078431372549, 0.0, 1.0), (0.9921568627450981, 0.42745098039215684, 0.0, 1.0), (0.9921568627450981, 0.43529411764705883, 0.0, 1.0), (0.996078431372549, 0.44313725490196076, 0.0, 1.0), (0.996078431372549, 0.45098039215686275, 0.0, 1.0), (1.0, 0.4588235294117647, 0.0, 1.0), (1.0, 0.4666666666666667, 0.0, 1.0), (1.0, 0.4745098039215686, 0.0, 1.0), (1.0, 0.4823529411764706, 0.0, 1.0), (1.0, 0.49019607843137253, 0.0, 1.0), (1.0, 0.4980392156862745, 0.0, 1.0), (1.0, 0.5058823529411764, 0.0, 1.0), (1.0, 0.5137254901960784, 0.0, 1.0), (1.0, 0.5215686274509804, 0.0, 1.0), (1.0, 0.5254901960784314, 0.0, 1.0), (1.0, 0.5333333333333333, 0.0, 1.0), (1.0, 0.5411764705882353, 0.0, 1.0), (1.0, 0.5490196078431373, 0.0, 1.0), (1.0, 0.5529411764705883, 0.0, 1.0), (1.0, 0.5607843137254902, 0.0, 1.0), (1.0, 0.5686274509803921, 0.0, 1.0), (1.0, 0.5764705882352941, 0.0, 1.0), (1.0, 0.5803921568627451, 0.0, 1.0), (1.0, 0.5882352941176471, 0.0, 1.0), (1.0, 0.596078431372549, 0.0, 1.0), (1.0, 0.6039215686274509, 0.0, 1.0), (1.0, 0.6078431372549019, 0.0, 1.0), (1.0, 0.615686274509804, 0.0, 1.0), (1.0, 0.6235294117647059, 0.0, 1.0), (1.0, 0.6313725490196078, 0.0, 1.0), (1.0, 0.6352941176470588, 0.0, 1.0), (1.0, 0.6431372549019608, 0.0, 1.0), (1.0, 0.6509803921568628, 0.0, 1.0), (1.0, 0.6588235294117647, 0.0, 1.0), (1.0, 0.6627450980392157, 0.0, 1.0), (1.0, 0.6705882352941176, 0.0, 1.0), (1.0, 0.6784313725490196, 0.0, 1.0), (1.0, 0.6862745098039216, 0.0, 1.0), (1.0, 0.6901960784313725, 0.0, 1.0), (1.0, 0.6980392156862745, 0.0, 1.0), (1.0, 0.7058823529411765, 0.0, 1.0), (1.0, 0.7137254901960784, 0.0, 1.0), (1.0, 0.7215686274509804, 0.0, 1.0), (1.0, 0.7294117647058823, 0.0, 1.0), (1.0, 0.7372549019607844, 0.0, 1.0), (1.0, 0.7450980392156863, 0.0, 1.0), (1.0, 0.7490196078431373, 0.0, 1.0), (1.0, 0.7568627450980392, 0.0, 1.0), (1.0, 0.7647058823529411, 0.0, 1.0), (1.0, 0.7725490196078432, 0.0, 1.0), (1.0, 0.7803921568627451, 0.0, 1.0), (1.0, 0.788235294117647, 0.0, 1.0), (1.0, 0.796078431372549, 0.0, 1.0), (1.0, 0.803921568627451, 0.0, 1.0), (1.0, 0.807843137254902, 0.0, 1.0), (1.0, 0.8156862745098039, 0.0, 1.0), (1.0, 0.8235294117647058, 0.0, 1.0), (1.0, 0.8313725490196079, 0.0, 1.0), (1.0, 0.8352941176470589, 0.0, 1.0), (1.0, 0.8431372549019608, 0.0, 1.0), (1.0, 0.8509803921568627, 0.0, 1.0), (1.0, 0.8588235294117647, 0.0, 1.0), (1.0, 0.8627450980392157, 0.0, 1.0), (1.0, 0.8705882352941177, 0.0, 1.0), (1.0, 0.8784313725490196, 0.0, 1.0), (1.0, 0.8862745098039215, 0.0, 1.0), (1.0, 0.8941176470588236, 0.0, 1.0), (1.0, 0.9019607843137255, 0.0, 1.0), (1.0, 0.9098039215686274, 0.0, 1.0), (1.0, 0.9176470588235294, 0.0, 1.0), (1.0, 0.9215686274509803, 0.01568627450980392, 1.0), (1.0, 0.9294117647058824, 0.03137254901960784, 1.0), (1.0, 0.9372549019607843, 0.050980392156862744, 1.0), (1.0, 0.9450980392156862, 0.06666666666666667, 1.0), (1.0, 0.9490196078431372, 0.08235294117647059, 1.0), (1.0, 0.9568627450980393, 0.10196078431372549, 1.0), (1.0, 0.9647058823529412, 0.11764705882352941, 1.0), (1.0, 0.9725490196078431, 0.13725490196078433, 1.0), (1.0, 0.9725490196078431, 0.16470588235294117, 1.0), (1.0, 0.9764705882352941, 0.19607843137254902, 1.0), (1.0, 0.9803921568627451, 0.22745098039215686, 1.0), (1.0, 0.984313725490196, 0.25882352941176473, 1.0), (1.0, 0.9882352941176471, 0.2901960784313726, 1.0), (1.0, 0.9921568627450981, 0.3215686274509804, 1.0), (1.0, 0.996078431372549, 0.35294117647058826, 1.0), (1.0, 1.0, 0.3843137254901961, 1.0), (1.0, 1.0, 0.4117647058823529, 1.0), (1.0, 1.0, 0.44313725490196076, 1.0), (1.0, 1.0, 0.4745098039215686, 1.0), (1.0, 1.0, 0.5058823529411764, 1.0), (1.0, 1.0, 0.5333333333333333, 1.0), (1.0, 1.0, 0.5647058823529412, 1.0), (1.0, 1.0, 0.596078431372549, 1.0), (1.0, 1.0, 0.6274509803921569, 1.0), (1.0, 1.0, 0.6549019607843137, 1.0), (1.0, 1.0, 0.6862745098039216, 1.0), (1.0, 1.0, 0.7176470588235294, 1.0), (1.0, 1.0, 0.7490196078431373, 1.0), (1.0, 1.0, 0.7803921568627451, 1.0), (1.0, 1.0, 0.8117647058823529, 1.0), (1.0, 1.0, 0.8431372549019608, 1.0), (1.0, 1.0, 0.8745098039215686, 1.0), (1.0, 1.0, 0.8901960784313725, 1.0), (1.0, 1.0, 0.9058823529411765, 1.0), (1.0, 1.0, 0.9215686274509803, 1.0), (1.0, 1.0, 0.9372549019607843, 1.0), (1.0, 1.0, 0.9529411764705882, 1.0), (1.0, 1.0, 0.9686274509803922, 1.0), (1.0, 1.0, 0.984313725490196, 1.0), (1.0, 1.0, 1.0, 1.0), (1.0, 1.0, 1.0, 1.0), (1.0, 1.0, 1.0, 1.0), (1.0, 1.0, 1.0, 1.0), (1.0, 1.0, 1.0, 1.0), (1.0, 1.0, 1.0, 1.0), (1.0, 1.0, 1.0, 1.0), (1.0, 1.0, 1.0, 1.0)]

def createSurfaceMaterial():
    surfaceMaterial = bpy.data.materials.new('surfaceMaterial')
    surfaceMaterial.blend_method = 'OPAQUE'
    surfaceMaterial.shadow_method = 'OPAQUE'
    surfaceMaterial.use_backface_culling = False
    surfaceMaterial.show_transparent_back = True
    surfaceMaterial.use_nodes = True
    nodetree = surfaceMaterial.node_tree
    nodes = surfaceMaterial.node_tree.nodes
    links = surfaceMaterial.node_tree.links
    nodes.clear()
    node_0 = nodes.new('ShaderNodeMapRange')
    node_0.name = 'Map Range'
    print(node_0.inputs.keys())
    node_0.inputs['Value'].default_value = 1.0 # Value
    node_0.inputs['From Min'].default_value = 0.0 # From Min
    node_0.inputs['From Max'].default_value = 1.0 # From Max
    node_0.inputs['To Min'].default_value = 0.5 # To Min
    node_0.inputs['To Max'].default_value = 0.8999999761581421 # To Max
    #node_0.inputs['Steps'].default_value = 4.0 # Steps
    node_1 = nodes.new('ShaderNodeNewGeometry')
    node_1.name = 'Geometry'
    node_2 = nodes.new('ShaderNodeVertexColor')
    node_2.name = 'Color Attribute'
    node_3 = nodes.new('ShaderNodeBsdfDiffuse')
    node_3.name = 'Diffuse BSDF'
    node_3.inputs['Color'].default_value = (0.800000011920929, 0.800000011920929, 0.800000011920929, 1.0) # Color
    node_3.inputs['Roughness'].default_value = 0.0 # Roughness
    node_3.inputs['Normal'].default_value = (0.0, 0.0, 0.0) # Normal
    node_4 = nodes.new('ShaderNodeOutputMaterial')
    node_4.name = 'Material Output'
    node_4.inputs['Displacement'].default_value = (0.0, 0.0, 0.0) # Displacement
    node_5 = nodes.new('ShaderNodeValToRGB')
    node_5.name = 'ColorRamp'
    node_5.color_ramp.elements.remove(node_5.color_ramp.elements[0])
    node_5.color_ramp.interpolation = 'CONSTANT'
    node_5.color_ramp.elements[0].position = 0.0
    nE = node_5.color_ramp.elements[0]
    nE.color = (0.017586424946784973, 0.5088909268379211, 1.0003315210342407, 1.0)
    nE = node_5.color_ramp.elements.new(position=0.5038166046142578)
    nE.color = (1.0003662109375, 0.09939299523830414, 0.017172230407595634, 1.0)
    node_5.inputs['Fac'].default_value = 0.5 # Fac
    node_6 = nodes.new('ShaderNodeMixRGB')
    node_6.name = 'Mix'
    node_6.inputs['Fac'].default_value = 0.5 # Fac
    node_6.inputs['Color1'].default_value = (0.5, 0.5, 0.5, 1.0) # Color1
    node_6.inputs['Color2'].default_value = (0.5, 0.5, 0.5, 1.0) # Color2
    node_7 = nodes.new('ShaderNodeValue')
    node_7.name = 'Value'
    links.new(node_0.outputs[0], node_3.inputs[1])
    links.new(node_1.outputs[6], node_0.inputs[0])
    links.new(node_1.outputs[6], node_5.inputs[0])
    links.new(node_2.outputs[0], node_6.inputs[2])
    links.new(node_3.outputs[0], node_4.inputs[0])
    links.new(node_5.outputs[0], node_6.inputs[1])
    links.new(node_6.outputs[0], node_3.inputs[0])
    links.new(node_7.outputs[0], node_6.inputs[0])
    nodetree.animation_data_create()
    d = nodetree.animation_data.drivers.new(data_path='nodes["Value"].outputs[0].default_value')
    vars = d.driver.variables
    while len(vars) > 0:
        vars.remove(vars[0])
    d.driver.expression = 'var'
    v = vars.new()
    v.name = 'var'
    v.type = 'SINGLE_PROP'
    v.targets[0].data_path = 'hide_render'
    v.targets[0].id_type = 'OBJECT'
    v.targets[0].id = bpy.data.objects['Switch Material']
    return surfaceMaterial


def createBackgroundMaterial():
    bgMaterialName = "bgMaterial"
    bgMaterial = bpy.data.materials.new(bgMaterialName)
    bgMaterial.use_nodes = True
    nodes = bgMaterial.node_tree.nodes
    links = bgMaterial.node_tree.links
    output   = nodes['Material Output']
    emission = nodes.new('ShaderNodeEmission')
    emission.inputs[0].default_value = (0.002, 0.002, 0.002, 1.0)
    links.new(emission.outputs[0], output.inputs[0])
    return bgMaterial


def createCageMaterial():
    cageMaterial = bpy.data.materials.new('cageMaterial')
    cageMaterial.blend_method = 'BLEND'
    cageMaterial.shadow_method = 'NONE'
    cageMaterial.use_backface_culling = False
    cageMaterial.show_transparent_back = True
    cageMaterial.use_nodes = True
    nodetree = cageMaterial.node_tree
    nodes = cageMaterial.node_tree.nodes
    links = cageMaterial.node_tree.links
    nodes.clear()
    node_0 = nodes.new('ShaderNodeBsdfPrincipled')
    node_0.name = 'Principled BSDF'
    node_0.inputs['Base Color'].default_value = (0.800000011920929, 0.800000011920929, 0.800000011920929, 1.0) # Base Color
    #node_0.inputs['Subsurface'].default_value = 0.0 # Subsurface_01
    #node_0.inputs['Subsurface Radius'].default_value = (1.0, 0.20000000298023224, 0.10000000149011612) # Subsurface Radius_02
    #node_0.inputs['Subsurface Color'].default_value = (0.800000011920929, 0.800000011920929, 0.800000011920929, 1.0) # Subsurface Color_03
    #node_0.inputs['Subsurface IOR'].default_value = 1.399999976158142 # Subsurface IOR_04
    #node_0.inputs['Subsurface Anisotropy'].default_value = 0.0 # Subsurface Anisotropy_05
    node_0.inputs['Metallic'].default_value = 0.0 # Metallic_06
    #node_0.inputs['Specular'].default_value = 0.5 # Specular_07
    #node_0.inputs['Specular Tint'].default_value = 0.0 # Specular Tint_08
    node_0.inputs['Roughness'].default_value = 0.5 # Roughness_09
    node_0.inputs['Anisotropic'].default_value = 0.0 # Anisotropic_10
    #node_0.inputs['Anisotropic Rotation'].default_value = 0.0 # Anisotropic Rotation_11
    #node_0.inputs['Sheen'].default_value = 0.0 # Sheen_12
    #node_0.inputs['Sheen Tint'].default_value = 0.5 # Sheen Tint_13
    #node_0.inputs['Clearcoat'].default_value = 0.0 # Clearcoat_14
    #node_0.inputs['Clearcoat Roughness'].default_value = 0.029999999329447746 # Clearcoat Roughness_15
    #node_0.inputs['IOR'].default_value = 1.4500000476837158 # IOR_16
    #node_0.inputs['Transmission'].default_value = 0.0 # Transmission_17
    #node_0.inputs['Transmission Roughness'].default_value = 0.0 # Transmission Roughness_18
    node_0.inputs['Emission Color'].default_value = (0.0, 0.0, 0.0, 1.0) # Emission_19
    node_0.inputs['Emission Strength'].default_value = 1.0 # Emission Strength_20
    node_0.inputs['Alpha'].default_value = 1.0 # Alpha_21
    #node_0.inputs['Normal'].default_value = (0.0, 0.0, 0.0) # Normal_22
    #node_0.inputs['Clearcoat Normal'].default_value = (0.0, 0.0, 0.0) # Clearcoat Normal_23
    node_0.inputs['Tangent'].default_value = (0.0, 0.0, 0.0) # Tangent
    node_1 = nodes.new('ShaderNodeOutputMaterial')
    node_1.name = 'Material Output'
    node_1.inputs['Displacement'].default_value = (0.0, 0.0, 0.0) # Displacement
    node_2 = nodes.new('ShaderNodeWireframe')
    node_2.name = 'Wireframe'
    node_2.inputs['Size'].default_value = 0.003000000026077032 # Size
    node_3 = nodes.new('ShaderNodeMath')
    node_3.name = 'Math'
    node_3.operation = 'LESS_THAN'
    node_3.use_clamp = True
    node_3.inputs['Value'].default_value = 0.5 # Value
    node_3.inputs['Value'].default_value = 0.5 # Value
    node_3.inputs['Value'].default_value = 0.5 # Value
    node_4 = nodes.new('ShaderNodeEmission')
    node_4.name = 'Emission'
    node_4.inputs['Color'].default_value = (1.0, 1.0, 1.0, 1.0) # Color
    node_4.inputs['Strength'].default_value = 1.0 # Strength
    node_5 = nodes.new('ShaderNodeBsdfTransparent')
    node_5.name = 'Transparent BSDF'
    node_5.inputs['Color'].default_value = (1.0, 1.0, 1.0, 1.0) # Color
    node_6 = nodes.new('ShaderNodeMixShader')
    node_6.name = 'Mix Shader'
    node_6.inputs['Fac'].default_value = 0.5 # Fac
    links.new(node_2.outputs[0], node_3.inputs[0])
    links.new(node_3.outputs[0], node_6.inputs[0])
    links.new(node_4.outputs[0], node_6.inputs[1])
    links.new(node_5.outputs[0], node_6.inputs[2])
    links.new(node_6.outputs[0], node_1.inputs[0])
    return cageMaterial


def importObjects(state, mainCollection):
    widest = 0

    if len(state['produced']) == 0:
        print("Nothing produced. Abort.")
        return None

    objects = {
        'cages': [],
        'surfaces': [],
        'widest': 0.0
    }

    for idx, production in enumerate(state['produced']):

        # New collection for each connex component
        collection = bpy.data.collections.new(f"contact-{str(idx+1).zfill(2)}")
        mainCollection.children.link(collection)

        # Importing the cage object (the before)
        center_object = bpy.ops.wm.obj_import(
            filepath=production['center'],
            use_split_objects=False,
            forward_axis='Y',
            up_axis='Z'
        )

        center_ref = bpy.context.selected_objects[0] if center_object == {'FINISHED'} else None

        # Importing the cleaned object (the surface built)
        cleaned_object = bpy.ops.wm.obj_import(
            filepath=production['cleaned'],
            use_split_objects=False,
            forward_axis='Y',
            up_axis='Z'
        )

        cleaned_ref = bpy.context.selected_objects[0] if cleaned_object == {'FINISHED'} else None
        
        # If one is missing we can abort.
        if (center_ref is None) or (cleaned_ref is None):
            print("One of the object is None. Abort.")
            return None

        objects['cages'].append(center_ref)
        objects['surfaces'].append(cleaned_ref)
        
        # Widest dimension extracted to place a camera and some lights.
        widest = max(widest, max(center_ref.dimensions))

        # Visual appearance of the cage object
        center_ref.name = f"Cage-{str(idx+1).zfill(2)}"
        mainCollection.objects.unlink(center_ref)
        collection.objects.link(center_ref)
        center_ref.data.polygons.foreach_set('use_smooth',  [False] * len(center_ref.data.polygons))
        center_ref.display_type = 'WIRE'
        
        # Visual appearance of the surface object
        cleaned_ref.name = f"Surface-{str(idx+1).zfill(2)}"
        mainCollection.objects.unlink(cleaned_ref)
        collection.objects.link(cleaned_ref)
        cleaned_ref.parent = center_ref
        
        # Assigning color depending geodesic distance from border.
        f = open(production['json'], 'r')
        distancesDict = json.load(f)
        f.close()
        distances = distancesDict['geodesic']

        color_layer = cleaned_ref.data.vertex_colors.active or cleaned_ref.data.vertex_colors.new()
        maxDist = max(distances)

        for poly in cleaned_ref.data.polygons:
            for loop_index in range(poly.loop_start, poly.loop_start + poly.loop_total):
                vertexIdx = cleaned_ref.data.loops[loop_index].vertex_index
                nDist = int(255.0 * (float(distances[vertexIdx]) / maxDist))
                newColor = fire_lut[nDist]
                color_layer.data[loop_index].color = newColor

    objects['widest'] = widest

    return objects


def buildExtras(mainCollection, objects):
    # Adding a collection to contain all the extras and hide them from the user.
    extrasCollection = bpy.data.collections.new("Extras")
    mainCollection.children.link(extrasCollection)
    bpy.context.view_layer.layer_collection.children["Extras"].hide_viewport = True
    bpy.context.scene.render.resolution_x = 2000
    bpy.context.scene.render.resolution_y = 2000

    # Adding a camera
    camera_data = bpy.data.cameras.new(name='Camera')
    camera_object = bpy.data.objects.new('Camera', camera_data)
    extrasCollection.objects.link(camera_object)

    direction = Vector((random.random(), random.random(), random.random()))
    direction.normalize()
    camera_object.location = 2 * objects['widest'] * direction

    constraint = camera_object.constraints.new(type='TRACK_TO')
    tgt = objects['cages'][0]
    constraint.target = tgt

    # Adding a background
    bpy.ops.mesh.primitive_ico_sphere_add(
        subdivisions=3,
        radius=4*objects['widest']
    )

    sphere = bpy.context.selected_objects[0]
    objects['backdrop'] = sphere
    extrasCollection.objects.link(sphere)
    mainCollection.objects.unlink(sphere)

    # Adding light sources
    main_light_data = bpy.data.lights.new(name="main_source", type='AREA')
    main_light_data.energy = objects['widest'] * 1500
    main_light_object = bpy.data.objects.new(name="main_source", object_data=main_light_data)
    extrasCollection.objects.link(main_light_object)
    main_light_object.location = 2 * objects['widest'] * direction
    main_light_data.size = 8
    main_light_data.color = (1.0, 0.65, 0.55)
    
    constraint = main_light_object.constraints.new(type='COPY_LOCATION')
    constraint.target = camera_object

    constraint = main_light_object.constraints.new(type='TRACK_TO')
    constraint.target = tgt

    # Adding keyframes
    for center_ref in objects['cages']:
        center_ref.rotation_euler = (0.0, 0.0, 0.0)
        center_ref.keyframe_insert(data_path="rotation_euler", frame=1)

        center_ref.rotation_euler = (0.0, 0.0, 6.265731811)
        center_ref.keyframe_insert(data_path="rotation_euler", frame=bpy.context.scene.frame_end)
    
    # Adding a controler for the materials
    bpy.ops.curve.primitive_bezier_curve_add()
    controler = bpy.context.selected_objects[0]
    mainCollection.objects.unlink(controler)
    extrasCollection.objects.link(controler)
    controler.name = "Switch Material"


def assignMaterials(objects):
    surfaceMaterial    = createSurfaceMaterial()
    backgroundMaterial = createBackgroundMaterial()
    cageMaterial       = createCageMaterial()

    for surface in objects['surfaces']:
        if surface.data.materials:
            surface.data.materials[0] = surfaceMaterial
        else:
            surface.data.materials.append(surfaceMaterial)

    for cage in objects['cages']:
        if cage.data.materials:
            cage.data.materials[0] = cageMaterial
        else:
            cage.data.materials.append(cageMaterial)
    
    bg = objects['backdrop']
    if bg.data.materials:
        bg.data.materials[0] = backgroundMaterial
    else:
        bg.data.materials.append(backgroundMaterial)


def main():

    # = = = = Getting the state from the command line arguments (JSON) = = = = 
    state = json.loads(sys.argv[5].replace('#', '"'))
    mainCollection = bpy.context.scene.collection
    bpy.data.collections.remove(mainCollection.children[0])
    
    # Importing objects (cage and surface)
    objects = importObjects(state, mainCollection)
    if objects is None:
        return

    # Adding a camera, lights and a background
    buildExtras(mainCollection, objects)

    # Activating the texture preview mode
    for area in bpy.context.screen.areas:
        if area.type == 'VIEW_3D':
            for space in area.spaces:
                if space.type == 'VIEW_3D':
                    space.shading.type = 'MATERIAL'

    # Giving textures to objects
    assignMaterials(objects)

    # Exporting in a .blend file, aside produced .obj files.
    baseName = os.path.basename(state['current']).split('.')[0]
    outPath = os.path.join(state['outputDirectory'], baseName) + ".blend"
    bpy.ops.wm.save_as_mainfile(filepath=outPath)


main()
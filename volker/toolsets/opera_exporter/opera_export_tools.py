import xml.etree.ElementTree as ET
from ij import IJ
import os
import re
import sys
import shutil
import argparse
from itertools import islice
from datetime import datetime
from ij.macro import Interpreter
from ij.plugin import ImagesToStack, ZProjector, RGBStackMerge, ImageCalculator
from ij.process import ImageConverter
import unittest
DEBUG = False

_Z_STACK_FOLDER = "/stack/"
_PROJECTION_FOLDER = "/projection/"
_Z_STACK_MOSAIC_FOLDER = "/stackMosaic/"
_PROJECTION_MOSAIC_FOLDER = "/projectionMosaic/"
_PROJECTION_MOSAIC_RGB_FOLDER = "/projectionMosaicRGB/"
_PROJECTION_MOSAIC_CHANNEL_FOLDER = "/projectionMosaicChannel/"
_WORK_FOLDER = "/work/"
_OUT_FOLDER = "/out/"
_FLATFIELD_FOLDER = "/flatfield/"

def main(args):
    if DEBUG:
        print("Entering main");
    exporter = OperaExporter(args)
    exporter.launch()

def getArgumentParser():
    parser = argparse.ArgumentParser(description='Create a mosaic from the opera images using the index file and fiji-stitching.')
    parser.add_argument("--wells", "-w", default='all', help='either "all" or a string of the form "01010102" defining the wells to be exported')
    parser.add_argument("--slice", "-s", default=0, type=int, help='the slice used to calculate the stitching, 0 for the middle slice')
    parser.add_argument("--channel", "-c", default=1, type=int, help='the channel used to calculate the stitching')

    parser.add_argument("--stitchOnMIP", default=False, action='store_true', help='use the z-projection to calculate the stitching')

    parser.add_argument("--zStackFields",default=False,action='store_true',help='export the z-stacks of fields')
    parser.add_argument("--zStackFieldsComposite",default=False,action='store_true',help='export the z-stacks of fields composite')
    parser.add_argument("--projectionFields",default=False,action='store_true',help='export the projection of fields')
    parser.add_argument("--projectionFieldsComposite",default=False,action='store_true',help='export the projection of fields composite')
    parser.add_argument("--zStackMosaic",default=False,action='store_true',help='export the z-stacks of mosaics')
    parser.add_argument("--zStackMosaicComposite",default=False,action='store_true',help='export the z-stacks of mosaics composite')
    parser.add_argument("--projectionMosaic",default=False,action='store_true',help='export the projection of mosaics')
    parser.add_argument("--projectionMosaicComposite",default=False,action='store_true',help='export the projection of mosaics composite')
    parser.add_argument("--projectionMosaicRGB",default=False,action='store_true',help='export the projection of mosaics RGB')
    parser.add_argument("--channelRGB",default="0000",help='Each character is a flag to export a channel, from left to right (1,2,3,4)')

    parser.add_argument("--computeOverlap", default=False, action='store_true',help='Compute the overlap or use approximate grid coordinates')
    parser.add_argument("--normalize", default=False, action='store_true', help='normalize the intensities of the images in a mosaic')
    parser.add_argument("--fusion-method", default="Linear_Blending", help='the fusion method, "Linear_Blending", "Average", "Median" ,"Max_Intensity", "Min_Intensity" or "random"')
    parser.add_argument("--regression-threshold", "-r", default=0.3, type=float, help='if the regression threshold between two images after the individual stitching are below that number they are assumed to be non-overlapping')
    parser.add_argument("--displacement-threshold", "-d", default=2.5, type=float, help='max/avg displacement threshold')
    parser.add_argument("--abs-displacement-threshold", "-a", default=3.5, type=float, help='removes links between images if the absolute displacement is higher than this value')
    
    parser.add_argument("--index-flatfield", default=False, action='store_true', help='background removal using the flatfield profile found in the index file')
    parser.add_argument("--pseudoflatfield", "-p", default=0, type=float, help='blurring radius for the pseudo flatfield correction (no correction if 0)')
    parser.add_argument("--rollingball", "-b", default=0, type=float, help='rolling ball radius for the background correction (no correction if 0)')
    parser.add_argument("--subtract-background-radius", "-g", default=3, type=int, help='radius for the find and subtract background operation')
    parser.add_argument("--subtract-background-offset", "-o", default=3, type=int, help='offset for the find and subtract background operation')
    parser.add_argument("--subtract-background-iterations", "-i", default=1, type=int, help='nr of iterations for the find and subtract background operation')
    parser.add_argument("--subtract-background-skip", "-k", default=0.3, type=float, help='skip limit for the find and subtract background operation')
    parser.add_argument('--colours', "-C", type=lambda s: re.split(' |,', s), default=["Blue", "Green", "Red"], help='colors of the channels')
    parser.add_argument('--min-max-display', "-M", type=coords, default=[(0, 255), (0, 255), (0, 255), (0, 255)], help='pairs of min. and max. display values per channel')
    parser.add_argument("index_file", help='path to the Index.idx.xml file')
    return parser

def coords(s):
     s = s.replace(" ", '')
     l = s.split(',')
     if not len(l)%2 == 0:
         raise Exception("Parameter --min-max-display needs two values for each channel!")
     coords = [float(x) for x in l]
     it = iter(coords)
     return list(iter(lambda: tuple(islice(it, 2)), ()))
     
def splitIntoChunksOfSize(aString, chunkLength):
    '''
        Split a string into chunks of a given length.
         
        Parameters
        ----------
        aString : str
            The string that will be splitted into chunks
        chunkLength : int
            The length of the chunks 
        Returns
        -------
        title : list
            A list of the chunks
    '''
    res=[aString[y-chunkLength:y] for y in range(chunkLength, len(aString)+chunkLength, chunkLength)]
    return res
    
def transformCoordinates(xPos, yPos):
    '''
       Change the origin from (0, 0) to (min(xPos), max(yPos)) and inverse the y axis.
       Answer the coordinates in the new system.

        Parameters
        ----------
        xPos : list
            A list of the x-values of the coordinates
        yPos : list
            A list of the y-values of the coordinates
        Returns
        -------
        title : (list, list)
            a tupel of two lists, the first list contains the transformed x-values 
            and the second list the transformed y-values
    '''
    leftmost = min(xPos)
    top = max(yPos)
    if leftmost < 0:
        xPos = [i + abs(leftmost) for i in xPos]
    else:
        xPos = [i - leftmost for i in xPos]       
    if top < 0:
          yPos = [abs(i) - abs(top) for i in yPos]
    else:
        yPos = [top - i for i in yPos]
    return xPos, yPos

class OperaExporter(object):
    '''
        Export the images from the Phenix Opera as a mosaic, by using the information 
        from the index file and refining the mosaic by stitching.
    '''
    experiment = None
    sourcePath = None
    options = None
    dims = None
    
    def __init__(self, args=None):
        if args:
            parser = getArgumentParser()
            self.options = parser.parse_args(args)
            self.configureFromOptions()

    def configureFromOptions(self):
        if not self.options:
            return
        self.experiment = PhenixHCSExperiment.fromIndexFile(self.options.index_file)
        self.experiment.setExporter(self)
        self.sourcePath = self.experiment.getPath()
        self.wellsOnPlate = self.experiment.getPlates()[0].getWells()
        self.wellsToExport = self.wellsOnPlate
        if not self.options.wells == 'all':
             wellIDs = splitIntoChunksOfSize(self.options.wells, 4)
             self.wellsToExport = [well for well in self.wellsOnPlate if well.getID() in wellIDs]
        self.dims = self.wellsToExport[0].getDimensions()
        self.zSize = self.dims[2]
        self.sliceForStitching = self.options.slice
        if self.sliceForStitching==0:
            self.sliceForStitching = max(self.zSize / 2, 1)
        self.stitchOnMIP = self.options.stitchOnMIP
        if self.stitchOnMIP:
            self.sliceForStitching = 1
        self.zStackFields = self.options.zStackFields
        self.projectionFields = self.options.projectionFields
        self.zStackMosaic = self.options.zStackMosaic
        self.projectionMosaic = self.options.projectionMosaic
        self.projectionMosaicRGB = self.options.projectionMosaicRGB
        self.channel = self.options.channel        
        self.channelRGB = self.options.channelRGB        
        
    def getWells(self):
        return self.wellsToExport

    def prepareCalculationOfStitching(self, well):
        self.names, self.newNames = well.createTileConfig(self.sliceForStitching, 0, self.channel)
        if self.stitchOnMIP:
            IJ.log("Create MIP to calculate Stitching")
            well.createMIPFromInputImages(self.dims, 
                                          self.channel,
                                          self.experiment.getWorkFolder())
        else:
            IJ.log("Copy fields to calculate Stitching");
            well.copyImages(self.sourcePath, 
                            self.experiment.getWorkFolder(), 
                            self.names, 
                            self.newNames)

    def calculateStitching(self, well):
        IJ.log("Calculate Stitching")
        well.calculateStitching()
        for newName in self.newNames:
            os.remove(self.experiment.getWorkFolder() + newName)

    def createStack(self, well):
        IJ.log("Create zStacks Fields")
        well.createStack(self.dims, 
                         self.experiment.getZStackFolder())            

    def createMIP(self, well):
        IJ.log("Create projection Fields")
        well.createMIP(self.dims, 
                       self.experiment.getProjectionsFolder())

    def applyStitching(self, well):
         if self.zStackMosaic:
            IJ.log("Applying Stitching on each Z")
            well.applyStitching(self.experiment.getZStackMosaicFolder(), 
                                self.options.zStackMosaicComposite)
            if self.projectionMosaic:
                IJ.log("Projecting Mosaic")
                well.projectMosaic(self.experiment.getZStackMosaicFolder(), 
                                   self.experiment.getProjectionMosaicFolder()) 
         else:
            if self.projectionMosaic:
                IJ.log("Applying Stitching on projection")
                well.applyStitchingProjection(self.experiment.getProjectionMosaicFolder()) 
    
    def createRGBOverlaySnapshot(self, well):
        '''
            Create an overlay of the channels of the projection of the stack
            as an RGB image, in order to be able to quickly assess the images 
            using the os-thumbnails. The colors and display settings provided
            by the user are applied.
        '''        
        IJ.log("Create channel overlay snapshot")
        if self.projectionMosaic:
            well.convertToRGB(self.experiment.getProjectionMosaicFolder(), 
                              self.experiment.getProjectionMosaicRGBFolder())
        else:
            if self.zStackMosaic:
                well.projectMosaic(self.experiment.getZStackMosaicFolder(), 
                                   self.experiment.getWorkFolder())
            else:
                well.applyStitchingProjection(self.experiment.getWorkFolder())
            well.convertToRGB(self.experiment.getWorkFolder(), 
                              self.getProjectionMosaicRGBFolder())        

    def createRGBChannelSnapshots(self, well):
        channelList = list(self.channelRGB)
        for index, channelFlag in enumerate(channelList, start = 0):
            IJ.log("Create channel snapshot for channel" + str(index + 1))
            if channelFlag == "1":
                if self.projectionMosaic:
                    well.convertToRGB(self.experiment.getProjectionMosaicFolder(), 
                                      self.experiment.getProjectionMosaicChannelFolder(),
                                      channelExport = str(index))
                else:
                    if not self.zStackMosaic:
                        well.applyStitchingProjection(self.experiment.getWorkFolder())
                    else:
                        well.projectMosaic(self.experiment.getZStackMosaicFolder(), 
                                           self.experiment.getOutFolder(), 
                                           channelExport = str(index))
                    well.convertToRGB(self.experiment.getWorkFolder(), 
                                      self.experiment.getProjectionMosaicChannelFolder(),
                                      channelExport = str(index))

    def renameOutputs(self, well):
        IJ.log("Rename output files")
        well.renameAllOutputs()

    def getOptions(self):
        return self.options
        
    def launch(self):
        for well in self.wellsToExport:
            self.prepareCalculationOfStitching(well);
            self.calculateStitching(well);
            if self.zStackFields:
                self.createStack(well)
            if self.projectionFields:
                self.createMIP(well)
            self.applyStitching(well)
            if self.projectionMosaicRGB:
                self.createRGBOverlaySnapshot(well)
            self.createRGBChannelSnapshots(well)
            self.renameOutputs(well)
             
class Plate(object):
    '''
    A plate is part of an experiment and contains a number of wells.
    '''
    def __init__(self, plateData, experiment):
        '''
        Create a plate.

        Parameters
        ----------
        plateData : string
            The string of the plate xml-element.
        experiment : PhenixHCSExperiment
            The experiment of which the plate is a part.
        '''
        self.data = plateData
        self.experiment = experiment

    def __str__(self):
        plateType = self.data[4].text
        rows = self.data[5].text
        columns = self.data[6].text
        name = self.getName()
        return "Plate (" + name + ", "+ plateType + ", " + rows + "x" + columns + ")"

    def getWells(self):
        wells = []
        for wellID in self.data[7:]:
            wells.append(self.experiment.getWell(wellID.attrib['id'], self))
        return wells

    def getName(self):
        return self.data[3].text
        
class Well(object):
    def __init__(self, anID, row, col, imageData, experiment, plate):
        self.id = anID
        self.row = row
        self.column = col
        self.imageData= imageData
        self.images = None
        self.experiment = experiment
        self.plate = plate

    def getID(self):
        return self.id

    def getRow(self):
        return self.row

    def getColumn(self):
        return self.column

    def getImageData(self):
        return self.imageData;

    def getOptions(self):
        return self.experiment.getOptions()
        
    def getImages(self):
        if not self.images:
            self.images = []
            for data in self.imageData:
                self.images.append(self.experiment.getImage(data.attrib['id']))
        return self.images;
    
    def getFields(self):
        images = self.getImages()
        fieldSet = set()
        for image in images:
            fieldSet.add(image.getField())
        fields = sorted(fieldSet, key = int)
        return fields

    def getPixelWidth(self):
        return self.getImages()[0].getPixelWidth()
        
    def getDimensions(self):
        images = self.getImages()
        slices = set()
        frames = set()
        channels = set()
        width = 0
        height = 0
        pixelWidth = self.getPixelWidth()
        xCoords = [int(round(image.getX()/pixelWidth)) for image in images]
        yCoords = [int(round(image.getY()/pixelWidth)) for image in images]
        xCoords, yCoords = transformCoordinates(xCoords, yCoords)
        for image in images:
            slices.add(image.getPlane())
            frames.add(image.getTime())
            channels.add(image.getChannel())
            if image.getWidth()>width:
                width = image.getWidth()# Define the image coordinates
            if image.getHeight()>height: 
                height = image.getHeight()
        res = (max(xCoords)+width, max(yCoords)+height, len(slices), len(frames), len(channels))
        return res

    def createTileConfig(self, zPosition, timePoint, channel):
        if DEBUG:
            print("Entering createTileConfig");
        tileConfPath = self.experiment.getWorkFolder() + "/TileConfiguration.txt"
        allImages = self.getImages()
        images = [image for image in allImages if image.getPlane()==zPosition and image.getChannel()==channel and image.getTime()==timePoint]
        xCoords = [int(round(image.getX()/float(image.getPixelWidth()))) for image in images]
        yCoords = [int(round(image.getY()/float(image.getPixelHeight()))) for image in images]
        names = [image.getURL() for image in images]
        newNames = [str(names.index(name)+1).zfill(2)+".tif" for name in names]
        xCoords, yCoords = transformCoordinates(xCoords, yCoords)
        with open(tileConfPath, 'w') as f:
            f.write("# Define the number of dimensions we are working on\n")
            f.write("dim = 2\n")
            f.write("\n")
            f.write("# Define the image coordinates\n")
            for name, x, y in zip(newNames, xCoords, yCoords):
                f.write(name+";"+" ; (" + str(x) + "," + str(y)+")"+"\n")
        return names, newNames;


    def copyImages(self,srcPath, path, names, newNames):
        for name, newName in zip(names, newNames):
            shutil.copy(srcPath+"/"+name, path+"/"+newName)

    def getStitchingOptions(self):
        computeString = ""
        if self.getOptions().computeOverlap:
            computeString = "compute_overlap "
        fusionMethod = self.getOptions().fusion_method
        if "Max_" in fusionMethod:
            fusionMethod = fusionMethod.replace("Max_", "Max. ")
        if "Min_" in fusionMethod:
            fusionMethod = fusionMethod.replace("Min_", "Min. ")
        if "Linear_" in fusionMethod:
            fusionMethod = fusionMethod.replace("_", " ");    
        if "random" in fusionMethod:
            fusionMethod = "Intensity of random input tile"
        options = "type=[Positions from file] " + \
                     "order=[Defined by TileConfiguration] " + \
                     "tile_overlap=10 " + \
                     "directory=["+self.experiment.getWorkFolder()+"] " + \
                     "layout_file=TileConfiguration.txt " + \
                     "fusion_method=["+fusionMethod+"] " + \
                     "regression_threshold=" + str(self.getOptions().regression_threshold) + " " +\
                     "max/avg_displacement_threshold=" + str(self.getOptions().displacement_threshold) + " "+\
                     "absolute_displacement_threshold=" + str(self.getOptions().abs_displacement_threshold) + " "+\
                     computeString + \
                     "subpixel_accuracy " + \
                     "computation_parameters=[Save computation time (but use more RAM)] " + \
                     "image_output=[Write to disk] " \
                     "output_directory=["+self.experiment.getOutFolder()+"] "
        return options
        
    def calculateStitching(self):
        '''
        Create an initial TileConfiguration from the meta-data in the work-folder 
        and use it for the stitching. Replace the TileConfiguration by the one
        created by the stitching.
        '''       
        if DEBUG:
            print("ENTERING calculateStitching")
        now = datetime.now().time()
        print(now)
        IJ.run("Grid/Collection stitching", self.getStitchingOptions())
        now = datetime.now().time()
        print(now)
        if self.getOptions().computeOverlap:
            print("Writing new Tile Configuration")
            os.remove(self.experiment.getWorkFolder()+"TileConfiguration.txt")
            os.rename(self.experiment.getWorkFolder()+"TileConfiguration.registered.txt", self.experiment.getWorkFolder()+"TileConfiguration.txt")
        os.remove(self.experiment.getOutFolder()+"img_t1_z1_c1")
        if DEBUG:
            print("LEAVING calculateStitching")
        
    def executeStitching(self, channel=1, newNames=None):
        if DEBUG:
            print("ENTERING executeStitching")
            print(newNames)
        path = self.experiment.getWorkFolder()
        if newNames==None:
            nbFiles = len(os.listdir(path))
            newNames = [str(i + 1).zfill(2) + ".tif" for i in range(nbFiles - 1)]
        if self.getOptions().index_flatfield:
            self.doIndexFlatFieldCorrection(newNames, channel)
        if self.getOptions().pseudoflatfield>0:
            self.doPseudoFlatFieldCorrection(newNames)
        if self.getOptions().normalize:
            self.doNormalize(newNames)
        if self.getOptions().rollingball>0:
            self.doBackgroundCorrection(newNames)
        if self.getOptions().subtract_background_radius>0:
            self.doSubtractBackground(newNames)
        self.runGridCollectionStitching()
        if DEBUG:
            print("LEAVING executeStitching")
    
    def applyStitching(self, outputPath, exportComposite=False):
        if DEBUG:
            print("ENTERING applyStitching")
        dims = self.getDimensions()
        slices = dims[2]
        timePoints = dims[3]
        channels = dims[4]
        rgbStackMerge = RGBStackMerge()
        for t in range(0, timePoints):
            channelImps = []
            for c in range(1, channels+1):
                imps = []
                for z in range(1, slices+1):
                    images = self.getImagesForZPosTimeAndChannel(z, t, c)
                    names, newNames = self.copyImagesToWorkFolder(images)
                    IJ.open(self.experiment.getWorkFolder()+newNames[0])
                    imp = IJ.getImage()
                    calibration = imp.getCalibration()
                    imp.close()
                    self.executeStitching(c, newNames)
                    imp = IJ.getImage()
                    imps.append(imp)
                    title = images[0].getURLWithoutField()                  
                    for name in newNames:
                        os.remove(self.experiment.getWorkFolder()+name)                     
                imp = ImagesToStack.run(imps)
                imp.setCalibration(calibration)
                IJ.run(imp, self.getOptions().colours[c-1], "");
                name = title[:6] + title[9:]
                IJ.log("Creating Z-Stack of mosaic : "+name)
                minDisplay, maxDisplay = self.getOptions().min_max_display[c-1][0], self.getOptions().min_max_display[c-1][1] 
                imp.getProcessor().setMinAndMax(minDisplay, maxDisplay)
                channelImps.append(imp)
                IJ.save(imp, outputPath + name)
            if exportComposite:
                composite = rgbStackMerge.mergeHyperstacks(channelImps,False)
                composite.setCalibration(calibration)
                name = title[:6] +"-"+title[13:]
                IJ.log("+ Composite: "+name);
                IJ.save(composite, outputPath + name)
        if DEBUG:
            print("LEAVING applyStitching")

    def applyStitchingProjection(self, outputPath):
        if DEBUG:
            print("Entering applyStitchingProjection")
        dims = self.getDimensions()
        timePoints = dims[3]
        channels = dims[4]
        if DEBUG:
            print("outputPath: " + outputPath);
        rgbStackMerge = RGBStackMerge()
        for t in range(0, timePoints):
            channelImps = []
            for c in range(1, channels+1):    
                title = self.createMIPFromInputImages(dims, c, self.experiment.getWorkFolder())
                IJ.open(self.experiment.getWorkFolder()+"01.tif")
                imp = IJ.getImage()
                calibration = imp.getCalibration()
                imp.close()
                self.executeStitching(channel=c)
                imp = IJ.getImage()
                imp.setCalibration(calibration)
                IJ.run(imp, self.getOptions().colours[c - 1], "");
                name = title[:6] + "-" + title[13:]
                minDisplay, maxDisplay = self.getOptions().min_max_display[c - 1][0], self.getOptions().min_max_display[c - 1][1] 
                imp.getProcessor().setMinAndMax(minDisplay, maxDisplay)
                channelImps.append(imp)
                IJ.save(imp, outputPath + name)
            if self.getOptions().projectionMosaicComposite:
                composite = rgbStackMerge.mergeHyperstacks(channelImps, False)
                composite.setCalibration(calibration)
                name = title[:6] + "-" + title[16:]
                IJ.log("+ Composite: "+name)
                IJ.save(composite, outputPath + name)               
            else:
                for im in channelImps:
                    im.close();        
        if DEBUG:
            print("LEAVING applyStitchingProjection")
            
    def doSubtractBackground(self, names):
        path = self.experiment.getWorkFolder()
        for name in names:
            IJ.open(path + "/" + name)
            imp = IJ.getImage()
            self.findAndSubtractBackground(self.getOptions().subtract_background_radius, 
                                           self.getOptions().subtract_background_offset, 
                                           self.getOptions().subtract_background_iterations, 
                                           self.getOptions().subtract_background_skip)
            IJ.save(imp, path + "/" + name)
            imp.close()

    def findAndSubtractBackground(self, radius, offset, iterations, skipLimit):
        '''
        Find the background intensity value and subtract it from the current image.
         
        Search for the maximum intensity value around pixels that are below or equal
        to the minimum intensity plus an offset in the image.
         
        @param radius The radius in which the maximum around the small values is searched
        @param offset The intensity offset above the minimum intensity of the image
        @param iterations The number of times the procedure is repeated
        @param skipLimit The ratio of pixels with value zero above which the procedure is skipped
        @return Nothing
        '''
        imp = IJ.getImage()
        ip = imp.getProcessor();
        width = imp.getWidth()
        height = imp.getHeight()
        stats = imp.getStatistics()
        histogram = stats.histogram()
        ratio = histogram[0] / ((width * height) * 1.0)
        if ratio>skipLimit:
            IJ.run("HiLo");
            IJ.run("Enhance Contrast", "saturated=0.35")
            print('find and subtract background - skipped, ratio of 0-pixel is: ' + str(ratio))
            return
        for i in range(0, iterations):
            stats = imp.getStatistics()
            minPlusOffset = stats.min + offset
            currentMax = 0
            for x in range(0, width):
                for y in range(0, height):
                    intensity = imp.getProcessor().getPixel(x, y)
                    if intensity<=minPlusOffset: 
                        value = self.getMaxIntensityAround(ip, x, y, stats.mean, radius, width, height)
                        if value>currentMax:
                            currentMax = value
            result = currentMax / ((i+1)*1.0);
            print('find and subtract background - iteration ' + str(i + 1) + ', value = ' + str(result));
            IJ.run("Subtract...", "value=" + str(result))
        IJ.run("HiLo")
        IJ.run("Enhance Contrast", "saturated=0.35");

    def getMaxIntensityAround(self, ip, x, y, mean, radius, width, height):
        '''
        Find the maximal intensity value below mean in the radius around x,y
         
        @param x (x,y) are the coordinates around which the maximum is searched
        @param y (x,y) are the coordinates around which the maximum is searched
        @param mean The mean value of the image, only values below mean are considered
        @radius The radius around (x,y) in which the maximum is searched
        @width The width of the image 
        @height The height of the image
        @return The maximum value below mean around (x,y) or zero
        '''
        max = 0;
        for i in range(x-radius, x+radius+1):
            if i>=0 and i<width:
                for j in range(y-radius, y+radius+1):
                    if j>=0 and j<height:
                        value = ip.getPixel(i,j);
                        if value<mean and value>max:
                            max = value
        return max

    def doBackgroundCorrection(self, names):
        radius = self.getOptions().rollingball
        path = self.experiment.getWorkFolder()
        for name in names:
            IJ.open(path+"/"+name)
            imp = IJ.getImage()
            IJ.run(imp, "Subtract Background...", "rolling="+str(radius))
            IJ.save(imp, path+"/"+name)
            imp.close()
            
    def doNormalize(self, names):
        if DEBUG:
            print("Entering doNormalize")
        path = self.experiment.getWorkFolder()
        mins = []
        maxs = []
        means = []
        for name in names:
            IJ.open(path+"/"+name)
            imp = IJ.getImage()
            mins.append(imp.getStatistics().min)
            maxs.append(imp.getStatistics().max)
            means.append(imp.getStatistics().mean)
            imp.close()
        globalMean = max(means)
        i = 0
        for name in names:
            IJ.open(path+"/"+name)
            imp = IJ.getImage()
            IJ.run(imp, "Subtract...", "value=" + str(mins[i]));
            IJ.run(imp, "32-bit", "");
            IJ.run(imp, "Divide...", "value=" + str(maxs[i]-mins[i]));
            IJ.run(imp, "Multiply...", "value="+str(globalMean));
            ImageConverter.setDoScaling(False);
            IJ.run(imp, "16-bit", "");
            ImageConverter.setDoScaling(True);
            IJ.save(imp, path+"/"+name)
            imp.close()
            i = i + 1
        if DEBUG:
            print("Leaving doNormalize")
            
    def doIndexFlatFieldCorrection(self, names, chan):
        path = this.experiment.getWorkFolder()
        for name in names:
            IJ.open(path+"/"+name)
            imp1 = IJ.getImage()
            IJ.open(self.experiment.getFlatfieldFolder()+str(chan)+".tiff")
            imp2 = IJ.getImage()
            imp3 = ImageCalculator.run(imp1, imp2, "Subtract create");                                                                                                   
            IJ.save(imp3, path+"/"+name)
            imp1.close()
            imp2.close()
            imp3.close()

    def doPseudoFlatFieldCorrection(self, names):
        path = this.experiment.getWorkFolder()
        radius = self.experiment.getOptions().pseudoflatfield
        for name in names:
            IJ.open(path+"/"+name)
            imp = IJ.getImage()
            IJ.run("Pseudo flat field correction", "blurring="+str(radius)+" hide")
            IJ.save(imp, path+"/"+name)
            imp.close()

    def createStack(self, dims, outputPath):
        if DEBUG:
            print("ENTERING createStack")
        slices = dims[2]
        timePoints = dims[3]
        channels = dims[4]
        path = self.experiment.getPath()
        rgbStackMerge = RGBStackMerge()
        fields = self.getFields()
        for t in range(0, timePoints):
            for f in range(0, len(fields)):
                channelImps = []
                for c in range(1, channels+1):
                    imps = []
                    for z in range(1, slices+1):
                        images = self.getImagesForZPosTimeAndChannel(z, t, c)
                        image = images[f].getURL()
                        IJ.open(path + "/" + image)
                        imp = IJ.getImage()
                        imps.append(imp)
                        calibration = imp.getCalibration()
                    imp = ImagesToStack.run(imps)
                    imp.setCalibration(calibration)
                    IJ.run(imp, self.getOptions().colours[c-1], "");
                    name = image[:9] + image[12:]
                    IJ.log("Creating Z-Stack of image : "+name)
                    minDisplay, maxDisplay = self.getOptions().min_max_display[c-1][0], self.getOptions().min_max_display[c-1][1] 
                    imp.getProcessor().setMinAndMax(minDisplay, maxDisplay)
                    channelImps.append(imp)
                    IJ.save(imp, outputPath + name)
                if self.getOptions().zStackFieldsComposite:
                    composite = rgbStackMerge.mergeHyperstacks(channelImps,False)
                    composite.setCalibration(calibration)
                    name = name[:10] + name[13:]
                    IJ.log("+ Composite: "+name)
                    IJ.save(composite, outputPath + name)
    
    def createMIP(self, dims, outputPath):
        if DEBUG:
            print("ENTERING createMIP")
        timePoints = dims[3]
        channels = dims[4]

        path = self.experiment.getPath()
        rgbStackMerge = RGBStackMerge()

        fields = self.getFields()
        for t in range(0, timePoints):
            index = 0
            for f in fields:
                channelImps = []
                for c in range(1, channels+1):
                    images = self.getImagesForTimeFieldAndChannel(t, f, c)
                    imps = []    
                    title = ""
                    for image in images:
                        IJ.open(path + "/" + image.getURL())
                        title = image.getURL()
                        imp = IJ.getImage()
                        calibration = imp.getCalibration()
                        IJ.run(imp, self.getOptions().colours[c-1], "");
                        imps.append(imp)
                    if title:    
                        imp = ImagesToStack.run(imps)
                        imp.setCalibration(calibration)
                        name = title[:9] + title[12:]
                        IJ.log("Creating Projection of image : "+name)
                        projImp = ZProjector.run(imp,"max")
                        url = outputPath + name
                        minDisplay, maxDisplay = self.getOptions().min_max_display[c-1][0], self.getOptions().min_max_display[c-1][1] 
                        projImp.getProcessor().setMinAndMax(minDisplay, maxDisplay)
                        channelImps.append(projImp)
                        IJ.save(projImp, url)
                        imp.close()
                        projImp.close()
                if self.getOptions().projectionFieldsComposite:
                    composite = rgbStackMerge.mergeHyperstacks(channelImps,False)
                    composite.setCalibration(calibration)
                    name = title[:9] + title[12:13] + title[16:]
                    IJ.log("+ Composite: "+name)
                    IJ.save(composite, outputPath + name)
                index = index + 1

    def createMIPFromInputImages(self, dims, channel, outputPath):
        if DEBUG:
            print("ENTERING createMIPFromInputImages")
        timePoints = dims[3]
        path = self.experiment.getPath()
        if DEBUG:
            print("path: " + path)
        if DEBUG:
            print("outputPath: " + outputPath)            
        fields = self.getFields()
        for t in range(0, timePoints):
            index = 0
            for f in fields:
                images = self.getImagesForTimeFieldAndChannel(t, f, channel)
                imps = []    
                title = ""
                for image in images:
                    IJ.open(path + "/" + image.getURL())
                    title = image.getURL()
                    imp = IJ.getImage()
                    calibration = imp.getCalibration()
                    imps.append(imp)
                if title:    
                    imp = ImagesToStack.run(imps)
                    imp.setCalibration(calibration)
                    projImp = ZProjector.run(imp,"max")
                    url = outputPath + str(f).zfill(2)+".tif"
                    minDisplay, maxDisplay = self.getOptions().min_max_display[channel - 1][0], self.getOptions().min_max_display[channel - 1][1] 
                    projImp.getProcessor().setMinAndMax(minDisplay, maxDisplay)
                    IJ.save(projImp, url)
                    imp.close()
                    projImp.close()
                index = index + 1
        if DEBUG:
            print("LEAVING createMIPFromInputImages");
        return title

    def getImagesInFolder(self, inputPath, getFullPath = False, contains = ""):
        coordName = "r" + str(self.getRow()).zfill(2) + "c"+str(self.getColumn()).zfill(2)
        if getFullPath:
            imagesURL = [os.path.join(inputPath, f) for f in os.listdir(inputPath) if (os.path.isfile(os.path.join(inputPath, f)) and coordName in f and contains in f)]
        else:
            imagesURL = [f for f in os.listdir(inputPath) if (os.path.isfile(os.path.join(inputPath, f)) and coordName in f and contains in f)]
        return imagesURL

    def projectMosaic(self, stackPath, outputFolder, channelExport = "All"):
        if DEBUG:
            print("ENTERING projectMosaic")
        containsString = "ch"
        if channelExport != "All":
            channelNumber = str(int(channelExport) + 1)
            containsString = containsString + channelNumber
        imagesURL = self.getImagesInFolder(stackPath, getFullPath=True, contains="ch")
        self.mipImages(imagesURL, outputFolder)
            
    def convertToRGB(self, inputPath, outputPath, channelExport="All", invert=False):
        if DEBUG:
            print("ENTERING convertToRGB")
        containsString = "ch"
        if channelExport != "All":
            channelNumber = int(channelExport) + 1
            containsString = containsString + str(channelNumber)
        imagesURL = self.getImagesInFolder(inputPath, getFullPath=False, contains=containsString)
        imagesURL.sort()
        options = ""
        for index, url in enumerate(imagesURL, start=0):
            if channelExport == "All":
                 channelMin = self.getOptions().min_max_display[index][0]
                 channelMax = self.getOptions().min_max_display[index][1]
            else:
                channelMin = self.getOptions().min_max_display[channelNumber-1][0]
                channelMax = self.getOptions().min_max_display[channelNumber-1][1]
            IJ.log(url + " - Min=" + str(channelMin)+", Max=" + str(channelMax))
            IJ.open(inputPath+url)
            imp = IJ.getImage()
            imp.getProcessor().setMinAndMax(channelMin, channelMax)
            options = options + "c" + str(index+1) + "=" + url + " "
        if channelExport == "All":
            IJ.run("Merge Channels...", options + " create")
            composite = IJ.getImage()
            IJ.run("RGB Color", "");
            imp = IJ.getImage()
            aFile = outputPath + imagesURL[0][:7] + imagesURL[0][10:]
            composite.close()
        else:
            imp = IJ.getImage()
            IJ.run("Grays")
            IJ.run(imp, "Invert LUT", "");
            if imp.isStack():
                IJ.run(imp, "8-bit", "stack")
            else:
                IJ.run("RGB Color", "")
            aFile = outputPath + imagesURL[0]
        if DEBUG:
            print("convertToRGB: saving file: " + aFile)
        IJ.save(imp, aFile)
        imp.close()

    def mergeChannels(self, dims):            
        channels = dims[4]
        if channels==1:
            return
        path = self.experiment.getPath()
        images = self.getImages()
        urlsChannel1 = [image.getURLWithoutField() for image in images if image.getChannel()==1] 
        if self.getOptions().stack:
            urlsChannel1 = [url[:6] + url[9:] for url in urlsChannel1]
            urlsChannel1 = set(urlsChannel1)            
        toBeDeleted = []
        for url in urlsChannel1:
            images = []
            IJ.open(self.experiment.getOutFolder() + url)
            imp = IJ.getImage()
            toBeDeleted.append(self.experiment.getOutFolder() + url)
            images.append(url)
            for c in range(2, channels+1):
                newURL = url.replace("ch1", "ch"+str(c))
                IJ.open(self.experiment.getOutFolder() + newURL)
                toBeDeleted.append(self.experiment.getOutFolder() + newURL)
                images.append(newURL)
            options = ""
            for c in range(1, channels+1):
                options = options + "c"+str(c)+"="+images[c-1]+" "
            options = options + "create"
            IJ.run(imp, "Merge Channels...", options);
            imp = IJ.getImage()
            aFile = self.experiment.getOutFolder() + url.replace("ch1", "")
            IJ.save(imp, aFile)
            imp.close()
        for aPath in toBeDeleted:
            os.remove(aPath)

    def mipImages(self, images, outputPath):
        imps = []
        for url in images:
            IJ.open(url)
            title = url.split("/")[-1]
            imp = IJ.getImage()
            projImp = ZProjector.run(imp,"max")
            IJ.save(projImp, outputPath + title)
            imps.append(projImp)    
            imp.close()
            projImp.close()
        if  self.getOptions().projectionMosaicComposite:
            rgbStackMerge = RGBStackMerge()
            composite = rgbStackMerge.mergeHyperstacks(imps,False)
            name = title[:6] +"-"+title[11:]
            IJ.log("+ Composite: "+name);
            IJ.save(composite, outputPath + name)

    # Currently unused
    def getImagesPerChannel(self, channels):
        allImages = self.getImages()
        res = []
        for c in range (1, channels + 1):
            filtered = [image for image in allImages if image.getChannel()==c]
            res.append(filtered);
        return res

    def getImagesForTimeFieldAndChannel(self, timePoint, field, channel):
        allImages = self.getImages()
        images = [image for image in allImages if image.getTime()==timePoint and image.getChannel()==channel and image.getField()==field]
        return images

    def getMergedImageName(self):
        allImages = self.getImages()
        image1 = allImages[0]
        url = image1.getURL()
        strippedURL = url[:6] + url[9:]
        strippedURL = strippedURL[:6] + strippedURL[9:]
        strippedURL = strippedURL[:7] + strippedURL[10:]
        return strippedURL
        
    def getImagesForZPosTimeAndChannel(self, zPosition, timePoint, channel):
        allImages = self.getImages()
        images = [image for image in allImages if image.getPlane()==zPosition and image.getChannel()==channel and image.getTime()==timePoint]
        return images

    def copyImagesToWorkFolder(self, images):
        srcPath = self.experiment.getPath()
        path = self.experiment.getWorkFolder()
        names = [image.getURL() for image in images]
        newNames = [str(names.index(name)+1).zfill(2)+".tif" for name in names]
        for name, newName in zip(names, newNames):
            shutil.copy(srcPath+"/"+name, path+"/"+newName)
        return names, newNames

    def emptyWorkFolder(self):
        shutil.rmtree(self.experiment.getWorkFolder())
        
    def runGridCollectionStitching(self):
        parameters = "type=[Positions from file] " + \
                     "order=[Defined by TileConfiguration] " + \
                     "directory=["+self.experiment.getWorkFolder()+"] " + \
                     "layout_file=TileConfiguration.txt " + \
                     "fusion_method=[Linear Blending] " + \
                     "regression_threshold=0.30 " + \
                     "max/avg_displacement_threshold=2.50 " + \
                     "absolute_displacement_threshold=3.50 "
        if self.getOptions().computeOverlap: 
            parameters = parameters + "compute_overlap "
        parameters = parameters + \
                     "subpixel_accuracy " + \
                     "computation_parameters=[Save computation time (but use more RAM)] " + \
                     "image_output=[Fuse and display] "
        IJ.run("Grid/Collection stitching", parameters)
        
    def createHyperstack(self):
        Interpreter.batchMode=True
        name = self.plate.getName()+"_"+self.getID()
        dims = self.getDimensions()
        print(dims)
        mosaic = IJ.createImage(name, "16-bit composite-mode", dims[0], dims[1], dims[4], dims[2], dims[3])
        if not mosaic: 
             raise Exception('Image too big!')
        mosaic.show()
        pixelWidth = self.getPixelWidth()
        IJ.run(mosaic, "Set Scale...", "distance=1 known="+str(pixelWidth)+" unit=m");
        mosaic.show()
        images = self.getImages()
        xCoords = [int(round(image.getX()/float(pixelWidth))) for image in images]
        yCoords = [int(round(image.getY()/float(pixelWidth))) for image in images]
        xCoords, yCoords = transformCoordinates(xCoords, yCoords)        
        for image, x, y in zip(images, xCoords, yCoords):
            IJ.open(image.getFolder() + os.path.sep + image.getURL())
            imp = IJ.getImage()
            IJ.run(imp, "Copy", "")
            mosaic.setPosition(image.getChannel(), image.getPlane(), image.getTime())
            mosaic.paste(x, y, "Copy")
            imp.close()
        Interpreter.batchMode=False
        mosaic.show()    
        for c in range(1,dims[4]):
            mosaic.setPosition(c, 1, 1)
            IJ.run("Enhance Contrast", "saturated=0.35")
        mosaic.repaintWindow()

    def renameAllOutputs(self):
        wellName = self.getName()
        if self.getOptions().zStackFields:
            self.addWellAndChannelNameToImages(self.experiment.getZStackFolder(), self.experiment.getZStackFolder() + "/" + wellName + "/")
        if self.getOptions().projectionFields:
            self.addWellAndChannelNameToImages(self.experiment.getProjectionsFolder(), self.experiment.getProjectionsFolder() + "/" + wellName + "/")
        if self.getOptions().zStackMosaic:
            self.addWellAndChannelNameToImages(self.experiment.getZStackMosaicFolder())            
        if self.getOptions().projectionMosaic:
            self.addWellAndChannelNameToImages(self.experiment.getProjectionMosaicFolder())
        if self.getOptions().projectionMosaicRGB:
            self.addWellAndChannelNameToImages(self.experiment.getProjectionMosaicRGBFolder())
        channelList = list(self.getOptions().channelRGB)
        for i in range(len(channelList)):
            if channelList[i] == "1":
                self.addWellAndChannelNameToImages(self.experiment.getProjectionMosaicChannelFolder())
        
    def getChannelNames(self):
        dims = self.getDimensions()
        channels = dims[4]
        channelNames = []
        for c in range(1, channels+1):
            images = self.getImagesForZPosTimeAndChannel(1, 0, c)
            channelNames.append(images[0].getChannelName())
        return channelNames
            
    def addWellAndChannelNameToImages(self, inputPath, outputPath = None):
        if outputPath:
            if not os.path.exists(outputPath):
                os.makedirs(outputPath)
        else:
            outputPath = inputPath
        imagesURL = self.getImagesInFolder(inputPath, getFullPath=False, contains = "")     
        wellName = self.getName()
        IJ.log("Renaming images of well " + wellName + ": From [" + inputPath+"] To [" + outputPath + "]"); 
        for image in imagesURL:
            newImage = image
            for channelNumber, channelName in enumerate(self.getChannelNames(), start=1):
                newImage = newImage.replace("ch" + str(channelNumber), channelName+"-")
            os.rename(inputPath + image, outputPath + wellName + newImage[6:])
            
    def getName(self):
        '''
            Get the name of the well from the file wellNames.txt
            Returns the coordinates of the well in the plate followed by the name if specified
        '''
        path = self.experiment.getPath()
        namesFile = "/wellNames.txt"
        row = self.getRow();
        column = self.getColumn();
        checkString = str(row).zfill(2) + str(column).zfill(2) + ":"
        resultName ="r" +  str(row).zfill(2) + "c" + str(column).zfill(2)
        with open(os.path.join(path+namesFile),"r") as file:
            wellLine = [line for line in file if line.startswith(checkString)]
            if(len(wellLine)>0):
                resultName = resultName+"-"+wellLine[0].split(":")[-1][:-1]
        return resultName
    
    def __str__(self):
        anID = self.getID();
        row = self.getRow();
        column = self.getColumn();
        nrOfImages = len(self.getImages())
        imagesString = "images";
        if (nrOfImages==1):
             imagesString = "image";
        res = "Well ("+anID+", r=" + str(row) + ", c=" + str(column) + ", " + str(nrOfImages) + " " + imagesString +")"
        return res

class Image(object):

    def __init__(self, anID):
        self.id = anID

    def getID(self):
        return self.id

    def setState(self, state):
        self.state = state

    def getState(self):
        return self.state
        
    def setURL(self, url):
        self.url = url

    def getURL(self):
        return self.url
    
    def setRow(self, row):
        self.row = row

    def getRow(self):
        return self.row
        
    def setColumn(self, column):
        self.column = column

    def getColumn(self):
        return self.column

    def getField(self):
        return self.field

    def setField(self, field):
        self.field = field

    def getPlane(self):
        return self.plane

    def setPlane(self, plane):
        self.plane = plane
        
    def getTime(self):
        return self.time

    def setTime(self, time):
        self.time = time
        
    def getChannel(self):
        return self.channel

    def setChannel(self, channel):
        self.channel = channel

    def getChannelName(self):
        return self.channelName

    def setChannelName(self, name):
        self.channelName = name
        
    def getWidth(self):
        return self.width

    def setWidth(self, width):
        self.width = width

    def getHeight(self):
        return self.height

    def setHeight(self, height):
        self.height = height

    def getX(self):
        return self.x

    def getY(self):
        return self.y

    def getZ(self):
        return self.z

    def setX(self, x):
        self.x = x

    def setY(self, y):
        self.y = y
    
    def setZ(self, z):
        self.z = z

    def setPixelWidth(self, pixelWidth):
        self.pixelWidth = pixelWidth

    def getPixelWidth(self):
        return self.pixelWidth

    def setPixelHeight(self, pixelHeight):
        self.pixelHeight = pixelHeight

    def getPixelHeight(self):
        return self.pixelHeight

    def setFolder(self, folder):
        self.folder = folder

    def getFolder(self):
        return self.folder

    def getURLWithoutField(self):
        url = self.getURL()
        res = url[:6] + url[9:]
        return res
        
    def __str__(self):
        res = "Image ("+self.getID()+", state="+self.getState()+", " + self.getURL() + ", r" + self.getRow() + ", c="+self.getColumn()+ ", f="+self.getField()+")"
        return res
    
class PhenixHCSExperiment(object):
    '''
       PhenixHCSExperiment represents a high-content streaming experiment done with 
       the Opera Phenix HCS. An experiment contains usually one plate with a number
       of wells. Each well contains a number of fields. The fields of one well form
       a mosaic of images. Each image can have multiple frames, z-slices and channels.
    '''        
    @classmethod
    def fromIndexFile(cls, path):
        '''
            Create the experiment from the index-xml-file (Index.idx.xml).
            The xml-file is parsed and different xml-elements are stored
            in the attributes of the experiment. 

            Parameters
            ----------
            path : str
                The path to the file Index.idx.xml
        '''
        root = ET.parse(path).getroot()
        children = root.getchildren()
        experiment = PhenixHCSExperiment()
        experiment.setUser(children[0].text)
        experiment.setInstrumentType(children[1].text)
        experiment.setPlates(children[2])
        experiment.setWells(children[3])
        experiment.setMaps(children[4])
        experiment.setImages(children[5])
        experiment.setPath(os.path.dirname(path))
        return experiment

    def setExporter(self, anExporter):
        self.exporter = anExporter
        
    def getOptions(self):
        if not self.exporter:
            return None
        else:
            return self.exporter.getOptions()
            
    def setPath(self, path):
        self.path = path

    def getPath(self):
        return self.path

    def getParentPath(self):
        return os.path.dirname(self.getPath())

    def getPathForDir(self, aDirectory):
        path = self.getParentPath()
        path = path + aDirectory
        if not os.path.isdir(path):
            os.mkdir(path)
        return path

    def getZStackFolder(self):
        return self.getPathForDir(_Z_STACK_FOLDER)

    def getProjectionsFolder(self):
        return self.getPathForDir(_PROJECTION_FOLDER)

    def getZStackMosaicFolder(self):
        return self.getPathForDir(_Z_STACK_MOSAIC_FOLDER)

    def getProjectionMosaicFolder(self):
        return self.getPathForDir(_PROJECTION_MOSAIC_FOLDER)

    def getProjectionMosaicRGBFolder(self):
        return self.getPathForDir(_PROJECTION_MOSAIC_RGB_FOLDER)

    def getProjectionMosaicChannelFolder(self):
        return self.getPathForDir(_PROJECTION_MOSAIC_CHANNEL_FOLDER)

    def getWorkFolder(self):
        return self.getPathForDir(_WORK_FOLDER)

    def getFlatfieldFolder(self):
        return self.getPathForDir(_FLATFIELD_FOLDER)
    
    def getOutFolder(self):
         return self.getPathForDir(_OUT_FOLDER)
         
    def setUser(self, user):
        self.user = user

    def getUser(self):
        return self.user

    def setInstrumentType(self, instrumentType):
        self.instrumentTYpe = instrumentType

    def getInstrumentType(self):
        return self.instrumentTYpe

    def getNrOfPlates(self):
        return len(self.getPlates());

    def getNrOfColumns(self):
        return 0;

    def getNrOfRows(self):
        return 0;

    def getNrOfWells(self):
        return len(self.getWells());

    def getPlates(self):
        '''
        Answers the plates of the experiment.

        Returns
        -------
            plates : list
                A list of plate objects.
        '''
        return self.plates

    def setPlates(self, plates):
        '''
           Takes a plates xml-string and sets the plates
           of the experiment as a list of plate-objects.

           Parameters
           ----------
           plates : str
            The string of the plates xml-element.
        '''
        self.plates = []
        plates = plates.getchildren()
        for plate in plates:
            self.plates.append(Plate(plate, self))

    def getWells(self):
        return self.wells

    def setWells(self, wells):
        self.wells = wells

    def getMaps(self):
        return self.maps

    def setMaps(self, maps):
        self.maps = maps

    def getImages(self):
        return self.images

    def setImages(self, images):
        self.images = images

    def getNrOfImages(self):
        '''
           Answers the number of images in the well. 
           Each frame, channel and z-slice counts as one image.

           Returns
           -------
           nrOfImages : int
        '''
        return len(self.getImages())

    def getWell(self, anID, aPlate):
        '''
           Answers the well with the id anID as a well-object. 

           Parameters
           ----------
           anID : str
              The id of the well
           aPlate : Plate
              The plate on which the well is situated will be set in the well-object
           
           Returns
           -------
           wellObject : Well
              The well-object for the well with the id anID
        '''
        for well in self.wells:
            if well[0].text==anID:
                imageData = []
                for i in range(3, len(well)):
                    imageData.append(well[i])
                wellObject = Well(anID, well[1].text, well[2].text, imageData, self, aPlate)
                return wellObject
        return None 

    def getImage(self, anID):
        '''
           Answers the image with the id anID as an image-object. 

           Parameters
           ----------
           anID : str
              The id of the image
           
           Returns
           -------
           result : Image
              The image-object for the image with the id anID
        '''
        for image in self.images:
            if image[0].text==anID:
                result = Image(anID)
                result.setFolder(self.getPath())
                result.setState(image[1].text)
                result.setURL(image[2].text)
                result.setRow(image[3].text)
                result.setColumn(image[4].text)
                result.setField(image[5].text)
                result.setPlane(int(image[6].text))
                result.setTime(int(image[7].text))
                result.setChannel(int(image[8].text))
                result.setChannelName(image[10].text)
                result.setPixelWidth(float(image[15].text))
                result.setPixelHeight(float(image[16].text))
                result.setWidth(int(image[17].text))
                result.setHeight(int(image[18].text))
                result.setX(float(image[23].text))
                result.setY(float(image[24].text))
                result.setZ(float(image[25].text))
                return result
        return None
    
    def __str__(self):
        nrOfPlates = self.getNrOfPlates();
        nrOfWells = self.getNrOfWells();
        nrOfImages = self.getNrOfImages();
        platesString = "plates";
        if (nrOfPlates==1):
             platesString = "plate";
        wellsString = "wells";
        if (nrOfWells==1):
             wellsString = "well";
        imagesString = "images";
        if (nrOfImages==1):
             imagesString = "image";
        res = "PhenixHCSExperiment ("+self.getUser()+", "+ self.getInstrumentType()+", "+str(self.getNrOfPlates()) + " " + platesString + ", "+str(self.getNrOfWells()) + " " + wellsString + ", " + str(self.getNrOfImages()) + " " + imagesString + ")"
        return res

if 'getArgument' in globals():
    if not hasattr(zip, '__call__'):
        del zip                     # the python function zip got overriden by java.util.zip, so it must be deleted to get the zip-function to work.
    args = getArgument()
    args = " ".join(args.split())
    print(args.split())
    main(args.split())
    sys.exit(0)

class SplitIntoChunksOfSizeTest(unittest.TestCase):
    def testSplitIntoChunksOfSize(self):
        chunks = splitIntoChunksOfSize("1234567890", 2)
        self.assertEqual(len(chunks[0]),2)
        self.assertEqual(chunks[0], '12')
        self.assertEqual(chunks[-1], '90')
        self.assertEqual(len(chunks), 5)

        chunks = splitIntoChunksOfSize("123456789", 2)
        self.assertEqual(len(chunks[0]),2)
        self.assertEqual(len(chunks), 5)
        self.assertEqual(chunks[-1], '9')

class TransformCoordinatesTest(unittest.TestCase):
    def testTransformCoordinates(self):
        xCoords, yCoords = transformCoordinates([-10, -5, -1, 0, 1, 5, 10], [-10, -5, -1, 0, 1, 5, 10])
        expectedXCoords = [0, 5, 9, 10, 11, 15, 20]
        expectedYCoords = [20, 15, 11, 10, 9, 5, 0]
        for actual, expected in zip(xCoords, expectedXCoords):
            self.assertEqual(actual, expected)
        for actual, expected in zip(yCoords, expectedYCoords):
            self.assertEqual(actual, expected)
        xCoords, yCoords = transformCoordinates([10, 11, 15, 19, 20], [10, 11, 15, 19, 20])
        expectedXCoords = [0, 1, 5, 9, 10]
        expectedYCoords = [10, 9, 5, 1, 0]
        for actual, expected in zip(xCoords, expectedXCoords):
            self.assertEqual(actual, expected)
        for actual, expected in zip(yCoords, expectedYCoords):
            self.assertEqual(actual, expected)

class PhenixHCSExperimentTest(unittest.TestCase):
    folder=None
    path=None
    exp=None
    
    def setUp(self):
        unittest.TestCase.setUp(self)
        self.folder = IJ.getDir("macros") + "toolsets/opera_export_tools_test"
        self.path = self.folder + "/Index.idx.xml"
        self.exp = PhenixHCSExperiment.fromIndexFile(self.path)
        
    def testFromIndexFile(self):
        exp = PhenixHCSExperiment.fromIndexFile(self.path)
        self.assertEquals(exp.getPath(), self.folder)
        self.assertEquals(exp.getUser(), 'PKI')
        self.assertEquals(exp.getInstrumentType(), 'Phenix')
        self.assertEquals(exp.getNrOfPlates(), 1)
        self.assertEquals(exp.getNrOfColumns(), 0)
        self.assertEquals(exp.getNrOfRows(), 0)
        self.assertEquals(exp.getNrOfWells(), 2)
        self.assertEquals(exp.getPlates()[0].getName(), 'Duc_plaque1_20210922')
        self.assertEquals(len(exp.getPlates()), 1)
        self.assertEquals(len(exp.getWells()), 2)
        self.assertEquals(exp.getWells()[0][0].text, "0202")
        self.assertEquals(exp.getWells()[1][0].text, "0203")
        self.assertEquals(('Map' in str(exp.getMaps()[0])), True)
        self.assertEquals(len(exp.getImages()), 24)
        self.assertEquals(exp.getNrOfImages(), 24)

    def testGetWell(self):
        exp = self.exp
        well = exp.getWell("0202", exp.getPlates()[0])
        self.assertEquals(isinstance(well, Well), True)
        self.assertEquals(len(well.getImageData()), 12)
        self.assertEquals(well.getRow(), '2')
        self.assertEquals(well.getColumn(), '2')
        self.assertEquals(well.getID(), '0202')
        well = exp.getWell("0203", exp.getPlates()[0])
        self.assertEquals(isinstance(well, Well), True)
        self.assertEquals(len(well.getImageData()), 12)
        self.assertEquals(well.getRow(), '2')
        self.assertEquals(well.getColumn(), '3')
        self.assertEquals(well.getID(), '0203')

    def testGetImage(self):
        exp = self.exp
        image = exp.getImage('0203K1F2P1R1')
        self.assertEquals(isinstance(image, Image), True)
        self.assertEquals(image.getID(), '0203K1F2P1R1')
        self.assertEquals(image.getState(), 'Ok')
        self.assertEquals(image.getURL(), 'r02c03f02p01-ch1sk1fk1fl1.tiff')        
        self.assertEquals(image.getRow(), '2')
        self.assertEquals(image.getColumn(), '3')
        self.assertEquals(image.getField(), '2')
        self.assertEquals(image.getPlane(), 1)
        self.assertEquals(image.getTime(), 0)
        self.assertEquals(image.getChannel(), 1)
        self.assertEquals(image.getWidth(), 108)
        self.assertEquals(image.getHeight(), 108)
        self.assertEquals(image.getX(), 0.0001025102)
        self.assertEquals(image.getY(), -0.0000615061)
        self.assertEquals(image.getZ(), -2E-06)
        self.assertEquals(image.getPixelWidth(), 1.8983367649421008E-07)
        self.assertEquals(image.getPixelHeight(), 1.8983367649421008E-07)
        self.assertEquals(image.getFolder(), self.folder)
        self.assertEquals(image.getURLWithoutField(), 'r02c03p01-ch1sk1fk1fl1.tiff')

class PlateTest(unittest.TestCase):
    plateXML = None
    experiment = None
    def setUp(self):
        unittest.TestCase.setUp(self)
        folder = IJ.getDir("macros") + "toolsets/opera_export_tools_test"
        path = folder + "/Index.idx.xml"
        root = ET.parse(path).getroot()
        children = root.getchildren()
        self.plateXML = children[2][0]
        self.experiment = PhenixHCSExperiment.fromIndexFile(path)

    def testConstructor(self):
        plate = Plate(self.plateXML, self.experiment)    
        self.assertEquals(plate.getName(), 'Duc_plaque1_20210922')
        wells = plate.getWells()
        self.assertEquals(len(wells), 2)
        self.assertEquals(wells[0].plate, plate)

    def testStr(self):
        plate = Plate(self.plateXML, self.experiment)    
        self.assertEquals(str(plate), 'Plate (Duc_plaque1_20210922, 96 PerkinElmer CellCarrier Ultra, 8x12)')

    def testGetWells(self):
        plate = Plate(self.plateXML, self.experiment)
        wells = plate.getWells()
        self.assertEquals(len(wells), 2)
        self.assertEquals(wells[0].getID(), '0202') 
        self.assertEquals(wells[1].getID(), '0203')

    def testGetName(self):
        plate = Plate(self.plateXML, self.experiment)
        self.assertEquals(plate.getName(), 'Duc_plaque1_20210922')

class OperaExporterTest(unittest.TestCase):
    def setUp(self):
        unittest.TestCase.setUp(self)
        folder = IJ.getDir("macros") + "toolsets/opera_export_tools_test"
        path = folder + "/Index.idx.xml"
        self.params = ['--wells=0202', '--slice=0', '--channel=1', '--stitchOnMIP', '--projectionMosaic', 
                       '--projectionMosaicComposite', '--projectionMosaicRGB', '--channelRGB=100', 
                       '--fusion-method=Linear_Blending', '--regression-threshold=0.3', '--displacement-threshold=2.5', 
                       '--abs-displacement-threshold=3.5', '--pseudoflatfield=0', '--rollingball=0', 
                       '--subtract-background-radius=0', '--subtract-background-offset=3', 
                       '--subtract-background-iterations=1', '--subtract-background-skip=0.3', 
                       '--colours=Green,Blue,Red,Cyan,Magenta,Yellow,Grays', 
                       path]

    def testConstructor(self):
        exporter = OperaExporter(self.params)
        self.assertEquals(len(exporter.getWells()), 1)
        
def suite():
    suite = unittest.TestSuite()

    suite.addTest(SplitIntoChunksOfSizeTest('testSplitIntoChunksOfSize'))
    suite.addTest(TransformCoordinatesTest('testTransformCoordinates'))
    suite.addTest(PhenixHCSExperimentTest('testFromIndexFile'))
    
    suite.addTest(PhenixHCSExperimentTest('testGetWell'))
    suite.addTest(PhenixHCSExperimentTest('testGetImage'))
    
    suite.addTest(PlateTest('testConstructor'))
    suite.addTest(PlateTest('testStr'))
    suite.addTest(PlateTest('testGetWells'))
    suite.addTest(PlateTest('testGetName'))

    suite.addTest(OperaExporterTest('testConstructor'))
    return suite

folder = IJ.getDir("macros") + "toolsets/opera_export_tools_test"
if not os.path.isdir(folder):
    os.mkdir(folder)
if not os.path.isfile(folder + "/Index.idx.xml"):
    URLS = ['https://dev.mri.cnrs.fr/attachments/download/2545/Index.idx.xml', 
            'https://dev.mri.cnrs.fr/attachments/download/2529/r02c02f01p01-ch1sk1fk1fl1.tiff', 
            'https://dev.mri.cnrs.fr/attachments/download/2531/r02c02f01p01-ch2sk1fk1fl1.tiff',
            'https://dev.mri.cnrs.fr/attachments/download/2524/r02c02f01p01-ch3sk1fk1fl1.tiff', 
            'https://dev.mri.cnrs.fr/attachments/download/2542/r02c02f01p02-ch1sk1fk1fl1.tiff',
            'https://dev.mri.cnrs.fr/attachments/download/2540/r02c02f01p02-ch2sk1fk1fl1.tiff', 
            'https://dev.mri.cnrs.fr/attachments/download/2525/r02c02f01p02-ch3sk1fk1fl1.tiff',
            'https://dev.mri.cnrs.fr/attachments/download/2537/r02c02f02p01-ch1sk1fk1fl1.tiff', 
            'https://dev.mri.cnrs.fr/attachments/download/2532/r02c02f02p01-ch2sk1fk1fl1.tiff',
            'https://dev.mri.cnrs.fr/attachments/download/2533/r02c02f02p01-ch3sk1fk1fl1.tiff', 
            'https://dev.mri.cnrs.fr/attachments/download/2534/r02c02f02p02-ch1sk1fk1fl1.tiff',
            'https://dev.mri.cnrs.fr/attachments/download/2519/r02c02f02p02-ch2sk1fk1fl1.tiff', 
            'https://dev.mri.cnrs.fr/attachments/download/2538/r02c02f02p02-ch3sk1fk1fl1.tiff',
            'https://dev.mri.cnrs.fr/attachments/download/2535/r02c03f01p01-ch1sk1fk1fl1.tiff', 
            'https://dev.mri.cnrs.fr/attachments/download/2526/r02c03f01p01-ch2sk1fk1fl1.tiff',
            'https://dev.mri.cnrs.fr/attachments/download/2520/r02c03f01p01-ch3sk1fk1fl1.tiff', 
            'https://dev.mri.cnrs.fr/attachments/download/2536/r02c03f01p02-ch1sk1fk1fl1.tiff',
            'https://dev.mri.cnrs.fr/attachments/download/2521/r02c03f01p02-ch2sk1fk1fl1.tiff', 
            'https://dev.mri.cnrs.fr/attachments/download/2539/r02c03f01p02-ch3sk1fk1fl1.tiff',
            'https://dev.mri.cnrs.fr/attachments/download/2541/r02c03f02p01-ch2sk1fk1fl1.tiff', 
            'https://dev.mri.cnrs.fr/attachments/download/2527/r02c03f02p01-ch1sk1fk1fl1.tiff',
            'https://dev.mri.cnrs.fr/attachments/download/2528/r02c03f02p01-ch3sk1fk1fl1.tiff', 
            'https://dev.mri.cnrs.fr/attachments/download/2522/r02c03f02p02-ch1sk1fk1fl1.tiff',
            'https://dev.mri.cnrs.fr/attachments/download/2523/r02c03f02p02-ch2sk1fk1fl1.tiff', 
            'https://dev.mri.cnrs.fr/attachments/download/2530/r02c03f02p02-ch3sk1fk1fl1.tiff',
            ]
    print("Starting download of the test-dataset...");
    for url in URLS:        
        os.popen('wget -P '+folder+'/ '+url).read()
    print("...download of the test-dataset finished.")
runner = unittest.TextTestRunner(sys.stdout, verbosity=2)
runner.run(suite())
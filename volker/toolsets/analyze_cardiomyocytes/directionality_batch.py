# @File(label = "Input directory", style = "directory") srcFile
# @String(label = "File extension", value=".tif") ext
# @Integer(label = "Number of width measurements", value="7", stepSize="1") numberOfWidthMeasurements
# Compare with the original Process_Folder to see how ImageJ 1.x
# GenericDialog use can be converted to @Parameters.

import os
from ij import IJ, ImagePlus
import fiji.analyze.directionality.Directionality_
from ij import WindowManager
import math
from ij.measure import ResultsTable
from array import zeros
from ij.plugin.frame import RoiManager

def run():
  global srcFile, ext, numberOfWidthMeasurements
  IJ.run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction display redirect=None decimal=3");
  IJ.setForegroundColor(255,255,255);
  IJ.setBackgroundColor(0,0,0);  
  IJ.run("Options...", "iterations=1 count=1 black");
  table = ResultsTable()
  srcDir = srcFile.getAbsolutePath()
  for root, directories, filenames in os.walk(srcDir):
    for filename in filenames:
      # Check for file extension
      if not filename.endswith(ext):
        continue
      # Check for file name pattern
      process(srcDir, root, filename, table, numberOfWidthMeasurements)
  table.save(os.path.join(srcDir, 'Results.xls'))
  
def process(srcDir, currentDir, fileName, table, numberOfWidthMeasurements):
    if "control-images" in currentDir:
      return   
    print "Processing:"
    # Opening the image
    print "Open image file", fileName
    imp = IJ.openImage(os.path.join(currentDir, fileName)) 
    # Put your processing commands here!
    imp.show()
   
    processCurrentImage(table);

    impIn = WindowManager.getCurrentImage()
    path = os.path.join(srcDir, 'control-images')
    if not os.path.exists(path):
      os.makedirs(path)
    IJ.save(os.path.join(path, fileName))
    impIn.changes = False
    impIn.close()

def processCurrentImage(table):
    imp = WindowManager.getCurrentImage()
    fileName = imp.getTitle()
    middleSlice = int(math.floor(imp.getNFrames() / 2.0) + (imp.getNFrames() % 2))
    imp.setSlice(middleSlice)
    IJ.run("Duplicate...", " ")
    imp.close()
    imp = WindowManager.getCurrentImage()
    
    dir = fiji.analyze.directionality.Directionality_()
    dir.setImagePlus(imp)
    dir.setMethod(fiji.analyze.directionality.Directionality_.AnalysisMethod.FOURIER_COMPONENTS)
    dir.setBinNumber(90)
    dir.setBinStart(-90)
    dir.setBuildOrientationMapFlag(False)
        
    dir.computeHistograms()
    dir.fitHistograms()
    results = dir.getFitAnalysis()
    direction = math.degrees(results[0][0])
    dispersion = math.degrees(results[0 ][1])
    amount = results[0][2]
    goodness = results[0][3]
    IJ.run("Clear Results")
    IJ.run("FFT")
    fftImp = WindowManager.getCurrentImage()
    
    IJ.run("Mean...", "radius=2");
    IJ.run("Find Maxima...", "noise=15 output=[Point Selection]")
    IJ.run("Measure")
    fftImp.changes = False
    fftImp.close()
      
    rt = ResultsTable.getResultsTable()
    size = rt.size()
    numberOfFrequences = size
    if size>=5: 
       numberOfFrequences = 5
    R = zeros('f', numberOfFrequences)
    Theta = zeros('f', numberOfFrequences)
    for i in range(0, numberOfFrequences):
       R[i] = rt.getValue("R", i)
       Theta[i] = rt.getValue("Theta", i)
    table.incrementCounter()
    table.addValue('image', fileName)
    table.addValue('Direction', direction)
    table.addValue('Dispersion', dispersion)
    table.addValue('Amount', amount)
    table.addValue('Goodness', goodness)
    for i in range(0, numberOfFrequences):
       table.addValue('R'+str(i), R[i])
       table.addValue('Theta'+str(i), Theta[i])
    
    widths = measureWidth(numberOfWidthMeasurements)
    i = 1;
    for width in widths:
      table.addValue("width" + str(i), width)        
      i = i + 1
    headings = rt.getHeadings()
    for heading in headings:
      if heading != "Label":
        value = rt.getValue(heading, 0)
        table.addValue(heading, value)
    table.show('Directonality analysis')
    
def measureWidth(numberOfWidthMeasurements):
  impIn = WindowManager.getCurrentImage()
  title = impIn.getTitle()
  IJ.run("Duplicate...", " ")
  impWork =  WindowManager.getCurrentImage()
  workTitle = impWork.getTitle()
  IJ.run("Clear Results")
  IJ.run("Measure")
  rt = ResultsTable.getResultsTable()
  min = rt.getValue("Min", 0)  
  IJ.run("Subtract...", "value=" + str(min))
  IJ.resetMinAndMax()
  imp = WindowManager.getCurrentImage()
  width = imp.getWidth()
  height = imp.getHeight()
  IJ.setAutoThreshold(imp, "Mean dark")
  roiManager = RoiManager.getRoiManager()
  roiManager.reset()
  IJ.run("Analyze Particles...", "size=1000-Infinity add")
  IJ.run("Clear Results")
  roiManager.select(0)
  roiManager.runCommand("Measure")
  angle = rt.getValue("Angle", 0)
  IJ.run("Select None")
  roiManager.runCommand("Delete")
  IJ.run("Rotate... ", "angle="+str(angle)+" grid=1 interpolation=Bilinear enlarge")
  IJ.setAutoThreshold(imp, "Li dark")
  IJ.run("Convert to Mask")
  IJ.run("Fill Holes")
  roiManager.reset()
  IJ.run("Analyze Particles...", "size=1000-Infinity add")
  IJ.run("Clear Results")
  roiManager.select(0)
  IJ.run("Clear Outside")
  IJ.selectWindow(title)
  IJ.run("Rotate... ", "angle="+str(angle)+" grid=1 interpolation=Bilinear enlarge")
  roiManager.select(0) 
  roiManager.runCommand("Measure")
  IJ.run("Select None")
  IJ.run("Rotate... ", "angle="+str(-angle)+" grid=1 interpolation=Bilinear enlarge")
  IJ.run("Canvas Size...", "width="+str(width)+" height="+str(height)+" position=Center zero")
  IJ.selectWindow(workTitle)
  xBox = rt.getValue("BX", 0)
  lengthBox = rt.getValue("Width", 0)
  heightBox = rt.getValue("Height", 0)
  lengthEllipse = rt.getValue("Major", 0)
  heightEllipse = rt.getValue("Minor", 0)
  calibration = imp.getCalibration()
  xMiddle = int(round(((lengthBox - xBox) / 2.0) + xBox, 0))
  xOuter = xBox + lengthBox
  xInner = xBox
  widths = zeros('f', numberOfWidthMeasurements)
  delta = (xOuter - xInner) / (numberOfWidthMeasurements + 1.0)
  for i in range(1,numberOfWidthMeasurements+1):
    deltaLen = delta * i;
    xM = xInner + deltaLen
    widths[i-1] = getWidthAt(xM, imp)
  IJ.run("Flatten");
  IJ.run("Rotate... ", "angle="+str(-angle)+" grid=1 interpolation=Bilinear enlarge")
  IJ.run("Canvas Size...", "width="+str(width)+" height="+str(height)+" position=Center zero")
  impFlat = WindowManager.getCurrentImage()
  imp.changes = False;
  imp.close()
  titleIn = impIn.getTitle()
  titleFlat = impFlat.getTitle()
  IJ.selectWindow(titleIn)
  IJ.run("Add Image...", "image=" + titleFlat + " x=0 y=0 opacity=50 zero")
  impFlat.changes = False
  impFlat.close()
  return widths
  
def getWidthAt(x, imp):
  ip = imp.getProcessor()
  calibration = imp.getCalibration()
  height = ip.getHeight()
  lastValue = 0
  numberOfTimesValueChanged = 0;
  startY = 0;
  endY = 0
  xUnscaled = int(round(calibration.getRawX(x),0))
  for i in range(0, height-1):
    newValue = ip.get(xUnscaled, i)
    if lastValue!=newValue:
        if numberOfTimesValueChanged==0: 
          startY = i
          numberOfTimesValueChanged = numberOfTimesValueChanged + 1
        endY = i
    lastValue = newValue;
  calibration = imp.getCalibration()
  yS = calibration.getY(startY)
  yE = calibration.getY(endY)
  IJ.makeLine(xUnscaled, startY, xUnscaled, endY)
  IJ.run("Add Selection...")
  return yE-yS

if 'getArgument' in globals():
  parameter = getArgument()
  args = parameter.split(",")
  arg1 = args[0]
  arg2 = args[1]
  arg3 = args[2]
  val1 = arg1.split("=")
  val2 = arg2.split("=")
  val3 = arg3.split("=")
  srcFile = val1[1]
  ext = val2[1]
  numberOfWidthMeasurements = int(val3[1])
  
  if srcFile=="None":
    table = ResultsTable()
    processCurrentImage(table)
  else:
    srcFile = File(val1[1])
    run()

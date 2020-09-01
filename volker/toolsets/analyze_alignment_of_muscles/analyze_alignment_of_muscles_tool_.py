####
 # 
 # Analyze alignment of muscles
 # 
 # The tool uses the [Directionality plugin](https://imagej.net/Directionality) to measure the main direction of the structures in the image and the dispersion. 
 # It is used in this context to analyze to which degree the muscles in the image are vertically aligned. 
 # The tool allows to run the Directionality plugin in batch-mode on a series of images. 
 # The direction-histograms and the measurements are exported as csv-files.
 # 
 # (c) 2019-2020, INSERM
 # 
 # written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)
 # 
####
from fiji.analyze.directionality import Directionality_
from ij import WindowManager, ImagePlus
from ij.measure import ResultsTable
import math

def run(binNumber, binStart, binEnd, method):
	'''
	Run Directonality and copy the results into an ImageJ
	Results-table.
	'''
	# Instantiate plugin
	dir = Directionality_()
	  
	# Set fields and settings
	dir.setImagePlus(WindowManager.getCurrentImage())
	fileName = WindowManager.getCurrentImage().getTitle()
	if method=='Fourier components':
		dir.setMethod(Directionality_.AnalysisMethod.FOURIER_COMPONENTS)
	else:
		dir.setMethod(Directionality_.AnalysisMethod.LOCAL_GRADIENT_ORIENTATION)
	dir.setBinNumber(binNumber)
	dir.setBinRange(binStart, binEnd);
	
	dir.setBuildOrientationMapFlag(False)
	  
	# Do calculation
	dir.computeHistograms()
	dir.fitHistograms()

	# Get results
	results = dir.getFitAnalysis()
	direction = math.degrees(results[0][0])
	dispersion = math.degrees(results[0 ][1])
	amount = results[0][2]
	goodness = results[0][3]  

	# Report results
	rt = ResultsTable.getResultsTable()
	rt.incrementCounter()
	rt.show("Results")
	
	rt.addValue('image', fileName)
	rt.addValue('Direction', direction)
	rt.addValue('Dispersion', dispersion)
	rt.addValue('Amount', amount)
	rt.addValue('Goodness', goodness)
	rt.show("Results")
	# Display results table
	table = dir.displayResultsTable()
	table.show("Directionality histograms")

binNumber = 90
binStart = 0
binEnd = 180
method = 'Fourier components'

if 'getArgument' in globals():
  parameter = getArgument()
  args = parameter.split(",")
  arg1 = args[0]
  arg2 = args[1]
  arg3 = args[2]
  arg4 = args[3]
  val1 = arg1.split("=")
  val2 = arg2.split("=")
  val3 = arg3.split("=")
  val4 = arg4.split("=")
  binNumber = int(val1[1])
  binStart = int(val2[1])
  binEnd = int(val3[1])
  method = val4[1];
run(binNumber, binStart, binEnd, method)


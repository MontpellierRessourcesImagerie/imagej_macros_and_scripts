from fiji.analyze.directionality import Directionality_
from ij import WindowManager, ImagePlus
from ij.measure import ResultsTable
import math

def run():
	global binNumber, binStart, binEnd
	# Instantiate plugin
	dir = Directionality_()
	  
	# Set fields and settings
	dir.setImagePlus(WindowManager.getCurrentImage())
	fileName = WindowManager.getCurrentImage().getTitle()
	dir.setMethod(Directionality_.AnalysisMethod.FOURIER_COMPONENTS)
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

if 'getArgument' in globals():
  parameter = getArgument()
  args = parameter.split(",")
  arg1 = args[0]
  arg2 = args[1]
  arg3 = args[2]
  val1 = arg1.split("=")
  val2 = arg2.split("=")
  val3 = arg3.split("=")
  binNumber = int(val1[1])
  binStart = int(val2[1])
  binEnd = int(val3[1])
run()


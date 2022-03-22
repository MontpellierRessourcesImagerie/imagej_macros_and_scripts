'''
 Moving particles divergence tool. 

(c) 2022, INSERM
written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)

The tool takes a results table of tracking data (as created by Trackmate) and calculates the mean of the scalar projections of the vector of the 
displacement of each particle from one timepoint t to the next t+1, onto the vector from a given point to the coordinates of the particle at timepoint t 

If the particles are moving away from the given point the result will be positive, if they are moving towards the given point the result will be negative.
If neither of the above is the case, the result will be near zero.
'''
from ij.measure import ResultsTable
from ij.gui import Plot
from ij.util import Tools
from ij import IJ
from ij.gui import Roi
from ij.gui import NewImage
import jarray
import math 

def main(tableName, showPlot):
    image = IJ.getImage();
    roi = image.getRoi()
    if not roi:
        center = image.getWidth() / 2, image.getHeight() / 2
    else:
        center = roi.getXBase(), roi.getYBase();
    table = ResultsTable.getResultsTable(tableName)
    vectors = getVectorsFromTable(table, center)
    divergence = calculateDivergencePerTime(vectors, center)
    stats = Tools.getStatistics(divergence)
    median = calculateMedian(divergence)
    rt = ResultsTable.getResultsTable ("Divergence")
    if not rt:
        rt = ResultsTable()
    row = rt.getCounter()
    rt.setValue("label", row, tableName)
    rt.setValue("x", row, center[0])
    rt.setValue("y", row, center[1])
    rt.setValue("mean", row, stats.mean)
    rt.setValue("stdDev", row, stats.stdDev)
    rt.setValue("min", row, stats.min)
    rt.setValue("median", row, median)
    rt.setValue("max", row, stats.max)
    rt.show("Divergence")
    if showPlot:
        plot(divergence, center)
    
def plot(data, center):
    T = list(range(0, len(data)))
    plot = Plot("divergence in (" + str(center[0]) + ", "+ str(center[1])+")", "time[1]", "divergence", T, data)
    plot.show()
    
def calculateDivergencePerTime(vectors, aPoint):
    divergences = []
    for row in vectors:
        newRow = []
        for vector in row:
            newRow.append(proj(vector[1], (vector[0][0]-aPoint[0], vector[0][1]-aPoint[1])))
        divergences.append(sum(newRow)/len(newRow))
    return divergences

def divergenceMapAt(vectors, aTime, width, height):
    vectorsAtTime = vectors[aTime:aTime+1]
    dMap = []
    for x in range(0, width):
        print("divergence map processing row " + str(x+1) + " of " + str(width))
        for y in range(0, height):
            dMap.append(calculateDivergencePerTime(vectors, (x,y))[0])
    image = NewImage.createFloatImage ("divergence map from t=" + str(aTime) + " to t=" + str(aTime), width, height, 1, NewImage.FILL_BLACK)
    image.getProcessor().setPixels(jarray.array(dMap, 'f'))
    image.updateAndDraw()
    return image

def proj(a, b):
    f = dot(a, b) / dot(b, b)
    projAonB = [bi*f for bi in b]
    sign = -1
    if math.copysign(1, b[0]) == math.copysign(1, projAonB[0]):
        sign = 1
    scalarProj = sign * math.sqrt(projAonB[0]**2 + projAonB[1]**2)
    return scalarProj
    
def dot(a, b):
    return sum(x*y for x, y in zip(a, b))

def calculateMedian(aList):
    ranks = Tools.rank(aList)
    if len(ranks) % 2 == 0:
        higherIndex = int(len(ranks)/2) 
        lowerIndex = higherIndex-1
        return (aList[lowerIndex] + aList[higherIndex]) / 2.0
    else:
        return aList[ranks[int(len(ranks)/2)]]
        
def getVectorsFromTable(table, center):
    vectors = []
    headings = list(table.getHeadings())
    tColumn, pIDColumn, xColumn, yColumn = table.getColumn(headings.index('T')),  \
                                           table.getColumn(headings.index('TRACK_ID')), \
                                           table.getColumn(headings.index('X')), \
                                           table.getColumn(headings.index('Y'))
    T = {}
    for t, pID, x, y in zip(tColumn, pIDColumn, xColumn, yColumn):
        T[t] = {pID : (x, y)}
    for t in range(0, len(T.keys())-1):
        row = []
        for pid in T[t].keys():
            x1 = T[t][pid][0] 
            y1 = T[t][pid][1] 
            x2 = T[t+1][pid][0] 
            y2 = T[t+1][pid][1] 
            dx = x2 - x1
            dy = y2 - y1
            row.append(((x1, y1), (dx, dy)))
        vectors.append(row)       
    return vectors
    
if 'getArgument' in globals():
    if not hasattr(zip, '__call__'):
        del zip                     # the python function zip got overriden by java.util.zip, so it must be deleted to get the zip-function to work.
    parameter = getArgument()
    args = parameter.split(",")
    table = args[0].split("=")[1]
    showPlotParam = args[1].split("=")[1]
    showPlot = False
    if showPlotParam=="true":
        showPlot = True
else:
    table = "Tracks"
    showPlot = True
main(table ,showPlot)
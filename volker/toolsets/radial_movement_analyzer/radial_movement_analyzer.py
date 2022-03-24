'''
 Radial movement analyzer. 

(c) 2022, INSERM
written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)

The tool takes a results table of tracking data (as created by Trackmate) and calculates the mean of the scalar projections of the vector of the 
displacement of each particle from one timepoint t to the next t+1, onto the vector from a given point to the coordinates of the particle at timepoint t 

If the particles are moving away from the given point the result will be positive, if they are moving towards the given point the result will be negative.
If neither of the above is the case, the result will be near zero.
'''
from __future__ import division
from ij.measure import ResultsTable
from ij.gui import Plot
from ij.util import Tools
from ij import IJ
from ij.gui import Roi
from ij.gui import NewImage
import jarray
import math 

TABLE_NAME = "Radial Velocity"

def main(tableName, showPlot):
    image = IJ.getImage();
    roi = image.getRoi()
    if not roi:
        center = image.getWidth() / 2, image.getHeight() / 2
    else:
        center = roi.getXBase(), roi.getYBase();
    table = ResultsTable.getResultsTable(tableName)
    vectors = getVectorsFromTable(table, center)
    radialVelocity = calculateRadialVelocityPerTime(vectors, center)
    radialVelocityAndDistanceByTrack(table, center)
    stats = Tools.getStatistics(radialVelocity)
    median = calculateMedian(radialVelocity)
    rt = ResultsTable.getResultsTable(TABLE_NAME)
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
    rt.show(TABLE_NAME)
    if showPlot:
        plot(radialVelocity, center)
    
def plot(data, center):
    T = list(range(0, len(data)))
    plot = Plot("radial velocity in (" + str(center[0]) + ", "+ str(center[1])+")", "time[1]", "radial velocity", T, data)
    plot.show()
    
def calculateRadialVelocityPerTime(vectors, aPoint):
    velocities = []
    for row in vectors:
        newRow = []
        for vector in row:
            magnitude = math.sqrt(vector[1][0]**2 + vector[1][1]**2)
            newRow.append(proj(vector[1], (vector[0][0]-aPoint[0], vector[0][1]-aPoint[1]))/magnitude)
        velocities.append(sum(newRow)/len(newRow))
    return velocities

def radialVelocityAndDistanceByTrack(table, center):
    vectors = []
    headings = list(table.getHeadings())
    tColumn, pIDColumn, xColumn, yColumn = table.getColumn(headings.index('T')),  \
                                           table.getColumn(headings.index('TRACK_ID')), \
                                           table.getColumn(headings.index('X')), \
                                           table.getColumn(headings.index('Y'))    
    trackData = []
    T = {}
    for t, pID, x, y in zip(tColumn, pIDColumn, xColumn, yColumn):
        T[(t, pID)] = (x, y)
    for t, pid in T.keys():
        if t == tColumn[len(tColumn)-1]: 
            continue
        row = []
            
        x1 = T[(t, pid)][0] 
        y1 = T[(t, pid)][1] 
#          print(pid, t, x1, y1)
        x2 = T[(t+1, pid)][0] 
        y2 = T[(t+1, pid)][1] 
        dx = x2 - x1
        dy = y2 - y1
        row.append((pid, (x1, y1), (dx, dy)))
        vectors.append(row)
    print(vectors)
                                               

def radialVelocityMapAt(vectors, aTime, width, height):
    vectorsAtTime = vectors[aTime:aTime+1]
    dMap = []
    for x in range(0, width):
        print("radial velocity map processing row " + str(x+1) + " of " + str(width))
        for y in range(0, height):
            dMap.append(calculateRadialVelocityPerTime(vectors, (x,y))[0])
    image = NewImage.createFloatImage ("radial velocity map from t=" + str(aTime) + " to t=" + str(aTime), width, height, 1, NewImage.FILL_BLACK)
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
        if not pID in T:
            t[pID] = []
        T[pID].append(x, y)
    for t, pid in T.keys():
        if t == tColumn[len(tColumn)-1]: 
            continue
        row = []
            
        x1 = T[(t, pid)][0] 
        y1 = T[(t, pid)][1] 
#          print(pid, t, x1, y1)
        x2 = T[(t+1, pid)][0] 
        y2 = T[(t+1, pid)][1] 
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
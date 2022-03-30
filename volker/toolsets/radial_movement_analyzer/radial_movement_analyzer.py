'''
 Radial movement analyzer. 

(c) 2022, INSERM
written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)

The tool takes a results table of tracking data (as created by Trackmate) and calculates the difference of the distances between the start point and a given point c
and the end point and the given point c, i.e. how much the particle has moved away from c (negative it moved towards c).

If a particle moves away from the given point the result will be positive, if it moves towards the given point the result will be negative.
If neither of the above is the case, the result will be near zero.
'''
from __future__ import division
DEPLOYED = True;
from operator import sub
from ij.measure import ResultsTable
from ij.gui import Plot
from ij.util import Tools
from ij import IJ
from ij.gui import Roi
from ij.gui import NewImage
import jarray
import math 

if not DEPLOYED:
    import unittest, sys

def main(tableName, showPlot):
    image = IJ.getImage();
    roi = image.getRoi()
    if not roi:
        center = image.getWidth() / 2, image.getHeight() / 2
    else:
        center = roi.getXBase(), roi.getYBase();
    table = ResultsTable.getResultsTable(tableName)
    rma = RadialMovementAnalyzer(table, center)
    radialDistances = rma.getDeltaRadialDistancePerTrack()
    distances = rma.getDistances()
    frames = rma.getFrames()
    travelledDistances = rma.getTravelledDistances()
    TABLE_NAME = "Distance from " + str(center)
    rt = ResultsTable.getResultsTable(TABLE_NAME)
    if not rt:
        rt = ResultsTable()
    for index, dist in enumerate(radialDistances):
        row = rt.getCounter()
        rt.setValue("label", row, tableName)
        rt.setValue("track ID", row, rma.trackIDs[index])
        rt.setValue("total augmentation of distance from center", row, dist)
        rt.setValue("distance start to end", row, distances[index])
        rt.setValue("travelled distance", row, travelledDistances[index])
        rt.setValue("nr. of frames", row, frames[index])
        if not distances[index] == 0:
            rt.setValue("total augmentation / distance start to end", row, dist / distances[index])
        else:
            rt.setValue("total augmentation / distance start to end", row, float("nan"))
        if not travelledDistances[index] ==0:
            rt.setValue("total augmentation / travelled distance", row, dist / travelledDistances[index])
        else:
             rt.setValue("total augmentation / travelled distance", row, float("nan"))
        rt.setValue("mean speed", row, travelledDistances[index] / frames[index])
        rt.setValue("mean outward speed", row, dist / frames[index])
        
    rt.show(TABLE_NAME)
    if showPlot:
        plot(distances, radialDistances, center)

def plot(dataX, dataY, center):
    plot = Plot("augmentation of distance from c=(" + str(center[0]) + ", "+ str(center[1])+")", "distance start to end", "augmentation of distance from c", dataX, dataY)
    plot.setStyle(0, "blue,none,1.2,X");
    plot.show()
    
class Vectors:
    @classmethod
    def proj(cls, a, b):
        f = Vectors.dot(a, b) / Vectors.dot(b, b) 
        projAonB = [bi*f for bi in b]
        sign = -1
        if math.copysign(1, b[0]) == math.copysign(1, projAonB[0]):
            sign = 1
        scalarProj = sign * math.sqrt(projAonB[0]**2 + projAonB[1]**2)
        return scalarProj

    @classmethod
    def dot(cls, a, b):
        return sum(x*y for x, y in zip(a, b))

    @classmethod
    def sub(cls, a, b):
        return tuple(map(sub, a, b))

    @classmethod
    def dist(cls, a, b):
        return math.sqrt((a[0]-b[0])**2 + (a[1]-b[1])**2)
        
class RadialMovementAnalyzer:

    timeColumnHeader = 'POSITION_T'
    trackColumnHeader = 'TRACK_ID'
    xColumnHeader = 'POSITION_X'
    yColumnHeader = 'POSITION_Y'
    radialDistances = []
    distances = []
    travelledDistances = []
    frames = []
    
    
    def __init__(self, table, center):
        self.table = table
        self.center = center
        self.tracks, self.timepoints, self.trackIDs = self.getTrackData()
        self.calculateTrackFeatures()
        
    def getTableData(self):
        vectors = []
        headings = list(self.table.getHeadings())
        tColumn = self.table.getColumn(self.timeColumnHeader)
        pIDColumn = self.table.getColumn(self.trackColumnHeader)
        xColumn = self.table.getColumn(self.xColumnHeader)
        yColumn = self.table.getColumn(self.yColumnHeader)    
        indices = [i for i, x in enumerate(pIDColumn) if math.isnan(x)]
        for j in sorted(indices, reverse=True):
            del tColumn[j]
            del pIDColumn[j]
            del xColumn[j]
            del yColumn[j]
        return tColumn, pIDColumn, xColumn, yColumn

    def getDeltaRadialDistancePerTrack(self):
        return self.radialDistances

    def getFrames(self):
        return self.frames

    def getDistances(self):
        return self.distances

    def getTravelledDistances(self):
        return self.travelledDistances
    
    def getTrackData(self):
        tColumn, pIDColumn, xColumn, yColumn = self.getTableData()
        timepoints = list(set(tColumn))
        trackIDs = list(set(pIDColumn))
        timepoints.sort()
        trackIDs.sort()
        T = [[0 for i in xrange(len(timepoints))] for j in xrange(len(trackIDs))]
        for timepoint, trackID, x, y in zip(tColumn, pIDColumn, xColumn, yColumn):
            timepointIndex = timepoints.index(timepoint)
            trackIndex = trackIDs.index(trackID)
            T[trackIndex][timepointIndex] = (x,y)
        return T, timepoints, trackIDs

    def getMeanRadialVelocityPerTrack(self):
        pass

    
    def calculateTrackFeatures(self):
        self.radialDistances = []
        self.distances = []
        self.travelledDistances = []
        self.frames = []
        for track in self.tracks:
            activeTrack = [xoords for xoords in track if not xoords == 0]
            x1, y1 = activeTrack[0]
            x2, y2 = activeTrack[-1]
            dist1 = Vectors.dist((x1, y1), self.center)
            dist2 = Vectors.dist((x2, y2), self.center)
            radialDist = dist2 - dist1
            dist = Vectors.dist((x1, y1), (x2, y2))
            self.radialDistances.append(radialDist)
            self.frames.append(len(activeTrack))
            self.distances.append(dist)
            self.travelledDistances.append(sum([Vectors.dist(x, activeTrack[i+1]) for i,x in enumerate(activeTrack[:-1:])]))
            
if DEPLOYED:
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
else:        
    ###################################################
    # UNIT TESTS
    ###################################################
    class VectorsTest(unittest.TestCase):
        
        def testDot(self):
            res = Vectors.dot((1, 2, 3), (2, 3, 4))
            self.assertEquals(20, res)
    
        def testProj(self):
            res = Vectors.proj((1, 0), (1, 0))
            self.assertEquals(1, res)
            res = Vectors.proj((1, 1), (1, 1))
            self.assertEquals(math.sqrt(2), res)
            
    class RadialMovementAnalyzerTest(unittest.TestCase):
        table = None
    
        def setUp(self):
            unittest.TestCase.setUp(self)
            rt = ResultsTable()
            rt.incrementCounter()
            rt.addLabel('LABEL', 'ID00002')
            rt.addValue('ID', 2)
            rt.addValue('TRACK_ID', 2)
            rt.addValue('QUALITY', 1)
            rt.addValue('POSITION_X', 738.9)
            rt.addValue('POSITION_Y', 670.0)
            rt.addValue('POSITION_Z', 0)
            rt.addValue('POSITION_T', 0)
            rt.incrementCounter()
            rt.addLabel('LABEL', 'ID00003')
            rt.addValue('ID', 3)
            rt.addValue('TRACK_ID', 3)
            rt.addValue('QUALITY', 1)
            rt.addValue('POSITION_X', 672.1)
            rt.addValue('POSITION_Y', 729.3)
            rt.addValue('POSITION_Z', 0)
            rt.addValue('POSITION_T', 0)
            rt.incrementCounter()
            rt.addLabel('LABEL', 'ID00001')
            rt.addValue('ID', 31)
            rt.addValue('TRACK_ID', 1)
            rt.addValue('QUALITY', 1)
            rt.addValue('POSITION_X', 953.2)
            rt.addValue('POSITION_Y', 803.5)
            rt.addValue('POSITION_Z', 0)
            rt.addValue('POSITION_T', 1)
            rt.incrementCounter()
            rt.addLabel('LABEL', 'ID000032')
            rt.addValue('ID', 32)
            rt.addValue('TRACK_ID', 2)
            rt.addValue('QUALITY', 1)
            rt.addValue('POSITION_X', 739.5)
            rt.addValue('POSITION_Y', 665.0)
            rt.addValue('POSITION_Z', 0)
            rt.addValue('POSITION_T', 1)
            rt.incrementCounter()
            rt.addLabel('LABEL', 'ID000033')
            rt.addValue('ID', 33)
            rt.addValue('TRACK_ID', 3)
            rt.addValue('QUALITY', 1)
            rt.addValue('POSITION_X', 667.0)
            rt.addValue('POSITION_Y', 729.8)
            rt.addValue('POSITION_Z', 0)
            rt.addValue('POSITION_T', 1)
            rt.incrementCounter()
            rt.addLabel('LABEL', 'ID000061')
            rt.addValue('ID', 61)
            rt.addValue('TRACK_ID', 1)
            rt.addValue('QUALITY', 1)
            rt.addValue('POSITION_X', 959.0)
            rt.addValue('POSITION_Y', 805.5)
            rt.addValue('POSITION_Z', 0)
            rt.addValue('POSITION_T', 2)
            self.table = rt
            
        def testConstructor(self):
            rma = RadialMovementAnalyzer(self.table, (800,800))
            self.assertEquals(self.table, rma.table)
    
        def testGetTableData(self):
            rma = RadialMovementAnalyzer(self.table, (800,800))
            tColumn, pIDColumn, xColumn, yColumn = rma.getTableData()
            self.assertEquals(0, tColumn[0])
            self.assertEquals(2, tColumn[5])
            self.assertEquals(2, pIDColumn[0])
            self.assertEquals(1, pIDColumn[5])
    
        def testGetTrackData(self):
            rma = RadialMovementAnalyzer(self.table, (800,800))
            data, _, _ = rma.getTrackData()
            self.assertEquals(3, len(data))
            self.assertEquals(3, len(data[0]))
            self.assertEquals(3, len(data[1]))
            self.assertEquals(3, len(data[2]))
            self.assertEquals(0, data[0][0]) 
            self.assertEquals(0, data[1][2])
            self.assertEquals(0, data[2][2])
    
        def testGetDeltaRadialDistancePerTrack(self):
            rma = RadialMovementAnalyzer(self.table, (800,800))
            distances = rma.getDeltaRadialDistancePerTrack()
            self.assertEquals(3, len(distances))
            
    def suite():
        suite = unittest.TestSuite()
        suite.addTest(VectorsTest('testDot'))
        suite.addTest(VectorsTest('testProj'))
        suite.addTest(RadialMovementAnalyzerTest('testConstructor'))
        suite.addTest(RadialMovementAnalyzerTest('testGetTableData'))
        suite.addTest(RadialMovementAnalyzerTest('testGetTrackData'))
        suite.addTest(RadialMovementAnalyzerTest('testGetDeltaRadialDistancePerTrack'))
        return suite
        
    runner = unittest.TextTestRunner(sys.stdout, verbosity=1)
    runner.run(suite())
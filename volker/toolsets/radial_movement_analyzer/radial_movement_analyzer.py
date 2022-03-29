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

TABLE_NAME = "Distance from center"

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
    distances = rma.getDeltaDistancePerTrack()
    rt = ResultsTable.getResultsTable(TABLE_NAME)
    if not rt:
        rt = ResultsTable()
    for index, dist in enumerate(distances):
        row = rt.getCounter()
        rt.setValue("label", row, tableName)
        rt.setValue("track ID", row, rma.trackIDs[index])
        rt.setValue("total augmentation of distance from center", row, dist)
    rt.show(TABLE_NAME)
    if showPlot:
        plot(distances, center)

def plot(data, center):
    T = list(range(0, len(data)))
    plot = Plot("augmentation of distance from (" + str(center[0]) + ", "+ str(center[1])+")", "track nr", "distance", T, data)
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

    timeColumnHeader = 'T'
    trackColumnHeader = 'TRACK_ID'
    xColumnHeader = 'X'
    yColumnHeader = 'Y'

    def __init__(self, table, center):
        self.table = table
        self.center = center
        self.tracks, self.timepoints, self.trackIDs = self.getTrackData()
        
    def getTableData(self):
        vectors = []
        headings = list(self.table.getHeadings())
        tColumn = self.table.getColumn(self.timeColumnHeader)
        pIDColumn = self.table.getColumn(self.trackColumnHeader)
        xColumn = self.table.getColumn(self.xColumnHeader)
        yColumn = self.table.getColumn(self.yColumnHeader)    
        return tColumn, pIDColumn, xColumn, yColumn

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
    
    def getDeltaDistancePerTrack(self):
        distances = []
        for track in self.tracks:
            activeTrack = [xoords for xoords in track if not xoords == 0]
            print(activeTrack)
            x1, y1 = activeTrack[0]
            x2, y2 = activeTrack[-1]
            distStart = Vectors.dist((x1, y1), self.center)
            distEnd = Vectors.dist((x2, y2), self.center)
            dist = distEnd - distStart
            distances.append(dist)
        return distances
            
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
            rt.addValue('X', 738.9)
            rt.addValue('Y', 670.0)
            rt.addValue('Z', 0)
            rt.addValue('T', 0)
            rt.incrementCounter()
            rt.addLabel('LABEL', 'ID00003')
            rt.addValue('ID', 3)
            rt.addValue('TRACK_ID', 3)
            rt.addValue('QUALITY', 1)
            rt.addValue('X', 672.1)
            rt.addValue('Y', 729.3)
            rt.addValue('Z', 0)
            rt.addValue('T', 0)
            rt.incrementCounter()
            rt.addLabel('LABEL', 'ID00001')
            rt.addValue('ID', 31)
            rt.addValue('TRACK_ID', 1)
            rt.addValue('QUALITY', 1)
            rt.addValue('X', 953.2)
            rt.addValue('Y', 803.5)
            rt.addValue('Z', 0)
            rt.addValue('T', 1)
            rt.incrementCounter()
            rt.addLabel('LABEL', 'ID000032')
            rt.addValue('ID', 32)
            rt.addValue('TRACK_ID', 2)
            rt.addValue('QUALITY', 1)
            rt.addValue('X', 739.5)
            rt.addValue('Y', 665.0)
            rt.addValue('Z', 0)
            rt.addValue('T', 1)
            rt.incrementCounter()
            rt.addLabel('LABEL', 'ID000033')
            rt.addValue('ID', 33)
            rt.addValue('TRACK_ID', 3)
            rt.addValue('QUALITY', 1)
            rt.addValue('X', 667.0)
            rt.addValue('Y', 729.8)
            rt.addValue('Z', 0)
            rt.addValue('T', 1)
            rt.incrementCounter()
            rt.addLabel('LABEL', 'ID000061')
            rt.addValue('ID', 61)
            rt.addValue('TRACK_ID', 1)
            rt.addValue('QUALITY', 1)
            rt.addValue('X', 959.0)
            rt.addValue('Y', 805.5)
            rt.addValue('Z', 0)
            rt.addValue('T', 2)
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
            print(data)
            self.assertEquals(3, len(data))
            self.assertEquals(3, len(data[0]))
            self.assertEquals(3, len(data[1]))
            self.assertEquals(3, len(data[2]))
            self.assertEquals(0, data[0][0]) 
            self.assertEquals(0, data[1][2])
            self.assertEquals(0, data[2][2])
    
        def testGetDeltaDistancePerTrack(self):
            rma = RadialMovementAnalyzer(self.table, (800,800))
            distances = rma.getDeltaDistancePerTrack()
            print(distances)
            self.assertEquals(3, len(distances))
            
    def suite():
        suite = unittest.TestSuite()
        suite.addTest(VectorsTest('testDot'))
        suite.addTest(VectorsTest('testProj'))
        suite.addTest(RadialMovementAnalyzerTest('testConstructor'))
        suite.addTest(RadialMovementAnalyzerTest('testGetTableData'))
        suite.addTest(RadialMovementAnalyzerTest('testGetTrackData'))
        suite.addTest(RadialMovementAnalyzerTest('testGetDeltaDistancePerTrack'))
        return suite
        
    runner = unittest.TextTestRunner(sys.stdout, verbosity=1)
    runner.run(suite())
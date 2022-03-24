from __future__ import division
DEPLOYED = False;
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

class RadialMovementAnalyzer:

    timeColumnHeader = 'T'
    trackColumnHeader = 'TRACK_ID'
    xColumnHeader = 'X'
    yColumnHeader = 'Y'

    def __init__(self, table, center):
        self.table = table
        self.center = center
        
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
        T = {}
        timepoints = list(set(tColumn))
        trackIDs = list(set(pIDColumn))
        timepoints.sort()
        trackIDs.sort()
        T = [[0 for i in xrange(len(timepoints))] for j in xrange(len(trackIDs))]
        for timepoint, trackID, x, y in zip(tColumn, pIDColumn, xColumn, yColumn):
            timepointIndex = timepoints.index(timepoint)
            trackIndex = trackIDs.index(trackID)
            T[trackIndex][timepointIndex] = (x,y)
        return T

    def getMeanRadialVelocityPerTrack(self):
        pass
    
    def getTotalRadialDistancePerTrack(self)
        pass
        
###################################################
# UNIT TESTS
###################################################
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

    def getTrackData(self):
        rma = RadialMovementAnalyzer(self.table, (800,800))
        data = rma.getTrackData()
        print(data)
        self.assertEquals(3, len(data))
        self.assertEquals(3, len(data[0]))
        self.assertEquals(3, len(data[1]))
        self.assertEquals(3, len(data[2]))
        self.assertEquals(0, data[0][0]) 
        self.assertEquals(0, data[1][2])
        self.assertEquals(0, data[2][2])
        
def suite():
    suite = unittest.TestSuite()
    suite.addTest(RadialMovementAnalyzerTest('testConstructor'))
    suite.addTest(RadialMovementAnalyzerTest('testGetTableData'))
    suite.addTest(RadialMovementAnalyzerTest('getTrackData'))
    return suite
    
runner = unittest.TextTestRunner(sys.stdout, verbosity=1)
runner.run(suite())
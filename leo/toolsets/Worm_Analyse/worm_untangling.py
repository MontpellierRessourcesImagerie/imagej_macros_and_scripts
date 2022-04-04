from ij import IJ
from ij.plugin.frame import RoiManager
from ij.gui import Roi , PolygonRoi
from ij.measure import ResultsTable


def main(args):
    untangler = WormUntangler()
    if args[0] == "Untangle":
        untangler.untangle()
    if args[0] == "Populate":
        untangler.populate()
    if args[0] == "Enumerate":
        untangler.enumerate()
    if args[0] == "Prune":
        untangler.prune()
    if args[0] == "Evaluate":
        untangler.evaluate()
    if args[0] == "Define?": #TODO Change this option code
        untangler.define()
    print("Python Call Ended !!")

class WormUntangler(object):
    def __init__(self, args=None):
        self.segments = []
        self.nodes = []
        self.paths = []
        if args:
            pass
            #parser = getArgumentParser()
            #self.options = parser.parse_args(args)
            #self.configureFromOptions()

    def untangle(self):
        self.initialize()
        self.doPathEnumeration()
        self.buildPathTable("pathsTable")
        orphans = self.getOrphanSegments()
        self.removeOrphans(orphans)
        print("Untangle Worms : Not Yet Implemented !")
        
    def populate(self):
        self.initialize()
        self.displayTextualGraph()
        
    def enumerate(self):
        self.initialize()
        self.doPathEnumeration(verbose=True)
        self.buildPathTable("pathsTable")
        
        
    def prune(self):
        self.initialize()
        self.doPathEnumeration()
        self.buildPathTable("pathsTable")
        orphans = self.getOrphanSegments()
        self.removeOrphans(orphans)
        
    def evaluate(self):
        self.initialize()
        self.doPathEnumeration()
        self.buildPathTable("pathsTable")
        orphans = self.getOrphanSegments()
        self.removeOrphans(orphans)
        self.evaluatePaths()
        
        print("Evaluate Path Locally : Not Yet Implemented !")
        pass
        
    def define(self):
        self.initialize()
        self.doPathEnumeration()
        self.buildPathTable("pathsTable")
        orphans = self.getOrphanSegments()
        self.removeOrphans(orphans)
        print("Evaluate Path Locally : Not Yet Implemented !")
        print("Define Best Path Configuration : Not Yet Implemented !")
        pass

    def initialize(self):
        self.initLists()
        self.populateSegments()
        self.populateNodes()

    def initLists(self):
        self.segments = []
        self.nodes = []
    
    def populateSegments(self):
        roiManager = RoiManager.getRoiManager()
        for roi in roiManager:
            seg = Segment()
            seg.setRoi(roi)
            self.segments.append(seg)

    def populateNodes(self):
        nodesTable = ResultsTable.getResultsTable("nodesTable")
        for i in range(nodesTable.size()):
            node = Node()
            node.setID(nodesTable.getStringValue("Node ID", i))
            node.setX(nodesTable.getValue("X", i))
            node.setY(nodesTable.getValue("Y", i))
            nbContact = nodesTable.getValue("Nb Contact", i)
            for column in range(1,int(nbContact)+1):
                currentContact = nodesTable.getStringValue("C"+str(column), i)
                for segment in self.segments:
                    if str(segment.ID) == currentContact:
                        node.addSegment(segment)
                        segment.addNode(node)
            self.nodes.append(node)
            
    def displayTextualGraph(self):
        for seg in self.segments:
            print(str(seg)+"=>"+seg.stringNodes())
    
    def doPathEnumeration(self,debug=False,verbose=False):
        validPaths = []
        for s in self.segments:
            #print("Starting path Evaluation of segment"+ str(s))
            currentPaths = self.getPossiblePaths(Path(s),debug,verbose)
            if currentPaths is not None:
                if type(currentPaths) is not type(validPaths):
                    validPaths.append(currentPaths)
                else:
                    for path in currentPaths:
                        validPaths.append(path)
        #print("-----")
        #print(str(len(validPaths)) + " paths found !")
        
        validPaths = self.removeDuplicatePaths(validPaths)
        validPaths = self.reorderSegmentsInPaths(validPaths)
        
        print("-----")
        print(str(len(validPaths)) + " paths found !")
        
        self.paths = validPaths
        return validPaths
    
    def removeDuplicatePaths(self, pathList, verbose=False):
        for p in pathList:
            firstIDString = p.getIDSortedString()
            if verbose:
                print(firstIDString)
            firstOne = True
            for p2 in pathList:
                if verbose:
                    print(p2.getIDSortedString()+"?=="+firstIDString)
                if p2.getIDSortedString() == firstIDString:
                    if firstOne:
                        firstOne = False
                        if verbose:
                            print("Is First")
                    else:
                        if verbose:
                            print("Duplicate Removed")
                        pathList.remove(p2)
        return pathList
        
    def reorderSegmentsInPaths(self, pathList, verbose=False):
        for p in pathList:
            if verbose:
                print("in : "+ str([str(s) for s in p.segments]))
            p.reorderSegments()
            if verbose:
                print("out : "+ str([str(s) for s in p.segments]))
        return pathList
        
    def buildPathTable(self,tableName):
        table = ResultsTable()
        for index, p in enumerate(self.paths):
            p.addToResultTable(table,index)
        table.show(tableName)
        
    def getOrphanSegments(self):
        paths = self.paths
        orphans = []
        for s in self.segments:
            orphan = True
            for p in paths:
                
                if s in p.segments:
                    orphan = False
            if orphan:
                orphans.append(s)
        return orphans
        
    def removeOrphans(self, orphans,debug=False,verbose=False):
        rm = RoiManager.getRoiManager()
        
        for o in orphans:
            if o in self.segments:
                if verbose:
                    print("Orphan "+o.ID+" removed!")
                self.segments.remove(o);
                for index in range(0,rm.getCount()-1):
                    if rm.getName(index) == o.ID:
                        break
                
                rm.select(index)
                rm.runCommand("Delete")
                
        for n in self.nodes:
            for o in orphans:
                if o in n.getSegments():
                    n.removeSegment(o)
                
            if len(n.getSegments()) == 0:
                self.nodes.remove(n)
                for s in self.segments:
                    if n in s.getNodes():
                        s.removeNode(n)
            
    def getPossiblePaths(self,path,debug=False,verbose=False):
        validPath = []
        if debug:
            print("Evaluating path "+ str(path) + "!")
        if path is None:
            print("None Path")
            return
            
        if path.isTooLong():
            if debug:
                print("Too Long")
            return None
            
        if not path.isTooShort():
            if verbose:
                print("Adding path "+ str(path) + "to Valid Paths")
            validPath.append(path)
            
        for segment in path.filteredGetNeighbors():
            recursivePath = self.getPossiblePaths(path.createCombinedPath(segment),debug,verbose)
            if recursivePath is None:
                continue
            elif type(recursivePath) is not type(validPath):
                validPath.append(recursivePath)
            else:
                for insidePath in recursivePath:
                    if insidePath is not None:
                        validPath.append(insidePath)
        if len(validPath) == 0:
            return None
        return validPath
        
    def evaluatePaths(self):
        for p in self.paths[:2]:
            cost = p.evaluateShapeCost()
           
        print("Path evaluation was only done on the first two paths for testing purpose")

class Path():
    minWormLength = 450
    maxWormLength = 750
    
    def __init__(self,args=None):
        self.segments = None
        if args is not None:
            self.addSegment(args)
    
    def addSegment(self,seg):
        if self.segments is None:
            self.segments = [seg]
        else:
            self.segments.append(seg)
    
    def getLength(self):
        totalLength = 0
        for s in self.segments:
            totalLength = totalLength + s.getLength()
        return totalLength
    
    def isTooShort(self):
        if self.getLength() < self.minWormLength:
            return True
        return False
        
    def isTooLong(self):
        if self.getLength() > self.maxWormLength:
            #print(self.getLength())
            return True
        return False
        
    def filteredGetNeighbors(self):
        neighborsSegments = []
        neighborsNodes = []
        firstSegmentID = self.segments[0].getIDNumber()
        for s in self.segments:
            currentNodes = s.getNodes()
            if currentNodes is None:
                continue
            for node in currentNodes:
                if node not in neighborsNodes:
                    neighborsNodes.append(node)
                else:
                    neighborsNodes.remove(node)
        
        for n in neighborsNodes:
            currentSegments = n.getSegments()
            for segment in currentSegments:
                if segment.getIDNumber() <= firstSegmentID:
                    continue
                if segment not in neighborsSegments and segment not in self.segments:
                    neighborsSegments.append(segment)
        
        return neighborsSegments
        
    def createCombinedPath(self,segment):
        newPath = Path()
        for s in self.segments:
            newPath.addSegment(s)
        newPath.addSegment(segment)
        return newPath
    
        
    def reorderSegments(self):
        newSegments = [self.segments[0]]
        for s in self.segments:
            if s in newSegments:
                continue
            if newSegments is None:
                newSegments = [self.segments[0]]
            else:
                if s.getContactNode(newSegments[-1]) is not None:
                    newSegments.append(s)
        newSegments.reverse()
        for s in self.segments:
            if s in newSegments:
                continue
            if s.getContactNode(newSegments[-1]) is not None:
                newSegments.append(s)
        self.segments = newSegments
        
    def evaluateShapeCost(self):
        xPoints,yPoints = self.getLine()
        newRoi = PolygonRoi(xPoints, yPoints, Roi.POLYLINE)
        newRoi.fitSpline(100)
        rm = RoiManager.getRoiManager()
        rm.addRoi(newRoi)
    
    def getLine(self):
        xPoints = []
        yPoints = []
        for i in range(len(self.segments) - 1):
            startSegment=self.segments[i]
            endSegment=self.segments[i + 1]
            sPointsX,sPointsY = startSegment.getPointsUntil(endSegment)
            xPoints = xPoints + sPointsX
            yPoints = yPoints + sPointsY
        sPointsX,sPointsY = endSegment.getPointsFrom(startSegment)
        xPoints = xPoints + sPointsX
        yPoints = yPoints + sPointsY
        return (xPoints,yPoints)
        
    def addToResultTable(self,table,index):
        table.setValue("Path ID", index, "P-"+str(index))
        table.setValue("Number of Segments", index, len(self.segments))
        table.setValue("Length", index, self.getLength())
        for i,segment in enumerate(self.segments):
            table.setValue("S_"+str(i), index, str(segment))
        
    def getIDSortedString(self):
        ID = []
        for s in self.segments:
            ID.append(s.getIDNumber())
        ID.sort()
        return str(ID)
    
    def __str__(self):
        string = ""
        for s in self.segments:
            string = string + str(s) + " "
        return string

class Segment():

    def __init__(self,args=None):
        self.ID = None
        self.roi = None
        self.nodesInContact = None
        
    def setRoi(self,inputRoi):
        self.roi = inputRoi
        self.ID = inputRoi.getName()
    
    def addNode(self, inputNode):
        if self.nodesInContact is None:
            self.nodesInContact = []
        self.nodesInContact.append(inputNode)
        
    def removeNode(self, inputNode):
        self.nodesInContact.remove(inputNode)
    
    def getLength(self):
        if self.roi is None:
            print("Undefined ROI in Segment")
            return
        return self.roi.getLength()
    
    def getNodes(self):
        if self.nodesInContact is None:
            print("Undefined Nodes in Segment")
        return self.nodesInContact
        
    def getPointsUntil(self,otherSegment):
        contactNode = self.getContactNode(otherSegment)
        if contactNode is None:
            print("No Contact Nodes")
            return
        
        xPoints, yPoints = self.getPointsCloserToNode(contactNode)
        return (xPoints, yPoints)
        
    def getPointsFrom(self,otherSegment):
        xPoints,yPoints = self.getPointsUntil(otherSegment)
        xPoints.reverse()
        yPoints.reverse()
        return (xPoints,yPoints)
    
    def getContactNode(self,otherSegment):
        otherNodes = otherSegment.getNodes()
        selfNodes = self.getNodes()
        node = None
        for n in selfNodes:
            if n in otherNodes:
                node = n
                break
        
        if node is not None:
            print(str(node)+ " is the contact point between "+str(self)+" and "+str(otherSegment))
        return node
    
    def getPoints(self):
        inPolygon = self.roi.getPolygon()
        xPoints = inPolygon.xpoints.tolist()
        yPoints = inPolygon.ypoints.tolist()
        return (xPoints,yPoints)
    
    def getPointsReverse(self):
        xPoints,yPoints = self.getPoints()
        xPoints.reverse()
        yPoints.reverse()
        return (xPoints,yPoints)
        
    def getPointsCloserToNode(self, node):
    
        if node not in self.getNodes():
            print("Node "+str(node)+" isn't at one end of the segment "+str(self)+" !")
            return None
        
        polygon = self.roi.getPolygon()
        
        firstPointX = polygon.xpoints[0]
        firstPointY = polygon.ypoints[0]
        lastPointX = polygon.xpoints[-1]
        lastPointY = polygon.ypoints[-1]
        
        distanceToFirstPoint = abs(node.xCoord - firstPointX) + abs(node.yCoord - firstPointY)
        distanceToLastPoint = abs(node.xCoord - lastPointX) + abs(node.yCoord - lastPointY)
        if distanceToFirstPoint <= distanceToLastPoint:
            
            return self.getPointsReverse()
        else:
            return self.getPoints()
        
    def stringNodes(self):
        output = ""
        for node in self.getNodes():
            output = output + str(node) + " "
        return output

    def getIDNumber(self):
        return int(self.ID[2:])

    def __str__(self):
        return str(self.ID)

class Node():
    
    def __init__(self,args=None):
        self.ID = None
        self.xCoord = -1
        self.yCoord = -1
        self.segmentsInContact = []
        
    def setID(self,inputID):
        self.ID = inputID
        
    def setX(self,inputX):
        self.xCoord = inputX
        
    def setY(self,inputY):
        self.yCoord = inputY
        
    def addSegment(self, inputSegment):
        if self.segmentsInContact is None:
            self.segmentsInContact = []
        self.segmentsInContact.append(inputSegment)
    
    def removeSegment(self, inputSegment):
        self.segmentsInContact.remove(inputSegment)
    
    def getX(self):
        return self.xCoord
        
    def getY(self):
        return self.yCoord
    
    def getCoordString(self):
        return "[" + str(self.xCoord) + ";" + str(self.yCoord) + "]"
    
    def __str__(self):
        return str(self.ID)
        
    def getSegments(self):
        if self.segmentsInContact is None:
            print("Undefined Segments in Node")
        return self.segmentsInContact

#main(None)
if 'getArgument' in globals():
    if not hasattr(zip, '__call__'):
        del zip                     # the python function zip got overriden by java.util.zip, so it must be deleted to get the zip-function to work.
    args = getArgument()
    args = " ".join(args.split())
    print(args.split())
    main(args.split())
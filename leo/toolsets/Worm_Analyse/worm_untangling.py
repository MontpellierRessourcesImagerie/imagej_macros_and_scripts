from ij import IJ
from ij.plugin.frame import RoiManager
from ij.gui import Roi , PolygonRoi
from ij.measure import ResultsTable


def main(args):
    untangler = WormUntangler()
    if args[0] == "Untangle":
        untangler.launch()
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
        
    print("Python Call Ended !!");

class WormUntangler(object):
    def __init__(self, args=None):
        self.segments = []
        self.nodes = []
        if args:
            pass
            #parser = getArgumentParser()
            #self.options = parser.parse_args(args)
            #self.configureFromOptions()

    def launch(self):
        self.initLists()
        self.populateSegments()
        self.populateNodes()
        #self.convertSegmentsROIToPolyline()
        possiblePaths = self.doPathEvaluation()
        orphans = self.getOrphanSegments(possiblePaths)
        self.removeOrphans(orphans)
        #possiblePaths[0].getContainedPoints()

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
            node.setY(nodesTable.getValue("X", i))
            nbContact = nodesTable.getValue("Nb Contact", i)
            for column in range(1,int(nbContact)+1):
                currentContact = nodesTable.getStringValue("C"+str(column), i)
                for segment in self.segments:
                    if str(segment.ID) == currentContact:
                        node.addSegment(segment)
                        segment.addNode(node)
            self.nodes.append(node)
    
    def convertSegmentsROIToPolyline(self):
        for s in self.segments:
            s.makeRoiIntoLine()
            
            
    def displayTextualGraph(self):
        for seg in self.segments:
            print(str(seg)+"=>"+seg.stringNodes())
    
    def doPathEvaluation(self,debug=False,verbose=False):
        validPaths = []
        for s in self.segments:
            #print("Starting path Evaluation of segment"+ str(s))
            currentPaths = self.evaluatePathRecursively(Path(s),debug,verbose)
            if currentPaths is not None:
                if type(currentPaths) is not type(validPaths):
                    validPaths.append(currentPaths)
                else:
                    for path in currentPaths:
                        validPaths.append(path)
        print("-----")
        print(str(len(validPaths)) + " paths found !")
        return validPaths
        
    def getOrphanSegments(self, paths):
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
            
    def evaluatePathRecursively(self,path,debug=False,verbose=False):
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
            recursivePath = self.evaluatePathRecursively(path.createCombinedPath(segment),debug,verbose)
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
    
    def populate(self):
        self.initLists()
        self.populateSegments()
        self.populateNodes()
        #self.convertSegmentsROIToPolyline()
        self.displayTextualGraph()
        
    def enumerate(self):
        self.initLists()
        self.populateSegments()
        self.populateNodes()
        #self.convertSegmentsROIToPolyline()
        possiblePaths = self.doPathEvaluation(verbose=True)
        
    def prune(self):
        self.initLists()
        self.populateSegments()
        self.populateNodes()
        #self.convertSegmentsROIToPolyline()
        possiblePaths = self.doPathEvaluation()
        orphans = self.getOrphanSegments(possiblePaths)
        self.removeOrphans(orphans,verbose=True)
        
    def evaluate(self):
        pass
        
    def define(self):
        pass

class Path():
    minWormLength = 450
    maxWormLength = 800
    
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
        
    def obsoleteGetNeighbors(self):
        neighborsSegments = []
        neighborsNodes = []
        for s in self.segments:
            currentNodes = s.getNodes()
            for node in currentNodes:
                if node not in neighborsNodes:
                    neighborsNodes.append(node)
                else:
                    neighborsNodes.remove(node)
        
        for n in neighborsNodes:
            currentSegments = n.getSegments()
            for segment in currentSegments:
                if segment not in neighborsSegments and segment not in self.segments:
                    neighborsSegments.append(segment)
        
        return neighborsSegments
        
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
        
    def getContainedPoints(self):
        containedPoints = []
        for s in self.segments:
            print(s.roi.size())
            containedPoints.append(s.roi.getContainedPoints())
        print(containedPoints)
        
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
        #print("roi Name:"+str(self.ID))
        #print("roi Size:"+str(self.roi.size()))
        #print("roi getLength/2:"+str(self.roi.getLength()/2))
        #print("roi nCoordinates:"+str(self.roi.getNCoordinates()))
        return self.roi.getLength()
    
    def getNodes(self):
        if self.nodesInContact is None:
            print("Undefined Nodes in Segment")
        return self.nodesInContact
    
    def stringNodes(self):
        output = ""
        for node in self.getNodes():
            output = output + str(node) + " "
        return output
        
    def makeRoiIntoLine(self):
        rm = RoiManager.getRoiManager()
        polygon = self.roi.getPolygon()
        print(str(self.roi.getType()) + " ?= " + str(Roi.POLYLINE))
        if self.roi.getType() == Roi.POLYLINE:
            print("Roi Polyline !!")
            newRoi = PolygonRoi(polygon.xpoints.tolist(),polygon.ypoints.tolist(),Roi.POLYLINE)
        else:
            print("Roi Not Polyline")
            nodes = self.getNodes()
            idx = self.getIndexOfPointCloserToNode(nodes[0])
            newRoi = PolygonRoi(polygon.xpoints[idx:idx+polygon.npoints/2].tolist(),polygon.ypoints[idx:idx+polygon.npoints/2].tolist(),Roi.POLYLINE)
            
        rm.setRoi(newRoi,self.getIDNumber())
        #self.roi.update(False,False)
        #rm.add(newRoi,self.getIDNumber())
        #index = rm.getRoiIndex(newRoi)
        
        #rm.rename(rm.getCount()-1,self.ID)
        
        #rm.select(0)
        #rm.runCommand("Delete")
        self.roi = newRoi
        
    def getIndexOfPointCloserToNode(self,node):
        return 0
        nodeX = node.getX()
        nodeY = node.getY()
        polygon = self.roi.getPolygon()
        closestDistance = 100
        closestIndex = -1
        for index,x,y in enumerate(zip(polygon.xpoints,polygon.ypoints)):
            distance = abs(x-nodeX) + abs(y-nodeY)
            if distance < closestDistance:
                closestDistance = distance
            print(str(x)+";"+str(y))
        
        return 0

    def getIDNumber(self):
        return int(self.ID[2:])

    def __str__(self):
        return str(self.ID)

class Node():
    
    def __init__(self,args=None):
        self.ID = None
        self.xCoord = -1
        self.yCoord = -1
        self.segmentsInContact = None
        
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
from ij import IJ
from ij.plugin.frame import RoiManager
from ij.gui import Roi
from ij.measure import ResultsTable


def main(args):
    untangler = WormUntangler(args)
    untangler.launch()

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
        self.displayTextualGraph()
        self.segments[0].getArea()

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
            nodeID = nodesTable.getStringValue("Node ID", i)
            node.setID(nodeID)
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
    
    def getArea(self):
        if self.roi is None:
            print("Undefined ROI in Segment")
            return
        #print("roi Size:"+str(self.roi.size())) #Count the number of points in the ROI
        return self.roi.size()
    
    def getNodes(self):
        if self.nodesInContact is None:
            print("Undefined Nodes in Segment")
        return self.nodesInContact
    
    def stringNodes(self):
        output = ""
        for node in self.getNodes():
            output = output + str(node) + " "
        return output
        
    def __str__(self):
        return str(self.ID)

class Node():
    
    def __init__(self,args=None):
        self.ID = None
        self.segmentsInContact = None
        
    def setID(self,inputID):
        self.ID = inputID
        
    def addSegment(self, inputSegment):
        if self.segmentsInContact is None:
            self.segmentsInContact = []
        self.segmentsInContact.append(inputSegment)
    
    def __str__(self):
        return str(self.ID)
        
    def getSegments(self):
        if self.segmentsInContact is None:
            print("Undefined Segments in Node")
        return self.segmentsInContact


main(None)
if 'getArgument' in globals():
    if not hasattr(zip, '__call__'):
        del zip                     # the python function zip got overriden by java.util.zip, so it must be deleted to get the zip-function to work.
    args = getArgument()
    args = " ".join(args.split())
    print(args.split())
    main(args.split())
    sys.exit(0)
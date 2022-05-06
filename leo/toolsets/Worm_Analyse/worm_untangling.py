from ij import IJ
from ij.plugin.frame import RoiManager
from ij.gui import Roi, PolygonRoi, Plot
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
    if args[0] == "GlobalEvaluate":
        untangler.globalEvaluate()
    if args[0] == "Define?":  # TODO Change this option code
        untangler.define()
    if args[0] == "Test":
        untangler.test()
    print("Python Call Ended !!")


class WormUntangler(object):
    def __init__(self, args=None):
        self.segments = []
        self.nodes = []
        self.paths = []
        if args:
            pass
            # parser = getArgumentParser()
            # self.options = parser.parse_args(args)
            # self.configureFromOptions()

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
        print("Initialization Finished!")
        self.doPathEnumeration()
        print("Path Enumeration Finished!")
        self.buildPathTable("pathsTable")
        print("Path Table Construction Finished!")
        self.evaluatePaths()
        print("Path Evaluation Finished!")
        self.filterPaths()
        print("Path Filtration Finished!")
        orphans = self.getOrphanSegments()
        self.removeOrphans(orphans)

    def globalEvaluate(self):
        self.initialize()
        print("Initialization Finished!")
        self.doPathEnumeration()
        print("Path Enumeration Finished!")
        self.buildPathTable("pathsTable")
        print("Path Table Construction Finished!")
        self.evaluatePaths()
        print("Path Evaluation Finished!")
        self.filterPaths()
        print("Path Filtration Finished!")
        orphans = self.getOrphanSegments()
        self.removeOrphans(orphans)
        self.calculateCostsUntilLevel(7)

        print("Evaluate Path Globally : Not Yet Finished !")

    def define(self):
        self.initialize()
        self.doPathEnumeration()
        self.buildPathTable("pathsTable")
        orphans = self.getOrphanSegments()
        self.removeOrphans(orphans)
        self.evaluatePaths()
        print("Define Best Path Configuration : Not Yet Implemented !")

    def test(self):
        pass

    def calculateCostsUntilLevel(self, level):
        previousCandidates = []
        lastBestScore = 3.1
        for i in range(1, level + 1):
            (previousCandidates, lastBestScore) = self.calculateCostsOneLevel(
                i, previousCandidates, lastBestScore
            )

    def calculateCostsOneLevel(self, level=1, previousCandidates=None, bestScore=3.1):
        print("Calculating Costs of Path with depth " + str(level))
        # Create the PathList of Level level
        (pathLists, innateCosts, overlapCosts, leftoverCosts) = self.generatePathLists(
            level, previousCandidates, bestScore
        )

        table = ResultsTable()
        minTotalCost = 3
        for pathListIndex, pathList in enumerate(pathLists, start=0):
            totalCost = (
                innateCosts[pathListIndex]
                + overlapCosts[pathListIndex]
                + leftoverCosts[pathListIndex]
            )
            minTotalCost = min(totalCost, minTotalCost)
            for pathIndex, path in enumerate(pathList):
                table.setValue(
                    "Path " + str(pathIndex), pathListIndex, "P-" + str(path.getID())
                )
            table.setValue("Innate Cost", pathListIndex, innateCosts[pathListIndex])
            table.setValue("Overlap Cost", pathListIndex, overlapCosts[pathListIndex])
            table.setValue("Leftover Cost", pathListIndex, leftoverCosts[pathListIndex])
            table.setValue("Total Cost", pathListIndex, totalCost)
        table.show("Costs for Level " + str(level))
        return (pathLists, minTotalCost)

    def generatePathListsLevel1(self):
        pathLists = []
        innateCosts = []
        overlapCosts = []
        leftoverCosts = []
        for p in self.paths:
            pathLists.append([p])
            innate, overlap, leftover = self.calculateCosts([p])
            innateCosts.append(innate)
            overlapCosts.append(overlap)
            leftoverCosts.append(leftover)
        return (pathLists, innateCosts, overlapCosts, leftoverCosts)

    def generatePathLists(self, level, previousCandidates, bestScore, verbose=True):
        if verbose:
            print("Length of previous Candidates = " + str(len(previousCandidates)))

        if level == 1:
            return self.generatePathListsLevel1()

        pathLists = []
        innateCosts = []
        overlapCosts = []
        leftoverCosts = []

        for candidate in previousCandidates:
            for p in self.paths:
                if p not in candidate:
                    possibleSet = [p]
                    possibleSet.extend(candidate)
                    if not self.alreadyInList(possibleSet, pathLists):
                        innate, overlap, leftover = self.calculateCosts(possibleSet)
                        if innate + overlap + leftover < bestScore:
                            pathLists.append(possibleSet)
                            innateCosts.append(innate)
                            overlapCosts.append(overlap)
                            leftoverCosts.append(leftover)

        if verbose:
            print("pathLists Length = " + str(len(pathLists)))

        return (pathLists, innateCosts, overlapCosts, leftoverCosts)

    def alreadyInList(self, candidate, list):
        if candidate in list:
            return True
        if any(set(candidate).issubset(set(element)) for element in list):
            return True
        return False

    def calculateCosts(self, pathList):
        innateWeight = 1.1
        overlapWeight = 1.0
        leftoverWeight = 1.0

        innateCost = self.calculateInnateCost(pathList) * innateWeight
        overlapCost = self.calculateOverlapCost(pathList) * overlapWeight
        leftoverCost = self.calculateLeftoverCost(pathList) * leftoverWeight

        return (innateCost, overlapCost, leftoverCost)

    def calculateInnateCost(self, pathList):
        return sum(path.getInnateCost() for path in pathList) / len(pathList)

    def calculateOverlapCost(self, pathList):
        lengthOfAllSegments = 0
        duplicatedLength = 0
        segments = []
        for path in pathList:
            lengthOfAllSegments += path.getLength()
            for s in path.segments:
                if s in segments:
                    duplicatedLength += s.getLength()
                else:
                    segments.append(s)
        return duplicatedLength / (lengthOfAllSegments - duplicatedLength)

    def calculateLeftoverCost(self, pathList):
        totalGraphLength = sum(s.getLength() for s in self.segments)
        selectedLength = sum(p.getLength() for p in pathList)

        return 1 - (selectedLength / totalGraphLength)

    # TODO Move That Somewhere else
    def createAngleTable(self, roi):
        polygon = roi.getPolygon()
        xPoints = polygon.xpoints
        yPoints = polygon.ypoints

        nPoints = polygon.npoints
        table = ResultsTable()
        firstAngle = Math.atan2(yPoints[0], xPoints[0])
        plot = Plot(str(roi.getName()) + " Angle", "--", "angle")

        angles = []
        derivative = []
        derivativeSign = []
        posDerivative = 0
        negDerivative = 0

        for i in range(nPoints):
            x = xPoints[i]
            y = yPoints[i]
            angle = Math.atan2(y, x)

            angles.append(angle - firstAngle)
            if i == 0:
                continue

            derivative.append(angle - angles[-2])
            derivativeSign.append(Math.signum(derivative[-1]))
            if derivativeSign[-1] > 0:
                posDerivative = posDerivative + 1
            else:
                negDerivative = negDerivative + 1

        maxSign = max(posDerivative, negDerivative)
        minSign = min(posDerivative, negDerivative)

        print("--" + str(roi.getName()))
        signRatio = float(minSign) / float(maxSign)
        print("Min Sign = " + str(minSign))
        print("Max Sign = " + str(maxSign))
        print("Sign Ratio = " + str(signRatio))
        plot.add("filled", derivativeSign)
        plot.show()

        if signRatio < 1.1:
            # table.show(str( roi.getName())+" Angle")
            return True
        return False

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
            for column in range(1, int(nbContact) + 1):
                currentContact = nodesTable.getStringValue("C" + str(column), i)
                for segment in self.segments:
                    if str(segment.ID) == currentContact:
                        node.addSegment(segment)
                        segment.addNode(node)
            self.nodes.append(node)

    def displayTextualGraph(self):
        for seg in self.segments:
            print(str(seg) + "=>" + seg.stringNodes())

    def doPathEnumeration(self, debug=False, verbose=False):
        validPaths = []
        for s in self.segments:
            if debug:
                print("Searching with base Segment S-" + str(s.getIDNumber()))
            currentPaths = self.getPossiblePaths(Path(s), debug, verbose)
            if currentPaths is not None:
                if type(currentPaths) is not type(validPaths):
                    validPaths.append(currentPaths)
                else:
                    validPaths.extend(iter(currentPaths))
        if debug:
            print("Enumeration Done, Starting to remove Duplicates")
        validPaths = self.removeDuplicatePaths(validPaths)
        if debug:
            print("Duplicates Removal Done, Starting to Reorder segments")
        validPaths = self.reorderSegmentsInPaths(validPaths)

        print("-----")
        print(str(len(validPaths)) + " paths found !")

        self.setPaths(validPaths)
        return self.paths

    def setPaths(self, paths):
        for i, p in enumerate(paths, start=0):
            p.setID(i)
        self.paths = paths

    def removeDuplicatePaths(self, pathList, verbose=False):
        for i, p in enumerate(pathList):
            firstIDString = p.getIDSortedString()
            if verbose:
                print(firstIDString)
            for p2 in (
                p2
                for i2, p2 in enumerate(pathList)
                if i2 > i and len(p2.segments) == len(p.segments)
            ):
                if verbose:
                    print(p2.getIDSortedString() + "?==" + firstIDString)
                if p2.getIDSortedString() == firstIDString:
                    if verbose:
                        print("Duplicate Removed")
                    pathList.remove(p2)
        return pathList

    def reorderSegmentsInPaths(self, pathList, verbose=False):
        for p in pathList:
            if verbose:
                print("in : " + str([str(s) for s in p.segments]))
            p.reorderSegments()
            if verbose:
                print("out : " + str([str(s) for s in p.segments]))
        return pathList

    def buildPathTable(self, tableName):
        table = ResultsTable()
        for index, p in enumerate(self.paths):
            p.addToResultTable(table, index)
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

    def removeOrphans(self, orphans, debug=False, verbose=False):
        self.removeOrphansSegments(orphans, debug, verbose)
        self.removeOrphansNodes(orphans, debug, verbose)

    def removeOrphansSegments(self, orphans, debug=False, verbose=False):
        rm = RoiManager.getRoiManager()

        for o in orphans:
            if o in self.segments:
                if verbose:
                    print("Orphan " + o.ID + " removed!")
                self.segments.remove(o)
                for index in range(rm.getCount() - 1):
                    if rm.getName(index) == o.ID:
                        break

                rm.select(index)
                rm.runCommand("Delete")

    def removeOrphansNodes(self, orphans, debug=False, verbose=False):
        for n in self.nodes:
            for o in orphans:
                if o in n.getSegments():
                    n.removeSegment(o)

            if len(n.getSegments()) == 0:
                self.nodes.remove(n)
                for s in self.segments:
                    if n in s.getNodes():
                        s.removeNode(n)

    def getPossiblePaths(self, path, debug=False, verbose=False):
        validPath = []
        if debug:
            print("Evaluating path " + str(path) + "!")

        if path is None:
            return

        if path.isTooLong() or path.hasTooManySegments():
            return None

        if not path.isTooShort():
            if verbose:
                print("Adding path " + str(path) + "to Valid Paths")
            validPath.append(path)

        for segment in path.filteredGetNeighbors():
            recursivePath = self.getPossiblePaths(
                path.createCombinedPath(segment), debug, verbose
            )
            if recursivePath is None:
                continue
            elif type(recursivePath) is not type(validPath):
                validPath.append(recursivePath)
            else:
                validPath.extend(
                    insidePath for insidePath in recursivePath if insidePath is not None
                )

        if not validPath:
            return None
        return validPath

    def evaluatePaths(self):
        table = ResultsTable()
        for p in self.paths:
            p.evaluateShapeCost(table)
        table.show("PathEvaluationTest")

    def filterPaths(self):
        evaluationTableTitle = "PathEvaluationTest"
        pathTableTitle = "pathsTable"
        evaluationTable = ResultsTable.getResultsTable(evaluationTableTitle)
        pathTable = ResultsTable.getResultsTable(pathTableTitle)
        rowToDelete = [
            index
            for index, p in enumerate(self.paths, start=0)
            if not p.isWanted(evaluationTable, index)
        ]

        for index in rowToDelete[::-1]:
            pathTable.deleteRow(index)
            evaluationTable.deleteRow(index)
            self.paths.pop(index)

        evaluationTable.show(evaluationTableTitle)
        pathTable.show(pathTableTitle)
        self.addPathsToRoiManager(evaluationTable)

    def addPathsToRoiManager(self, nameTable):
        rm = RoiManager.getRoiManager()
        initialCount = rm.getCount()
        for index, p in enumerate(self.paths, start=0):
            p.addToRoiManager(rm, nameTable.getStringValue("Path", index))


class Path:
    minWormLength = 450
    maxWormLength = 750
    maxSegmentNumber = 12

    def __init__(self, args=None):
        self.ID = None
        self.angle = None
        self.segments = None
        self.innateCost = None

        if args is not None:
            self.addSegment(args)

    def setID(self, inputID):
        self.ID = inputID

    def getID(self):
        return self.ID

    def addSegment(self, seg):
        if self.segments is None:
            self.segments = [seg]
        else:
            self.segments.append(seg)

    def getLength(self):
        totalLength = 0
        for s in self.segments:
            totalLength = totalLength + s.getLength()
        return totalLength

    def getPolygon(self):
        xPoints, yPoints = self.getLine()
        newRoi = PolygonRoi(xPoints, yPoints, Roi.POLYLINE)
        return newRoi.getPolygon()

    def isTooShort(self):
        return self.getLength() < self.minWormLength

    def isTooLong(self):
        return self.getLength() > self.maxWormLength

    def hasTooManySegments(self):
        return len(self.segments) > self.maxSegmentNumber

    def isTouchingTheEdge(self):
        return any(s.touchingTheEdge for s in self.segments)

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

    def createCombinedPath(self, segment):
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
            if s.getContactNode(newSegments[-1]) is not None:
                newSegments.append(s)
        newSegments.reverse()
        for s in self.segments:
            if s in newSegments:
                continue
            if s.getContactNode(newSegments[-1]) is not None:
                newSegments.append(s)
        self.segments = newSegments

    def getInnateCost(self):
        if self.innateCost is None:
            self.calculateInnateCost()
        return self.innateCost

    def calculateInnateCost(self):
        calculatedCost = -1 * ((self.calculateAngle(self.getPolygon()) / Math.PI) - 1)
        self.innateCost = calculatedCost

    def evaluateShapeCost(self, table):
        interpolatedPolygon = self.getPolygon()

        steepestAngleStep1 = self.calculateAngle(interpolatedPolygon, table)
        steepestAngleStep2 = self.calculateAngle(interpolatedPolygon, table, 2)
        nbSegments = len(self.segments)
        """
        index = table.size()
        table.setValue("Path",index,"P-"+str(index))
        table.setValue("Absolute Steepest Angle Step 1",index,steepestAngleStep1)
        table.setValue("Absolute Steepest Angle Step 2",index,steepestAngleStep2)
        table.setValue("Nb of Segments",index,nbSegments)
        """

    def isWanted(self, table, index):
        steepestAngleStep1 = table.getValue("Absolute Steepest Angle Step 1", index)
        steepestAngleStep2 = table.getValue("Absolute Steepest Angle Step 2", index)
        if self.isTouchingTheEdge():
            return False
        if max(steepestAngleStep1, steepestAngleStep2) > 2.0:
            return True
        return False

    def calculateAngle(self, polygon, table=None, step=1):
        xpoints = polygon.xpoints
        ypoints = polygon.ypoints
        npoints = polygon.npoints

        absMin = 3.15
        sumOfPositive = 0
        sumOfNegative = 0
        countOfPositive = 0
        countOfNegative = 0
        sumAngle = 0

        for i in range(step, npoints - step):
            angle = self.calculateAngleBetween3Points(
                xpoints[i - step],
                ypoints[i - step],
                xpoints[i],
                ypoints[i],
                xpoints[i + step],
                ypoints[i + step],
            )

            if angle < -Math.PI:
                angle = angle + 2 * Math.PI

            if angle >= 0:
                countOfPositive = countOfPositive + 1
                sumOfPositive = sumOfPositive + angle
            else:
                countOfNegative = countOfNegative + 1
                sumOfNegative = sumOfNegative + angle

            if Math.abs(angle) < absMin:
                absMin = Math.abs(angle)

        sumAngle = sumOfPositive + sumOfNegative
        sumAbsAngle = sumOfPositive - sumOfNegative

        if table is not None:
            index = table.size() - step + 1
            table.setValue("Path", index, "P-" + str(index))
            table.setValue("Absolute Steepest Angle Step " + str(step), index, absMin)
            table.setValue(str(step) + "-Sum Angle > 0", index, sumOfPositive)
            table.setValue(str(step) + "-Count Angle > 0", index, countOfPositive)
            table.setValue(str(step) + "-Sum Angle < 0", index, sumOfNegative)
            table.setValue(str(step) + "-Count Angle < 0", index, countOfNegative)
            table.setValue(str(step) + "-Sum Angle", index, sumAngle)
            table.setValue(str(step) + "-Sum Absolute Angle", index, sumAbsAngle)
        return absMin

    def calculateAngleBetween3Points(
        self, xPoint1, yPoint1, xPoint2, yPoint2, xPoint3, yPoint3
    ):
        return Math.atan2(yPoint3 - yPoint2, xPoint3 - xPoint2) - Math.atan2(
            yPoint1 - yPoint2, xPoint1 - xPoint2
        )

    def getLine(self):
        xPoints = []
        yPoints = []
        if len(self.segments) == 1:
            return self.segments[0].getPoints()

        for i in range(len(self.segments) - 1):
            startSegment = self.segments[i]
            endSegment = self.segments[i + 1]
            sPointsX, sPointsY = startSegment.getPointsUntil(endSegment)
            xPoints, yPoints = (xPoints + sPointsX, yPoints + sPointsY)

        sPointsX, sPointsY = endSegment.getPointsFrom(startSegment)
        xPoints, yPoints = (xPoints + sPointsX, yPoints + sPointsY)
        return (xPoints, yPoints)

    def addToResultTable(self, table, index):
        table.setValue("Path ID", index, "P-" + str(index))
        table.setValue("Number of Segments", index, len(self.segments))
        table.setValue("Length", index, self.getLength())
        for i, segment in enumerate(self.segments):
            table.setValue("S_" + str(i), index, str(segment))

    def addToRoiManager(self, roiManager, roiName):
        xPoints, yPoints = self.getLine()
        newRoi = PolygonRoi(xPoints, yPoints, Roi.POLYLINE)
        roiManager.add(newRoi, 0)
        count = roiManager.getCount()
        roiManager.rename(count - 1, roiName)

    def getIDSortedString(self):
        ID = [s.getIDNumber() for s in self.segments]
        ID.sort()
        return str(ID)

    def __str__(self):
        string = ""
        for s in self.segments:
            string = string + str(s) + " "
        return string


class Segment:
    margin = 3

    def __init__(self, args=None):
        self.ID = None
        self.roi = None
        self.nodesInContact = None
        self.touchingTheEdge = False

    def setRoi(self, inputRoi):
        self.roi = inputRoi
        self.ID = inputRoi.getName()

        imageWidth, imageHeight, _, _, _ = inputRoi.getImage().getDimensions()
        bounds = inputRoi.getBounds()
        margin = self.margin

        self.touchingTheEdge = (
            bounds.x < margin
            or bounds.x + bounds.width > imageWidth - margin
            or bounds.y < margin
            or bounds.y + bounds.height > imageHeight - margin
        )

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

    def getPointsUntil(self, otherSegment):
        contactNode = self.getContactNode(otherSegment)
        if contactNode is None:
            print("No Contact Nodes")
            return

        xPoints, yPoints = self.getPointsCloserToNode(contactNode)
        xPoints.append(contactNode.getX() - 0.5)
        yPoints.append(contactNode.getY() - 0.5)
        return (xPoints, yPoints)

    def getPointsFrom(self, otherSegment):
        xPoints, yPoints = self.getPointsUntil(otherSegment)
        xPoints.reverse()
        yPoints.reverse()
        xPoints.pop(0)
        yPoints.pop(0)
        return (xPoints, yPoints)

    def getContactNode(self, otherSegment):
        otherNodes = otherSegment.getNodes()
        selfNodes = self.getNodes()
        node = None
        for n in selfNodes:
            if n in otherNodes:
                node = n
                break
        return node

    def getPoints(self):
        inPolygon = self.roi.getInterpolatedPolygon(3, True)
        xPoints = inPolygon.xpoints.tolist()
        yPoints = inPolygon.ypoints.tolist()
        return (xPoints, yPoints)

    def getPointsReverse(self):
        xPoints, yPoints = self.getPoints()
        xPoints.reverse()
        yPoints.reverse()
        return (xPoints, yPoints)

    def getPointsCloserToNode(self, node):
        if node not in self.getNodes():
            print(
                "Node "
                + str(node)
                + " isn't at one end of the segment "
                + str(self)
                + " !"
            )
            return None

        polygon = self.roi.getPolygon()

        firstPointX, firstPointY = (polygon.xpoints[0], polygon.ypoints[0])
        lastPointX, lastPointY = (polygon.xpoints[-1], polygon.ypoints[-1])

        distanceToFirstPoint = abs(node.xCoord - firstPointX) + abs(
            node.yCoord - firstPointY
        )
        distanceToLastPoint = abs(node.xCoord - lastPointX) + abs(
            node.yCoord - lastPointY
        )
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


class Node:
    def __init__(self, args=None):
        self.ID = None
        self.xCoord = -1
        self.yCoord = -1
        self.segmentsInContact = []

    def setID(self, inputID):
        self.ID = inputID

    def setX(self, inputX):
        self.xCoord = inputX

    def setY(self, inputY):
        self.yCoord = inputY

    def addSegment(self, inputSegment):
        if self.segmentsInContact is None:
            self.segmentsInContact = []
        self.segmentsInContact.append(inputSegment)

    def removeSegment(self, inputSegment):
        index = self.segmentsInContact.index(inputSegment)
        self.segmentsInContact.pop(index)

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


# main(None)
if "getArgument" in globals():
    if not hasattr(zip, "__call__"):
        del zip  # the python function zip got overriden by java.util.zip, so it must be deleted to get the zip-function to work.
    args = getArgument()
    args = " ".join(args.split())
    print(args.split())
    main(args.split())

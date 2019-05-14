from ij import IJ, WindowManager
from ij.plugin.frame import RoiManager
from ij.gui import Roi, PointRoi, Line, PolygonRoi
from java.awt import Color
from math import sqrt

imageID = -1
maskID = -1
command = "doNothing"

def run(command):
    if command == "findEndPoints":
        findEndPoints(imageID, maskID)
    if command == "trackEnds":
        trackEnds(imageID, maskID)
    
def trackEnds(imageID, maskID):
    index = RoiManager.getInstance2().getSelectedIndex()
    inputIMP = WindowManager.getImage(imageID)
    maskIMP = WindowManager.getImage(maskID)
    points1 = inputIMP.getOverlay().get(0).getContainedPoints()[index]
    points2 = inputIMP.getOverlay().get(1).getContainedPoints()[index]
    roi = maskIMP.getOverlay().get(index)
    outerBounds = roi.getBounds()
    impMT, innerBounds = duplicateMaskInRoi(maskIMP, roi, True)
    centroid = impMT.getOverlay().get(0).getContourCentroid()
    nr, endPoint1, endPoint2 = findEndPointsInSkeleton(impMT)
    impMT.show()
    track1 = trackEnd(impMT, endPoint1, centroid);
    track2 = trackEnd(impMT, endPoint2, centroid);
    impMT.changes=False
    impMT.close()
    newTrack1 = []
    for point in track1:
        newTrack1.append((point.x + outerBounds.x + innerBounds.x - 1,
                         point.y + outerBounds.y + innerBounds.y - 1))
    newTrack2 = []
    for point in track2:
        newTrack2.append((point.x + outerBounds.x + innerBounds.x - 1,
                          point.y + outerBounds.y + innerBounds.y - 1))
    track1X = [point[0] for point in newTrack1]
    track1Y = [point[1] for point in newTrack1]
    roiTrack1 = PolygonRoi(track1X, track1Y, Roi.POLYLINE)
    inputIMP.getOverlay().add(roiTrack1)
    track2X = [point[0] for point in newTrack2]
    track2Y = [point[1] for point in newTrack2]
    roiTrack2 = PolygonRoi(track2X, track2Y, Roi.POLYLINE)
    inputIMP.getOverlay().add(roiTrack2)
    inputIMP.repaintWindow()            
    
def findEndPoints(imageID, maskID):
    endPoints1 = []
    endPoints2 = []

    imp = IJ.getImage()
    imp.setSlice(1);

    roiManager = RoiManager.getInstance2()
    rois = roiManager.getRoisAsArray()
    roisRoBeRemoved = []
    index = 0
    for roi in rois:
       outerBounds = roi.getBounds()
       impMT, innerBounds = duplicateMaskInRoi(imp, roi)
       nr, endPoint1, endPoint2 = findEndPointsInSkeleton(impMT)
       if (nr==2):
           endPoint1.x = endPoint1.x + outerBounds.x + innerBounds.x - 1
           endPoint1.y = endPoint1.y + outerBounds.y + innerBounds.y - 1
           endPoint2.x = endPoint2.x + outerBounds.x + innerBounds.x 
           endPoint2.y = endPoint2.y + outerBounds.y + innerBounds.y 
           endPoints1.append(endPoint1)
           endPoints2.append(endPoint2)
       else:
           roisRoBeRemoved.append(index)
       impMT.close()
       index = index + 1
    roiManager.setSelectedIndexes(roisRoBeRemoved)
    roiManager.runCommand("Delete")
    roiManager.moveRoisToOverlay(WindowManager.getImage(maskID))
    inputIMP = WindowManager.getImage(imageID)
    inputIMP.setOverlay(PointRoi([seq.x for seq in endPoints1], [seq.y for seq in endPoints1]), Color.magenta, 1, Color.magenta)
    otherPoints = PointRoi([seq.x for seq in endPoints2], [seq.y for seq in endPoints2])
    otherPoints.setStrokeColor(Color.cyan)
    otherPoints.setFillColor(Color.cyan)
    inputIMP.getOverlay().add(otherPoints)

def trackEnd(imp, endPoint, centroid):
    stackSize = imp.getStackSize()
    track = [endPoint]
    for i in range(2, stackSize+1):
        imp.setSlice(i)
        points = findAllEndPointInSkeleton(imp)
        track.append(getNextPoint(track, points, centroid))
    return track

def getNextPoint(track, points, centroid):
    candidates = []
    point = track[-1]
    distLastToMiddle = sqrt(((centroid[0]-point.x)**2) + ((centroid[1]-point.y)**2))
    for p in points:
        distCurrentToMiddle = sqrt(((centroid[0]-p.x)**2) + ((centroid[1]-p.y)**2))
        distCurrentToLast = sqrt(((point.x-p.x)**2) + ((point.y-p.y)**2))
        if ((distCurrentToMiddle<distLastToMiddle) and (distCurrentToLast<=distCurrentToMiddle)):
            candidates.append(p)
    if len(candidates)==0:
        return point
    if len(candidates)==1:        
        return candidates[0]
    distances = []
    for candidate in candidates:
        distances.append(sqrt(((candidate.x-point.x)**2) + ((candidate.y-point.y)**2)))
    index = distances.index(min(distances))
    return candidates[index]	
    
def findEndPointsInSkeleton(impMT):
    points = getPointsFromSekelton(impMT)
    nr = 0
    endPoint1 = (-1,-1)
    endPoint2 = (-1,-1)
    for point in points:
        rect = Roi(point.x-1, point.y-1, 3, 3)
        impMT.setRoi(rect)
        stats = impMT.getStatistics	()
        if (stats.mean > 56 and stats.mean<57):
            if (nr==0):
                endPoint1 = point
            else: 
                endPoint2 = point
            nr = nr + 1
    return nr, endPoint1, endPoint2

def findAllEndPointInSkeleton(impMT):
    points = getPointsFromSekelton(impMT)
    endPoints = []
    for point in points:
        rect = Roi(point.x-1, point.y-1, 3, 3)
        impMT.setRoi(rect)
        stats = impMT.getStatistics	()
        if (stats.mean > 56 and stats.mean<57):
            endPoints.append(point)
    return endPoints

# duplicates the mask in the roi with a border of 1 pixel
def duplicateMaskInRoi(imp, roi, duplicateStack=False):
    imp.setRoi(roi)
    if duplicateStack:
    	WindowManager.setCurrentWindow(imp.getWindow())
        impMT1 = IJ.run("Duplicate...", "duplicate")
        impMT1 = WindowManager.getCurrentImage()
    else:
        impMT1 = imp.crop()
    IJ.run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel")
    IJ.run(impMT1, "Create Selection", "")
    roi1 = impMT1.getRoi()
    bounds = roi1.getBounds()
    if duplicateStack:
       	WindowManager.setCurrentWindow(impMT1.getWindow())
        IJ.run("Duplicate...", "duplicate")
        impMT = WindowManager.getCurrentImage()
        impMT1.close()
    else:
        impMT = impMT1.crop()
    IJ.run(impMT, "Canvas Size...", "width="+str(bounds.width+2)+" height="+str(bounds.height+2)+" position=Center zero")  
    return impMT, bounds

def getPointsFromSekelton(imp):
    IJ.run(imp, "Points from Mask", "")
    points = imp.getRoi()
    imp.deleteRoi()
    return points
    
if 'getArgument' in globals():
  parameter = getArgument()
  args = parameter.split(",")
  command = args[0].split("=")[1]
  imageID = int(args[1].split("=")[1])
  maskID = int(args[2].split("=")[1])

run(command)
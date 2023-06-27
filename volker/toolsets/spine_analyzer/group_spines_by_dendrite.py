import sys
import math
from ij import IJ
from ij import ImagePlus
from ij.measure import Calibration
from inra.ijpb.measure.region3d import Centroid3D



def main():
    image = IJ.getImage()
    cal = image.getCalibration()
    tmpCal = Calibration()
    image.setCalibration(tmpCal)
    analyzer = Centroid3D()
    measurements = analyzer.analyzeRegions(image)
    
    print(measurements.values())
    
    overlay = image.getOverlay()
    dendrites = overlay.toArray()
    
    for label, centroid in measurements.items():
        minDist = sys.maxsize
        closestDendrite = None
        for dendrite in dendrites:
            dist = distance(dendrite, centroid)
            if dist < minDist:
                minDist = dist
                closestDendrite = dendrite
        print(label, closestDendrite.getGroup(), minDist)        
    image.setCalibration(cal)


def distance(dendrite, centroid):
    points = dendrite.getContainedPoints()
    minDist = sys.maxsize
    for point in points:
        dx = point.getX() - centroid.getX()
        dy = point.getY() - centroid.getY()
        dist = math.sqrt((dx * dx) + (dy * dy))
        if dist < minDist:
            minDist = dist
    return minDist

main()
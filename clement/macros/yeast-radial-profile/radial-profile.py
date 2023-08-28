from ij import IJ
from ij.gui import Roi, Line, PointRoi
import math
from ij.measure import ResultsTable

import os
os.system("clear")

# ================== SETTINGS ================== 

_diameter  = 52
_angle_deg = 2
_n_samples = 100

# ==============================================


angle      = math.radians(_angle_deg)
iterations = int(180 / _angle_deg)


def rotate_point(origin, point, angle):
    """
    Rotate a point counterclockwise by a given angle around a given origin.
    The angle should be given in radians.
    """
    # Translate to origin
    ox, oy = origin
    px, py = point

    qx = ox + math.cos(angle) * (px - ox) - math.sin(angle) * (py - oy)
    qy = oy + math.sin(angle) * (px - ox) + math.cos(angle) * (py - oy)

    return qx, qy


def getPoints(imIn):
    roi = imIn.getRoi()
    if roi is None:
        return None
    if roi.getType() != Roi.POINT:
        return None
    return roi.getPolygon()


def interpolate(p1, p2, imgProc):
    """
    Samples N points between p1 and p2.
    """

    x1, y1 = p1
    x2, y2 = p2

    dx = float(x2 - x1) / (_n_samples - 1)
    dy = float(y2 - y1) / (_n_samples - 1)

    points = []
    for i in range(_n_samples):
        x = x1 + i * dx
        y = y1 + i * dy
        points.append(imgProc.getf(int(x), int(y)))
    
    return points


def average_of_lists(list_of_lists):
    if not list_of_lists:  # vérifie si la liste est vide
        return None

    size = len(list_of_lists[0])

    averaged_list = []

    for i in range(size):
        total = sum([lst[i] for lst in list_of_lists])
        averaged_list.append(total / float(len(list_of_lists)))

    return averaged_list
    

def main():
    imIn = IJ.getImage()
    rt = ResultsTable()
    
    if imIn is None:
        print("No image opened")
        return -1
    
    poly = getPoints(imIn)
    if poly is None:
        print("No points were detected")
        return -1

    for k, (c, l) in enumerate(zip(poly.xpoints, poly.ypoints)):
        print("Processing point " + str(k))
        o  = (c, l)
        p1 = (c, int(l - _diameter/2))
        p2 = (c, int(l + _diameter/2))

        profiles = []
        for i in range(iterations):
            profile = interpolate(p1, p2, imIn.getProcessor())
            profiles.append(profile)

            p1 = rotate_point(o, p1, angle)
            p2 = rotate_point(o, p2, angle)
            
        averaged = average_of_lists(profiles)
        rt.setValue("X", k, c)
        rt.setValue("Y", k, l)
        rt.setValue("Peak", k, max(averaged))
    
    imIn.setRoi(PointRoi(poly))
    rt.show("Peaks")

main()
print("DONE.")

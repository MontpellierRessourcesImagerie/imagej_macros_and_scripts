from ij.plugin.frame import RoiManager
from ij import IJ
from ij import IJ, WindowManager, ImagePlus
from ij.gui  import Roi, PointRoi, PolygonRoi
from ij.process import FloatPolygon
import math
import time

# v1 - v2
def vecSub(v1, v2):
    x1, y1 = v1
    x2, y2 = v2
    return (x1-x2, y1-y2)


# Normalize a vector
def norma(vec):
    length = math.sqrt(vec[0]*vec[0]+vec[1]*vec[1])
    return (vec[0]/length, vec[1]/length)


# Given an angle, calculates the module to create an ellipsis (in polar coordinates)
def makeEllipsisPoints(width, height, angle, img):
    a = int(min(height, width) / 2) - 1
    b = int(max(height, width) / 2) - 1
    
    return (a * b) / math.sqrt((b*b*math.cos(angle)*math.cos(angle)) + (a*a*math.sin(angle)*math.sin(angle)))


# Class representing a ray with its origin and its direction. Handles moves.
class Ray:

    def __init__(self, o, d, img, tol):
        self.origin    = o
        self.direction = d
        self.image     = img
        self.go        = True
        self.tolerance = tol
        self.distance  = []
        self.reset()

    def reset(self):
        self.go = True
        self.distance.append(0)
    
    def getDistance(self, idx=-1):
        return self.distance[idx]

    def setOrigin(self, o):
        self.origin = o

    def setDirection(self, d):
        self.direction = d

    def getOrigin(self):
        return self.origin

    def getDirection(self):
        return self.direction

    def forceStep(self, t, n=1):
        T = n * t
        self.origin = (self.origin[0]+T*self.direction[0], self.origin[1]+T*self.direction[1])

    def move(self, t):
        if not self.go:
            return False

        # Making the ray go forward (and storing before and after pixel's value)
        proc        = self.image.getStack().getProcessor(1)
        before      = proc.get(int(self.origin[0]), int(self.origin[1]))
        newPoint    = (self.origin[0]+t*self.direction[0], self.origin[1]+t*self.direction[1])
        after       = proc.get(int(newPoint[0]), int(newPoint[1]))
        
        # Comparing pixel's value before and after moving. If the difference is to big, we stop (we certainly detected an outline)
        if abs(after - before) >= self.tolerance:
            self.go = False
            return False
        
        else:
            self.distance[-1] += t
            self.origin = newPoint
            return True

# Class representing an n-gon that can shrink around a structure.
class MovingNGon:

    def __init__(self, nbPoints, img, tol):
        self.points    = []
        self.nPoints   = nbPoints
        self.image     = img
        self.tolerance = tol
        self.centroid  = (0, 0)
        self.buildFramePointsList(nbPoints, img)


    def displayPoints(self):
        IJ.run(self.image, "Select None", "")

        self.image.setRoi(PolygonRoi(
            FloatPolygon(*map(list, zip(*map(Ray.getOrigin, self.points)))), # Unpacking x and y coordinates of rays in two lists
            Roi.NORMAL
        ))


    def balancePoints(self):
        pass

    
    def updateCentroid(self):
        pass


    def buildFramePointsList(self, nbPoints, img):
        incre = (2*math.pi) / nbPoints
        self.centroid = (img.getHeight()/2, img.getWidth()/2)
        angle = -math.pi

        for i in range(0, nbPoints):
            ro = makeEllipsisPoints(img.getWidth(), img.getHeight(), angle, img)
            x = (img.getWidth() / 2) + ro * math.cos(angle)
            y = (img.getHeight() / 2) + ro * math.sin(angle)
            vDir = norma(vecSub(self.centroid, (x, y)))
            self.points.append(Ray((x, y), vDir, img, self.tolerance))
            angle += incre

    
    def toString(self):
        return str(self.points)

    
    def reset(self):
        for pt in self.points:
            pt.reset()

    
    def forceStep(self, t, n=1):
        for pt in self.points:
            pt.forceStep(t, n)


    def getMedianDistance(self):
        return sorted(map(Ray.getDistance, self.points))[int(len(self.points)/2)]


    def expand(self, t):
        return False


    def shrink(self, t):
        moved = False

        for p in self.points:
            moved = p.move(t) or moved
        
        self.balancePoints()
        self.updateCentroid()

        return moved



def main():
    img = IJ.getImage()
    mvng = MovingNGon(80, img, 25)

    while mvng.shrink(0.2):
        mvng.displayPoints()
        time.sleep(0.02)

    print(mvng.getMedianDistance())
    time.sleep(2)
    mvng.reset()
    mvng.forceStep(0.5)
    
    while mvng.shrink(0.2):
        mvng.displayPoints()
        time.sleep(0.02)

    print(mvng.getMedianDistance())


main()


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# - [ ] The amount of points in an area must be balanced at each iteration.
# - [ ] The normals must be adapted.
# - [ ] The centroid's position must be updated along the execution.
# - [ ] Try to scan the neighborhood to determine if we can still go forward.
# - [ ] Make moving distance adaptive to better match the outline.
# - [ ] Can an expanding polygon work for that task?
# - [ ] Can a shrinking polygon handle the case where the two cells are not merged together?
# - [ ] Add a safety condition to avoid looping if the tolerance is too high.
# - [ ] Remove points moving too much compared to their direct neighbor.
# - [ ] Implement an average filter that uses the neighbors to smooth the points.
# - [ ] Modify the launching function so if a points selection is in the ROI manager, it uses it to place N centroids of N polygons.
# - [ ] Store steps in ROI manager? Process final selection (difference step1 - step2)?
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# - RDV Maxime -> Lundi (pas d'heure précise)
# - Record l'écran pendant les explications.
# - Comment tu segmenterais les cellules qui se touchent à la main ? Qu'est-ce qu'on fait en cas de contact (perte d'information)
# - Où commence la membrane ? Le halo blanc ou le noir à l'intérieur ? Les deux ?
# - Sur quel channel faire les mesures ?
# - Niveau de précision attendu ?
# - Forme du rendu ? (CSV, Image, ...)
# - Pour quand ?
# - Liste totale des mesures à extraire ? (aire, largeur moyenne/mediane de membrane, intensité, ...)
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 
#       = = = NOTES = = =
#
# - On peut détecter 3 zones (fond, cytoplasme1 et cytoplasme2) et utiliser ces 3 zones pour faire des expanding polygons.
#   On dirait que ces zones peuvent être facilement trouvées avec une localisation de composantes connexes. (si on considère le BG comme une structure et la membrane comme du BG).
#
# - Chaque rayon pourrait stocker la distance qu'il parcours dans une liste qui ajoute un élément à chaque reset.
#
# - La méthode d'expension plutôt que shrinking semble plus adaptée pour la position du centroide.
#   Avec le shrinking, les points latéraux sont quand même très attirés vers le centre de l'image au lieu de suivre les normales de la structure.
#
# - Si on reste sur le shrinking polygon (peu probable), on peut essayer de déterminer les point de séparation des cellules en prenant un point et en faisant un loop sur tous les autres.
#   On aurait ainsi une courbe de la distance à un point. Au niveau des points de rétrécissement, cette distance devrait avoir des valeurs reconnaissables.
#
# - Tester une segmentation par LabKit ?
#
# - Revoir les options proposées par Volker (marque-page orange).
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

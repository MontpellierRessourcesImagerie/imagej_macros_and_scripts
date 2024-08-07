from ij.plugin.frame import RoiManager
from ij import IJ
from ij import IJ, WindowManager, ImagePlus
from ij.gui  import Roi, PointRoi, PolygonRoi
from ij.process import FloatPolygon
from java.awt import Point
import math
import time

def isSmall(e):
    return abs(e) < 0.0001

## @brief v1 - v2
def vecSub(v1, v2):
    x1, y1 = v1
    x2, y2 = v2
    return (x1-x2, y1-y2)


## @brief Process the distance between two points
def distance(p1, p2):
    return math.sqrt(p1[0]*p2[0] + p1[1]*p2[1])

## @brief Normalize a vector
def norma(vec):
    length = math.sqrt(vec[0]*vec[0]+vec[1]*vec[1])
    return (vec[0]/length, vec[1]/length)


## @brief Given an angle, calculates the module to create an ellipsis (in polar coordinates)
def makeEllipsisPoints(width, height, angle, img):
    a = int(min(height, width) / 2) - 1
    b = int(max(height, width) / 2) - 1
    
    return (a * b) / math.sqrt((b*b*math.cos(angle)*math.cos(angle)) + (a*a*math.sin(angle)*math.sin(angle)))


# Class representing a ray with its origin and its direction. Handles moves.
class Ray:

    ## @brief Constructor
    ## @param o The origin point of this ray, where it will start its travel.
    ## @param d Director vector of this ray. It is recommended to provided something normalized.
    ## @param img Image on which intensities will be scanned to detect if a ray can keep going.
    ## @param tol Maximal tolerated difference of intensity between two steps of the ray to block its travel (detect a contour).
    def __init__(self, o, d, img, tol):
        self.origin    = o
        self.direction = d
        self.image     = img
        self.go        = True
        self.tolerance = tol
        self.distance  = []
        self.reset()

    ## @brief Resets the locking status of this ray so it can move again.
    def reset(self):
        self.go = True
        self.distance.append(0)
    
    ## @brief Returns the distance traveled by this ray during this iteration (from start to lock)
    def getDistance(self, idx=-1):
        return self.distance[idx]

    ## @brief Modifies the current position of this ray.
    def setOrigin(self, o):
        self.origin = o

    ## @brief Modifies the director vector of this ray
    def setDirection(self, d):
        self.direction = d

    ## @brief Get the current location of the ray.
    def getOrigin(self):
        return self.origin

    ## @brief Get the director vector of this ray
    def getDirection(self):
        return self.direction

    ## @brief Forces a step to go forward, independently of its locking status.
    def forceStep(self, t, n=1):
        T = n * t
        self.origin = (self.origin[0]+T*self.direction[0], self.origin[1]+T*self.direction[1])

    ## @brief Method moving a ray along its normal according to the provided distance.
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


## @brief Class representing an n-gon that can shrink around a structure.
class MovingNGon:

    def __init__(self, center, nbPoints, img, tol, mode):
        self.points    = []
        self.nPoints   = nbPoints
        self.image     = img
        self.tolerance = tol
        self.origin  = center
        
        if mode == 'SHRINK':
            self.buildShrinkingRays()
        elif mode == 'EXPAND':
            self.buildExpandingRays()
        else:
            IJ.log("Unknown mode for MovingNGon: '{0}'".format(mode))


    ## @brief Process the total length of the polygon and the length of each segment composing it.
    def distanceCurve(self):
        distances = []
        for i in range(0, len(self.points)-1):
            p1 = self.points[i].getOrigin()
            p2 = self.points[i+1].getOrigin()
            distances.append(distance(p1, p2))
        
        total = sum(distances)
        theory = total / self.nPoints

        return map(lambda e : e / theory, distances)


    ## @brief Displays this N-Gon as an ROI in Fiji
    def displayPoints(self):
        IJ.run(self.image, "Select None", "")

        self.image.setRoi(PolygonRoi(
            FloatPolygon(*map(list, zip(*map(Ray.getOrigin, self.points)))), # Unpacking x and y coordinates of rays in two lists
            Roi.NORMAL
        ))


    ## @brief Spreads the points more evenly on the detected contour.
    def balancePoints(self):
        pass

    
    ## @brief Function used in the shrinking process to change the position of the centroid according to the detected contours.
    def updateCentroid(self):
        pass


    ## @brief Builds a list of points shaped as an ellipsis settled to shrink.
    def buildShrinkingEllipsis(self):
        incre = (2 * math.pi) / self.nPoints
        angle = -math.pi

        for i in range(0, self.nPoints):
            ro = makeEllipsisPoints(self.image.getWidth(), self.image.getHeight(), angle, self.image)
            x = (self.image.getWidth() / 2) + ro * math.cos(angle)
            y = (self.image.getHeight() / 2) + ro * math.sin(angle)
            vDir = norma(vecSub(self.origin, (x, y)))
            self.points.append(Ray((x, y), vDir, self.image, self.tolerance))
            angle += incre

    
    def processCentroid(self):
        pc = self.image.getProcessor()
        xs = []
        ys = []

        for c in range(self.image.getWidth()):
            for l in range(self.image.getHeight()):
                if pc.get(c, l) == 255:
                    xs.append(c)
                    ys.append(l)

        self.origin = (
            sum(xs) / len(xs),
            sum(ys) / len(ys)
        )

    
    def intersection(self, d):
        if isSmall(d[0]):
            return (self.origin[0], 0) if d[1] < 0 else (self.origin[0], self.image.getHeight()-1)
        else:
            if d[0] < 0:
                dist = self.origin[0]
            else:
                dist = self.image.getWidth() - self.origin[0]
            tx = abs(dist / d[0])

        if isSmall(d[1]):
            return (0, self.origin[1]) if d[0] < 0 else (self.image.getWidth()-1, self.origin[1])
        else:
            if d[1] < 0:
                dist = self.origin[1]
            else:
                dist = self.image.getHeight() - self.origin[1]
            ty = abs(dist / d[1])

        t = min(tx, ty)

        x = int(self.origin[0] + d[0] * t)
        y = int(self.origin[1] + d[1] * t)

        if x < 0:
            x = 0
        if x >= self.image.getWidth():
            x = self.image.getWidth() - 1

        if y < 0:
            y = 0
        if y >= self.image.getHeight():
            y = self.image.getHeight() - 1

        return (x, y)
            

    
    def buildShrinkingRays(self):
        incre = (2 * math.pi) / self.nPoints
        angle = -math.pi
        self.processCentroid()

        for i in range(0, self.nPoints):
            vDir = (math.cos(angle), math.sin(angle))
            point = self.intersection(vDir)
            self.points.append(Ray(point, (-1.0*vDir[0], -1.0*vDir[1]), self.image, self.tolerance))
            angle += incre


    ## @brief Builds a list of rays settled to start all on the same point and expand as a circle.
    def buildExpandingRays(self):
        incre = (2 * math.pi) / self.nPoints
        angle = -math.pi

        for i in range(0, self.nPoints):
            vDir = (math.cos(angle), math.sin(angle))
            self.points.append(Ray(self.origin, vDir, self.image, self.tolerance))
            angle += incre

    
    def toString(self):
        return str(self.points)

    
    ## @brief Resets the locking status of all rays
    def reset(self):
        for pt in self.points:
            pt.reset()


    ## @brief Forces rays to go one step ahead even if they are locked.
    def forceStep(self, t, n=1):
        for pt in self.points:
            pt.forceStep(t, n)


    ## @brief Get the median distance traveled by rays for this iteration.
    def getMedianDistance(self):
        return sorted(map(Ray.getDistance, self.points))[int(len(self.points)/2)]

    
    def outputCoordinates(self, path):
        f = open(path, 'w')
        for p in self.points:
            f.write(str(p.origin) + ";" + str(p.direction) + "\n")
        f.close()

    
    def updateNormals(self):
        for i in range(len(self.points)):
            a = self.points[i-1].origin # A
            b = self.points[i].origin   # B

            if i+1 >= len(self.points):
                c = self.points[0].origin # C
            else:
                c = self.points[i+1].origin # C

            v1 = (b[0]-a[0], b[1]-a[1]) # AB
            v2 = (c[0]-b[0], c[1]-b[1]) # BC

            x1 = 1.0
            y1 = (x1 * v1[0]) / v1[1]

            x2 = 1.0
            y2 = (x2 * v2[0]) / v2[1]

            n1 = norma((x1, y1))
            n2 = norma((x2, y2))
            d1 = distance(a, b)
            d2 = distance(b, c)

            nx = (d1 * n1[0] + d2 * n2[0])
            ny = (d1 * n1[1] + d2 * n2[1])
            cx = self.points[i].direction[0]
            cy = self.points[i].direction[1]

            if nx * cx + ny * cy > 0:
                n = (nx, ny)
            else:
                n = (-nx, -ny)
            
            n = norma(n)

            self.points[i].setDirection(n)



    ## @brief Calls the move function of each ray until no one can move anymore
    ## @return A boolean telling if at least a ray can still move in this n-gon.
    def move(self, t):
        moved = False

        for p in self.points:
            moved = p.move(t) or moved

        return moved


## @brief If the first slots of the ROI Manager contains a points selection, uses it as starting points for moving n-gons.
## @return A list of tuple (possibly empty) containing all starting points.
def seedsFromRoiManager():
    rm = RoiManager().getInstance()
    if rm.getCount() == 0:
        return []

    roi = rm.getRoi(0) # Tous les points sont stockés dans la même ROI
    if roi.getType() != Roi.POINT:
        return []
    
    startingPoints = [(p.x, p.y) for p in roi.getContainedPoints()]
    return startingPoints


def main():
    img = IJ.getImage()

    mvng = MovingNGon((0, 0), 60, img, 1, 'SHRINK')

    while mvng.move(0.2):
        pass
        # mvng.displayPoints()
        # time.sleep(0.02)
    
    mvng.outputCoordinates("/home/benedetti/Bureau/before_update.txt")

    mvng.updateNormals()

    mvng.outputCoordinates("/home/benedetti/Bureau/after_update.txt")

    # for i in range(10):
    #     mvng.forceStep(0.2)
    #     mvng.displayPoints()
    #     time.sleep(0.02)



main()

# Pour la distance parcourue, au lieu d'arrêter, de faire un forceStep et de continuer, plutôt continuer tout du long mais changer
# automatiquement de collection quand la tolérance est franchie.

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# - [ ] Output a curve representing the distance between each points of the ROI.
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
# - [ ] What does the input look like? A tiff with a filled ROI Manager? A bio-format image?
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# 
#       = = = = = = NOTES = = = = = =
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
# - L'avantage du lissage de points et de la vérification de distance est aussi que les 2 structure n'ont pas à être totalement fermées.
#   On peut simplement placer le "mauvais point" entre 2 autres avec un léger shift.
#
# - Pour retirer les coprs à l'intérieur de la cellule, on peut utiliser la proximité avec la sélection.
#   La roundness ou compactness des formes peut aussi être testée. Même la taille, mais ça risque d'être peu représentatif.
#   Nos shapes sont censées être très vides et épouser les bords d'un cercloïde.
#
# - Si les normales ne sont pas correctement calculées, l'épaisseur de la membrane sera faussée car le trajet sera plus long à travers la membrane.
#   Il faut absolument actualiser les normales, au moins avant la deuxième phase (et arrêter d'utiliser le centroïde comme référent tout le long).
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

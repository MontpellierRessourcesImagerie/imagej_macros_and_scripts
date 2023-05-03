from ij import IJ, ImagePlus
from ij.gui import OvalRoi
import math
from inra.ijpb.label import LabelImages
from inra.ijpb.data.border import BorderManager, ConstantBorder
from ij.plugin import ImageCalculator
from ij.gui import PolygonRoi, Roi
from java.awt import Color, Polygon

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Prend en argument une image qui contient des labels qui représentent l'emplacement des noyaux.
# Les valeurs des labels match les valeurs dans les labels de cytoplasmes.
# On calcule ici le centroïde de chaque noyau car ce sont ces points qui seront utilisés comme départ des radial-rays.
# Le dico produit renvoie un point 2D pour une valeur de label passée comme clé.
def processNucleiCentroids(nucleiLabels):
	coordinates = {} # Ce dico est indexé avec les labels, chaque item doit contenir la somme des coordonées, suivie du nombre de pixels.
	processed   = {} # Contient les coordonnées 2D du centroid de chaque nuclei.
	ip          = nucleiLabels.getProcessor()
	
	# On ajoute les coordonnées des pixels au buffer selon le label.
	for r in range(ip.getHeight()):
		for c in range(ip.getWidth()):
			val = ip.get(c, r)
			if val == 0:
				continue
			old = coordinates.setdefault(val, (0.0, 0.0, 0)) # [a, b, c]: a = sum of x axis, b = sum of y axis, c = nb of pixels in the sum
			coordinates[val] = (old[0]+c, old[1]+r, old[2]+1)

	# On divise par le nombre d'occurences du label.
	for key, (a, b, c) in coordinates.items():
		pos = (a/c, b/c)
		if ip.get(int(pos[0]), int(pos[1])) > 0:
			processed[key] = pos
		
	return processed

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Distance Euclidienne entre deux points 2D.
def distance(p1, p2):
	return math.sqrt(((p2[0] - p1[0]) * (p2[0] - p1[0])) + ((p2[1] - p1[1]) * (p2[1] - p1[1])))

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Retourne la distance maximale entre le centroid du nuclei et le point le plus loin de la cellule.
# En d'autres termes, cette fonction renvoie un dictionnaire qui pour chaque label, donne le radius du cercle qui est centré sur le nuclei et englobe la cellule.
# C'est le "bounding-circle".
def createCircle(nucleiLabels, cellsLabels):
	centers   = processNucleiCentroids(nucleiLabels)
	distances = {}
	cLblsPrc  = cellsLabels.getProcessor()
	
	for r in range(cLblsPrc.getHeight()):
		for c in range(cLblsPrc.getWidth()):
			val = cLblsPrc.get(c, r)
			if (val == 0) or (val not in centers.keys()):
				continue
			distances.setdefault(val, 0.0)
			dst = distance((c, r), centers[val])
			distances[val] = max(distances[val], dst)
	
	for k in distances.keys():
		distances[k] = math.ceil(distances[k])
	
	return centers, distances

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

def makeBorders(img, factor=0.5):
	size = int(factor * max(img.getHeight(), img.getWidth()))
	IJ.run(img, "Extend Image Borders", "left={0} right={0} top={0} bottom={0} fill=Black".format(str(size)))
	imgold = IJ.getImage()
	imgPadded = imgold.duplicate()
	imgold.close()
	img.close()
	return imgPadded

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Prend en input les images labélisées de noyaux et de cellules.
# Pour les tests actuels, les chemins sont hard-codés. Ils doivent être passés en paramètres.
def test_create_circles():
	nucleiImage = IJ.openImage("/home/benedetti/Bureau/testing/" + "nuclei.tif")
	cellsImage  = IJ.openImage("/home/benedetti/Bureau/testing/" + "cells.tif")

	# On a besoin d'ajouter des bordures noires car on veut pouvoir faire un carré centré autour de chaque individu.
	# Cela dans le but d'avoir des wedges qui ont toutes la même aire.
	# Les labels trop proches des bords peuvent ne pas avoir assez de marge pour faire un carré sans ajouter du padding artificiellement.
	nucleiImage = makeBorders(nucleiImage)
	cellsImage  = makeBorders(cellsImage)
	
	# On retire les noyaux sur les labels de cellules (on les transforme en BG)
	# Cela dans le but de pouvoir détecter facilement le moment de sortie du noyau dans les wedges.
	# On termine ces 3 lignes avec un dico qui donne une distance par label, et des labels troués.
	centers, radius = createCircle(nucleiImage, cellsImage)
	woNuclei = ImageCalculator.run(cellsImage, nucleiImage, "subtract")
	chunks = {}
	
	# Pour chaque label...
	for val in centers.keys():
		c = centers[val] # Centre du bounding-circle
		d = radius[val] # Rayon du bounding-circle
		roi = OvalRoi(c[0]-d, c[1]-d, d*2, d*2)
		woNuclei.setRoi(roi)
		# On isole les labels sur des images carrées, et on retire les morceaux d'autres labels qu'on a attrapé dans le cropping.
		chunk = woNuclei.crop()
		toBeRemoved = list(centers.keys())
		toBeRemoved.remove(val)
		LabelImages.replaceLabels(chunk.getProcessor(), toBeRemoved, 0)
		chunks[val] = chunk
	
	woNuclei.close()
	nucleiImage.close()
	cellsImage.close()
	
	# On retourne une liste d'images carrées qui contiennent toutes exactement un label de cellule trouée par leur noyau.
	return chunks

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Vérifie que des coordonnées sont dans les limites de l'image.
def in_bounds(csx, csy, img):
	return (csx >= 0) and (csy >= 0) and (csx < img.getWidth()) and (csy < img.getHeight())

# Une wedge est un triangle dont un point est au centre du bounding-circle, et les deux autres sont sur le bounding-circle.
# Dans cette fonction, on cherche à trouver les 4 points d'intersections entre le label et les segments de la wedge.
def findBorder(c0, p1, image, iters=2000):
	"""
	Goes from the end to the start of the path, seeking for the transition from BG fo FG.

	c0: Origin of the path.
	p1: End point of the path.
	image: Image on which FG/BG will be probed.
	iters: Cap of iterations number.
	"""	
	pr = image.getProcessor()

	# Direction vector of the wedge and normalization
	v1 = (p1[0] - c0[0], p1[1] - c0[1])
	nv = distance((0, 0), v1)
	ix, iy = v1[0] / nv, v1[1] / nv
	
	psx, psy = c0[0] + v1[0], c0[1] + v1[1]
	count = 0

	while (not in_bounds(psx, psy, image)) and (count <= iters):
		psx -= ix
		psy -= iy
		count += 1
	
	vl1 = pr.get(int(psx), int(psy))

	while (vl1 == 0) and (count <= iters):
		psx -= ix
		psy -= iy
		vl1 = pr.get(int(psx), int(psy))
		count += 1
	
	return (psx, psy)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Cette fonction itère sur le cercle trigo pour couper des wedges.
# 'divs' est le nombre de wedges qu'on va créer sur le cercle trigo.
# Cette fonction prendra en input la collection d'images carrées qui ne contiennent qu'un label. Pour l'instant, cette liste est acquise avec 'test_create_circle()'
def makePieSlices(divs):
	chunks = test_create_circles()
	incr   = 2.0 * math.pi / divs # Incrément d'angle

	# Pour chaque index de label et l'image carrée qui le contient
	for label, chunk in chunks.items():
		radius = chunk.getWidth()/2
		cX = cY = int(radius)
		for i in range(1, divs+1):
			a1 = (i-1) * incr
			a2 = i * incr

			# Construction des coordonnées des 3 points d'une wedge.
			x1 = int(cX + radius * math.cos(a1))
			x2 = int(cX + radius * math.cos(a2))
			y1 = int(cY + radius * math.sin(a1))
			y2 = int(cY + radius * math.sin(a2))
			poly = Polygon([cX, x1, x2], [cY, y1, y2], 3)

			roi = PolygonRoi(poly, Roi.POLYGON)
			clrCompo =  (1.0/(divs+1))*i

			end1   = findBorder((cX, cY), (x1, y1), chunk)
			end2   = findBorder((cX, cY), (x2, y2), chunk)
			start1 = findBorder((x1, y1), (cX, cY), chunk)
			start2 = findBorder((x2, y2), (cX, cY), chunk)

			# --- Marking only for visual contrast ---
			# prcr = chunk.getProcessor()
			# prcr.setColor(clrCompo*65535)
			# prcr.fill(roi)
		chunk.show()
		return

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

makePieSlices(200)








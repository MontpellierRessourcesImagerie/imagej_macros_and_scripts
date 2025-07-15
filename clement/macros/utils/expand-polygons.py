from ij import IJ, ImagePlus
from ij.plugin.frame import RoiManager
from ij.gui import Roi, PolygonRoi
from ij.process import FloatPolygon
import math
from java.awt import Color
from ij.plugin.filter import EDM
from inra.ijpb.binary.conncomp import FloodFillComponentsLabeling


def centroid(polygon):
	xs = sum(polygon.xpoints)
	ys = sum(polygon.ypoints)
	return (xs / polygon.npoints, ys / polygon.npoints)

def smooth_polygon(xs, ys, window=3):
    n = len(xs)
    if n < window:
        return xs[:], ys[:]

    half_w = window // 2
    new_xs = []
    new_ys = []
    for i in range(n):
        sum_x = 0.0
        sum_y = 0.0
        for j in range(-half_w, half_w + 1):
            idx = (i + j) % n
            sum_x += xs[idx]
            sum_y += ys[idx]
        new_xs.append(sum_x / window)
        new_ys.append(sum_y / window)

    return new_xs, new_ys

def get_polygons():
	rm = RoiManager.getInstance()
	if rm is None:
		return []
	rois = rm.getRoisAsArray()
	rois = [r.getFloatPolygon() for r in rois if r.type == Roi.POLYGON]
	rois = [FloatPolygon(*smooth_polygon(r.xpoints, r.ypoints)) for r in rois]
	return rois

def magnitude(v):
	return math.sqrt(v[0]**2 + v[1]**2)

def find_point(l, boundaries, p, v, distance, niters=200):
	i = 0
	t = -1
	f = 1.0
	while (i < niters) and (t != l):
		p2x = int(f * distance * v[0] + p[0])
		p2y = int(f * distance * v[1] + p[1])
		i += 1
		f *= 0.95
		if p2x >= boundaries.getWidth() or p2x < 0:
			continue
		if p2y >= boundaries.getHeight() or p2y < 0:
			continue
		t = boundaries.get(p2x, p2y)
	
	if t != l:
		return p
	
	return (p2x, p2y)

def expand(polygon, distance, boundaries):
	c  = centroid(polygon)
	xs = polygon.xpoints
	ys = polygon.ypoints
	ep = {'x': [], 'y': []}
	l  = boundaries.get(int(c[0]), int(c[1]))
	
	for x, y in zip(xs, ys):
		v = (x-c[0], y-c[1])
		m = magnitude(v)
		v = tuple([k/m for k in v])
		ex, ey = find_point(l, boundaries, (x, y), v, distance)
		ep['x'].append(ex)
		ep['y'].append(ey)
	
	return FloatPolygon(ep['x'], ep['y'])

def expansion(polygons, distance, boundaries):
	return [expand(p, distance, boundaries) for p in polygons]

def expansions(polygons, series, boundaries):
	expanded = {}
	for s in series:
		expanded[s] = expansion(polygons, s, boundaries)
	return expanded

def add_polygons(expanded):
	rm = RoiManager.getInstance()
	for i, (radius, polygons) in enumerate(expanded.items()):
		for p in polygons:
			roi = PolygonRoi(p, Roi.POLYGON)
			rm.add(roi, -1)

def calibrate(radii, image):
	calib = image.getCalibration()
	return [r / calib.pixelWidth for r in radii]

def build_boundaries(image, polygons):
	centroids = [centroid(p) for p in polygons]
	bounds = IJ.createImage(
		"voronoi-boundaries",
		image.getWidth(),
		image.getHeight(),
		image.getNSlices(),
		8
	)
	prc = bounds.getProcessor()
	for x, y in centroids:
		prc.set(int(x), int(y), 255)
	edm = EDM()
	edm.setup("voronoi", bounds)
	edm.run(prc)
	prc.setThreshold(1, 255)
	mask = prc.createMask()
	bounds.close()
	mask.invert()
	ffcl = FloodFillComponentsLabeling(4, 16)
	return ffcl.computeLabels(mask)

def main():
	plaques  = get_polygons()
	if len(plaques) == 0:
		print("Nothing found, abort")
		return
	
	radii    = [5.0, 9.0, 15.0] # um
	image    = IJ.getImage()
	radii    = calibrate(radii, image) # to pxl
	bounds   = build_boundaries(image, plaques)
	expanded = expansions(plaques, radii, bounds)
	
	img = ImagePlus("boundaries", bounds)
	img.show()
	add_polygons(expanded)
	
if __name__ == "__main__":
	main()
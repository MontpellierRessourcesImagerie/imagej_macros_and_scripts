from eu.kiaru.limeseg import LimeSeg
from eu.kiaru.limeseg.struct import Cell
from eu.kiaru.limeseg.struct import CellT
from eu.kiaru.limeseg.struct import DotN
from eu.kiaru.limeseg.struct import Vector3D
from ij.gui import PolygonRoi
from  ij.gui import Roi
from ij import IJ
from  ij.plugin.frame import RoiManager
from java.awt import Color

xPoints = []
yPoints = []
ip = IJ.getImage()	
pw = ip.getCalibration().pixelWidth
vd = ip.getCalibration().pixelDepth

index = 1; 
for c in LimeSeg.allCells:
	roisX = {}
	roisY = {}
	LimeSeg.currentCell=c
	ct = c.getCellTAt(1) 
	for dn in ct.dots:
		z = int(round(dn.pos.z))
		if not z in roisX:
			roisX[z] = []
		if not z in roisY:
			roisY[z] = []	
		roisX[z].append(dn.pos.x)
		roisY[z].append(dn.pos.y)

	roiManager = RoiManager.getInstance()
	for key in roisX.keys():
		roi = PolygonRoi(roisX[key], roisY[key], Roi.POLYGON)
		roi = PolygonRoi(roi.getConvexHull(), Roi.POLYGON)
		roi.setPosition(key)
		roi.setColor(Color(index, index, index))
		roi.setFillColor(Color(index, index, index))
		roiManager.addRoi(roi)
	index = index + 1
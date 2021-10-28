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
from ij.gui import NewImage

xPoints = []
yPoints = []
ip = IJ.getImage()	
title = ip.getTitle()
width = ip.getWidth()
height = ip.getHeight()
nip = NewImage.createShortImage(title+"-mask", width, height, ip.getNSlices(), NewImage.FILL_BLACK)

index = 1
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

	for key in roisX.keys():
		roi = PolygonRoi(roisX[key], roisY[key], Roi.POLYGON)
		roi = PolygonRoi(roi.getConvexHull(), Roi.POLYGON)
		roi.setPosition(key)
		nip.setSlice(key)
		nip.getProcessor().setValue(index)
		nip.getProcessor().fill(roi)	
	index = index + 1
nip.show()
IJ.resetMinAndMax(nip);
IJ.run(nip, "3-3-2 RGB", "");
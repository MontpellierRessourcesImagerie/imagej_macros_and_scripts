from eu.kiaru.limeseg import LimeSeg
from eu.kiaru.limeseg.struct import Cell
from eu.kiaru.limeseg.struct import CellT
from eu.kiaru.limeseg.struct import DotN
from eu.kiaru.limeseg.struct import Vector3D
from ij.gui import PolygonRoi
from  ij.gui import Roi
from ij import IJ

xPoints = []
yPoints = []
ip = IJ.getImage()	
pw = ip.getCalibration().pixelWidth
vd = ip.getCalibration().pixelDepth
roisX = {}
roisY = {}
for c in LimeSeg.allCells:
	LimeSeg.currentCell=c
	ct = c.getCellTAt(1) 
	for dn in ct.dots:
		print("P=\t"+str(dn.pos.x)+"\t"+str(dn.pos.y)+"\t"+str(dn.pos.z)+"\t");
		print(" N=\t"+str(dn.Norm.x)+"\t"+str(dn.Norm.y)+"\t"+str(dn.Norm.z)+"\t");
		z = round(dn.pos.z)
		if not roisX[z]:
			roisX[z] = []
		if not roisY[z]:
			roisY[z] = []	
		roisX[z].append(dn.pos.x)
		roisY[z].append(dn.pos.y)

roiManager = RoiManager.getInstance()
for key in roisX.keys():
	roi = PolygonRoi(roisX[key], roisY[key], Roi.POLYGON)
	IJ.setSlice(key)
	roiManager.addRoi(roi)
	
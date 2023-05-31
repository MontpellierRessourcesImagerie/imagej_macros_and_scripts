from ij import IJ, ImagePlus
from ij.plugin import ImageCalculator
from java.awt import Color
from inra.ijpb.morphology import Reconstruction
from inra.ijpb.binary.conncomp import FloodFillComponentsLabeling
from inra.ijpb.label.edit import ReplaceLabelValues
from inra.ijpb.label import LabelImages
import os

# Les détections sont exportées en tant qu'overlays dans les .tiff
# Il faut les extraire sous forme de sélection (sachant que certaines sont inutiles)
# Cette fonction transforme ces overlays en 2 masques.
def masksFromDetections(detectionsPath):
    detections = IJ.openImage(detectionsPath)
    allRois    = detections.getOverlay().toArray()
    height     = detections.getHeight()
    width      = detections.getWidth()
    white      = Color(1.0, 1.0, 1.0)
    detections.close()

    nucleiMask = IJ.createImage("NucleiMask", width, height, 1, 16)
    cellsMask  = IJ.createImage("CellsMask", width, height, 1, 16)
    counters = {
        id(nucleiMask.getProcessor()): 0,
        id(cellsMask.getProcessor()): 0
    }
    
    # Les sélectiions de cellules sont stockées à la suite de celles des noyaux.
    # 'active' détermine le masque de destination. On fait une détection selon l'index dans les ROIs.
    # Quand les indices sont reset à 1, on peut considérer que le switch a eu lieu.
    active  = None
    lastIdx = 1

    for r in allRois:
        name = r.getName()
        if name is None:
        	active = nucleiMask.getProcessor()
        	continue
        
        idx, dump = [int(i) for i in name.split("-")]
        if idx < lastIdx:
            active = cellsMask.getProcessor()
        lastIdx = idx

        r.setFillColor(white)
        active.setColor(white)
        active.fill(r)
        counters[id(active)] += 1

    # On affiche le nombre de cellules et de noyaux détectés. Ces deux nombres peuvent être différents.
    print("Nuclei: {0}, cells: {1}".format(
        counters[id(nucleiMask.getProcessor())],
        counters[id(cellsMask.getProcessor())]
    ))
    
    return (nucleiMask, cellsMask)

# Les détections peuvent contenir des éléments invalides dont-on veut se débarasser avant de commencer à calculer.
# Par exemple, des noyaux peuvent ne pas avoir de cellule associée, des noyaux peuvent dépasser de la cellule, des cellules touchent les bords, ...
# À la fin de cette fonction, 2 images labelisées sont renvoyées, avec des labels correspondants.
# C'est-à-dire que pour un même index de label, on a un noyau dans une image et la cellule à laquelle il appartient dans l'autre.
def cureAndIdentify(nucleiMask, cellsMask):
    # Killing borders on the cells. Removes connected components touching the borders, even the image was not labeled by connected components.
    cellsBorders = Reconstruction.killBorders(cellsMask.getProcessor())
    cellsMask.close()
    cellsMask = ImagePlus("CellsMask", cellsBorders)

    # Nuclei protruding from cell.
    ffcl = FloodFillComponentsLabeling(4, 16)
    labeledNuclei = ImagePlus("LabeledNuclei", ffcl.computeLabels(nucleiMask.getProcessor()))
    nucleiMask.close()
    lostNuclei = ImageCalculator.run(labeledNuclei, cellsMask, "subtract create")
    lostLabels = LabelImages.findAllLabels(lostNuclei)
    ReplaceLabelValues().process(labeledNuclei.getStack(), lostLabels, 0)
    lostNuclei.close()

    # Couples of cell + nuclei (we need both a cell and a nuclei inside)
    labeledCells = ImagePlus("LabeledCells", ffcl.computeLabels(cellsMask.getProcessor()))
    cellsMask.close()
    nucleiMask = labeledNuclei.duplicate()
    nucleiMask.getProcessor().threshold(0)
    finalNuclei = ImageCalculator.run(nucleiMask, labeledCells, "and create")

    cellsLabels  = LabelImages.findAllLabels(labeledCells)
    nucleiLabels = LabelImages.findAllLabels(finalNuclei)
    invalidLbls  = [i for i in cellsLabels if i not in nucleiLabels]
    ReplaceLabelValues().process(labeledCells.getStack(), invalidLbls, 0)

    return finalNuclei, labeledCells


# Pour l'instant, le plugin de segmentation doit avoir été lancé avant ce script.
# On va garder ce fonctionnement pour l'instant car il ne fonctionne qu'en batch, et a des paramètres très précis.
def main():
    # Original images
    inputDirectory  = "/home/benedetti/Documents/projects/11-radial-profiles/images-01"
    # Output directory of "map-organelles"
    outputDirectory = "/home/benedetti/Documents/projects/11-radial-profiles/output"
    content         = os.listdir(outputDirectory)

    for name in content:
        # The output is filled with folders
        resDirPath = os.path.join(outputDirectory, name)
        if not os.path.isdir(resDirPath):
            print("Skiping: " + name)
            continue
        
        # Folders are named after the images with an extra suffix.
        originalPath = os.path.join(inputDirectory, name.replace("_S0", ".tif"))
        if not os.path.isfile(originalPath):
            print("Original not found for: " + name)
            continue

        detectionsPath = os.path.join(resDirPath, "detections.tiff")
        if not os.path.isfile(detectionsPath):
            print("Detection file not found for: " + name)
            continue

        nucleiMask  , cellsMask   = masksFromDetections(detectionsPath)
        nucleiLabels, cellsLabels = cureAndIdentify(nucleiMask, cellsMask)

        # nucleiLabels.show()
        # cellsLabels.show()
        
    return 0

main()


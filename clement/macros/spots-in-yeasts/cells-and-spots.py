from ij import IJ, ImagePlus
from inra.ijpb.label import LabelImages
from ij.plugin import ImageCalculator
import math


def linkCellsSpots(labeledCells, spotsOriginal, spotsPoly, deadMask):
    """
    labeledCells: An ImagePlus instance on 16 bits containing the segmented yeasts.
    spotsOriginal: The original fluo channel for this image.
    spotsPoly: A polygon containing the location of spots across the image.
    deadMask: A binary mask representing the location of dead cells.
    """
    yeasts = []
    LabelImages.remapLabels(labeledCells)
    spots = {}

    # Assigning each spot to its owner cell:
    labelsProc = labeledCells.getProcessor()
    spotsProc  = spotsOriginal.getProcessor()
    for x, y in zip(spotsPoly.xpoints, spotsPoly.ypoints):
        val = labelsProc.get(x, y)
        if val == 0:
            # Spot in the background...
            continue
        spots.setdefault(val, []).append({
            'x': x,
            'y': y,
            'intensity': spotsProc.get(x, y)
        })
    
    # Detecting dead cells:
    allLabels = findAllLabels(labeledCells)
    nbCells   = len(allLabels)

    for label in range(1, nbCells+1):
        production = {}

        # Is it alive ?
        labelMask = ImageProcessor("cellMask", LabelImages.binarize(labeledCells.getProcessor(), label))
        intersect = ImageCalculator.run(labelMask, deadMask, "and")
        isDead    = intersect.getStatistics().histMax > 0
        
        labelMask.close()
        intersect.close()
        
        if isDead:
            continue

        # Processing roundness factor
        isolatedLabel = LabelImages.cropLabel(labeledCells, label, 0)
        circleRadius  = max(isolatedLabel.getWidth(), isolatedLabel.getHeight()) / 2.0
        circleArea    = math.pi * radius * radius
        cellArea      = isolatedLabel.getStatistics().histogram[255]
        circFactor    = cellArea / circleArea

        production['circularityFactor'] = circFactor
        production['area']              = cellArea
        production['nSpots']            = len(spots[label]) if (label in spots) else 0
        production['spots']             = spots[label] if (label in spots) else {}
        yeasts.append(production)

    return yeasts

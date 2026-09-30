from ij import IJ
from ij.plugin import Duplicator
from ij.plugin.filter import RankFilters

SIGNAL_CHANNEL = 1
KINETOCHORES_CHANNEL = 2

def main():
    image = IJ.getImage()
    sliceNr = getInFocusSlice(image)
    image.setPosition(1, sliceNr, 1)
    cellsImage = Duplicator().run(image, SIGNAL_CHANNEL, SIGNAL_CHANNEL, sliceNr, sliceNr), 1, 1)
    segmentCells(cellsImage)
    print(sliceNr)
    
def getInFocusSlice(image):
    signal = Duplicator().run(image, SIGNAL_CHANNEL, SIGNAL_CHANNEL, 1, image.getNSlices(), 1, 1)
    rankFilters = RankFilters()
    stack = signal.getStack()
    stdDeviations = []
    for i in range(1, stack.size()+1):
        processor = stack.getProcessor(i)
        rankFilters.rank(processor, 1.0, RankFilters.VARIANCE)
        stats = processor.getStats()
        stdDeviations.append(stats.stdDev)
    return stdDeviations.index(max(stdDeviations)) + 1            
      
      
def segmentCells(image):
    
    
      
main()
import java
from ij import IJ
from jarray import array

def main():
    STEP = 5
    
    image = IJ.getImage()  
    width, height, nChannels, nSlices, nFrames = image.getDimensions()
    found = True
    counter = 1    
    while found and counter < 11:
        print("processing iteration: ", counter)
        found = False
        processor = image.getProcessor()
        newProcessor = processor.duplicate()
        numberOfChanges = 0
        for x in range(0, width):
            for y in range(0, height):
                value = processor.get(x, y)
                if value == 0:
                    newValue = getMinAboveZeroInNeighborhood(x, y, processor)
                    if newValue == 65536:
                        continue
                    newProcessor.set(x, y, int(max(newValue-STEP, 1)))
                    found = True
                    numberOfChanges = numberOfChanges + 1
        print(str(numberOfChanges) + " pixels changed")               
        image.setProcessor(newProcessor)
        counter = counter + 1
        

def getMinAboveZeroInNeighborhood(x, y, processor):
    imp = processor
    line1 = array([float(0.0), float(0.0) ,float(0.0)], 'd')
    line2 = array([float(0.0), float(0.0) ,float(0.0)], 'd')
    line3 = array([float(0.0), float(0.0) ,float(0.0)], 'd')
    neighbors = array([line1, line2, line3], java.lang.Class.forName("[D"))
    imp.getNeighborhood(x, y, neighbors)
    neighbors = list([list(line) for line in neighbors])
    smallest = 65536
    for line in neighbors:
        for element in line:
            if element == 0.0:
                continue
            if element < smallest:
                smallest = element
    return smallest


main()
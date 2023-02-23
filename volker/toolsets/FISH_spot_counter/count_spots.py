import os
from ij import IJ
from ij.process import ImageConverter
from  ij.process import StackStatistics
from ij.measure import ResultsTable
from  ij.gui import GenericDialog


def main():
    image = IJ.getImage()
    counter = SpotCounter(image)
    if not counter.showDialog():
        return
    counter.countSpots()
    counter.report()
    counter.saveControlImage()
    

class SpotCounter:
                        

    def __init__(self, image):
        IJ.run("FeatureJ Options", "isotropic progress log")
        self.radius = 7
        self.sigma = 0.45
        self.dynamic = 5000
        self.connectivity = 6
        self.image = image
        self.labels = None
        self.numberOfSpots = 0
        
    
    def showDialog(self):
        gd = GenericDialog("Count Spots Options")
        gd.addNumericField("Rolling Ball Radius for background subtraction: ", self.radius)
        gd.addNumericField("Sigma for LoG:", self.sigma);
        gd.addNumericField("Dynamic for ext. maxima:", self.dynamic);
        gd.addNumericField("Connectivity for ext. maxima:", self.connectivity);
        
        gd.showDialog()
        if gd.wasCanceled():
            return False

        self.radius = gd.getNextNumber()
        self.sigma = gd.getNextNumber()
        self.dynamic = gd.getNextNumber()
        self.connectivity = int(gd.getNextNumber())
        return True
    
    
    def countSpots(self):
        imp = self.image.duplicate();
        IJ.run(imp, "Subtract Background...", "rolling={} stack".format(self.radius))
        IJ.run(imp, "FeatureJ Laplacian", "compute smoothing={}".format(self.sigma))
        spotImage = IJ.getImage()
        IJ.run(spotImage, "Invert", "stack")
        ImageConverter.setDoScaling(True)
        IJ.run(spotImage, "16-bit", "")
        IJ.run(spotImage, "Extended Min & Max 3D", "operation=[Extended Maxima] dynamic={} connectivity={}".format(self.dynamic, self.connectivity))
        emaxImage = IJ.getImage();
        IJ.run(emaxImage, "Connected Components Labeling", "connectivity={} type=float".format(self.connectivity));
        self.labels = IJ.getImage()
        self.closeImages(emaxImage, spotImage, imp)
        stats = StackStatistics(self.labels)
        self.numberOfSpots = stats.max
    
    
    def report(self):
        title = "number of spots"
        table = ResultsTable.getResultsTable(title)
        tableIsOpen = False
        if table:
            tableIsOpen = True
        if not tableIsOpen:
            table = ResultsTable()
        table.show(title)
        table.incrementCounter()
        table.addValue("image", self.image.getTitle())
        table.addValue("nr. of spots", self.numberOfSpots)
        table.show(title)
        table.updateResults()
        table = ResultsTable.getResultsTable("Results")
        table.updateResults();
    
    
    def saveControlImage(self):
        path = self.image.getOriginalFileInfo().directory + "/control"
        if not os.path.exists(path):
            os.makedirs(path) 
        IJ.run(self.image, "32-bit", "");
        IJ.run(self.image, "Merge Channels...", "c1=[{labelsTitle}] c4=[{imageTitle}] create".format(labelsTitle = self.labels.getTitle(), imageTitle = self.image.getTitle()))
        mergedImage = IJ.getImage()
        IJ.saveAsTiff(mergedImage, path + "/" + self.labels.getTitle())
            
    
    def closeImages(self, *images):
        for image in images:
            image.changes = False
            image.close()


main()
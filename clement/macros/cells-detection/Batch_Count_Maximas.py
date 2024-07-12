from ij import IJ
from fiji.util.gui import GenericDialogPlus
from ij.plugin.filter import MaximumFinder
import os
from ij.plugin.filter import Filters

class BatchCountMaximas:

    def __init__(self):
        self.files = []
        self.progression = 0.0
        self.root = ""
        self.laplaScale = 6.0
        self.prominance = 150
        self.state = "Not initialized."
        self.count = {}
        self.exportPath = ""


    def checkState(self):
        if not os.path.isdir(self.root):
            self.state = "The provided folder path doesn't exist."
            return False

        if self.laplaScale < 0.5:
            self.state = "The Laplacian's scale is not valid."
            return False

        if self.prominance <= 0:
            self.state = "The prominance is not valid."
            return False

        self.fixExportPath()
        
        return True

    
    def fetchImages(self):
        self.files = [f for f in os.listdir(self.root) if os.path.isfile(os.path.join(self.root, f))]
        self.files.sort()
        return len(self.files) > 0


    def writeToFile(self):
        f = open(self.exportPath, 'w')

        if f.closed:
            self.state = "Failed to create/open: {0}".format(self.exportPath)
            return False
        
        f.write("Name, Count\n")
        keys = sorted(self.count.keys())
        
        for key in keys:
            f.write(", ".join([str(key), str(self.count[key])])+"\n")
        
        f.close()
        return True

    
    def applyOperations(self):
        for f in self.files:
            fullPath = os.path.join(self.root, f)
            img = IJ.openImage(fullPath)

            if img is None:
                continue

            IJ.run(img, "FeatureJ Laplacian", "compute smoothing={0}".format(self.laplaScale))
            laplaTemp = IJ.getImage()
            lapla = laplaTemp.duplicate()
            laplaTemp.close()
            img.close()

            filt = Filters()
            filt.setup("invert", lapla)
            filt.run(lapla.getProcessor())

            poly = MaximumFinder().getMaxima(lapla.getProcessor(), self.prominance, False)
            lapla.close()
            self.count[f] = poly.npoints
        
        return True


    def run(self):
        if not self.displayMenu():
            self.state = "Command was canceled."
            return False
        
        if not self.checkState():
            return False

        if not self.fetchImages():
            self.state = "Failed to fetch files in this folder."
            return False

        if not self.applyOperations():
            return False

        if not self.writeToFile():
            return False
        
        self.state = "DONE."
        return True

    
    def getState(self):
        return self.state


    def fixExportPath(self):
        self.exportPath = self.exportPath.lower()

        if not self.exportPath.endswith('.csv'):
            self.exportPath += ".csv"

        self.exportPath = os.path.join(self.root, self.exportPath)

    
    def display(self):
        IJ.log(self.root)
        IJ.log(self.exportPath)


    def displayMenu(self):
        gui = GenericDialogPlus("Batched Maximas Counting")

        gui.addDirectoryField("Folder: ", "DefaultFolderPath")
        gui.addNumericField("Laplacian scale: ", self.laplaScale)
        gui.addNumericField("Prominance: ", self.prominance)
        gui.addStringField("Export to: ", "untitled.csv")

        gui.showDialog()

        if gui.wasOKed():
            self.root       = gui.getNextString()
            self.laplaScale = gui.getNextNumber()
            self.prominance = gui.getNextNumber()
            self.exportPath = gui.getNextString()
            return True

        return False


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

b = BatchCountMaximas()
b.run()

IJ.log(b.getState())
import os
import urllib2
import sys
from ij import IJ, Menus
from fiji.util.gui import GenericDialogPlus


downloadsList = [
    {
        'name': "movingNGon-package",
        'category': 'PACKAGE',
        'source': "https://raw.githubusercontent.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/master/clement/packages/movingNgon",
        'path': ["movingNgon"],
        'files': [
            "rays.py",
            "movingNgon.py",
            "basicOps.py",
            "basicContours.py",
            "__init__.py"
        ]
    },
    {
        'name': "mdYeasts-package",
        'category': 'PACKAGE',
        'source': "https://raw.githubusercontent.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/master/clement/packages/mdYeasts",
        'path': ["mdYeasts"],
        'files': [
            "userIO.py",
            "makeSegmentation.py",
            "makeNGon.py",
            "__init__.py"
        ]
    },
    {
        'name': "mdYeasts-macro",
        'category': 'MACRO',
        'source': "https://raw.githubusercontent.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/master/clement/macros/md-yeasts",
        'path': ["md-yeasts"],
        'files': [
            "MD_Yeasts.py",
            "MD_Options.py",
            "MD_Export_ROI_Manager.py",
            "MD_Batch_Yeasts.py"
        ]
    },
    {
        'name': "mdYeasts-toolset",
        'category': 'TOOLSET',
        'source': "https://raw.githubusercontent.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/master/clement/toolsets/md_yeasts",
        'path': [],
        'files': [
            "MD Yeasts.ijm"
        ]
    }
]


class Wizard:

    def __init__(self, dl):
        self.toolsetsDir = os.path.join(IJ.getDirectory("macros"), "toolsets")
        self.macrosDir   = IJ.getDirectory("plugins")
        self.packagesDir = None
        self.status      = "Installation failed."
        self.downloads   = dl

    
    def getStatus(self):
        return self.status

    
    def checkMorphoLibJ(self):
        try:
            from inra.ijpb.label.edit import ReplaceLabelValues
        except:
            IJ.log("MorphoLibJ is not installed (Site: IJPB-plugins)")
            return False
        
        IJ.log("MorphoLibJ detected")
        return True
    

    def checkFeatureJ(self):
        try:
            from featurej import FJ_Laplacian
        except:
            IJ.log("FeatureJ is not installed (Site: ImageScience)")
            return False
        
        IJ.log("FeatureJ detected")
        return True

    
    def getPackagesDir(self):
        if self.packagesDir is not None:
            return self.packagesDir

        if len(sys.path) == 0:
            IJ.log("Failed to get the Python path")
            return None
        
        path = sys.path[0]
        compos = path.split(os.path.sep)
        
        for i in range(len(compos)+1):
            current = os.path.sep.join(compos[0:i])

            if len(current) == 0:
                continue

            if os.path.isdir(current):
                continue

            os.mkdir(current)
            IJ.log("Created folder: {0}".format(current))

        self.packagesDir = os.path.sep.join(compos)
        return self.packagesDir

    
    def getMacrosDir(self):
        return self.macrosDir


    def getToolsetsDir(self):
        return self.toolsetsDir
    

    def getDestination(self, block):
        if block['category'] == 'PACKAGE':
            return self.getPackagesDir()
        
        if block['category'] == 'MACRO':
            return self.getMacrosDir()

        if block['category'] == 'TOOLSET':
            return self.getToolsetsDir()

        return None
    

    def makeFullPath(self, rootPath, chunks):
        fullPath = rootPath
        
        for chunk in chunks:
            fullPath = os.path.join(fullPath, chunk)
            if not os.path.isdir(fullPath):
                os.mkdir(fullPath)

        return fullPath

    
    def downloadElements(self):
        for block in self.downloads:

            IJ.log("= = = Installing {0} = = =".format(block['name']))
            destination = self.getDestination(block)

            if destination is None:
                IJ.log("Failed to find destination for {0}. Abort.".format(block['name']))
                return False

            urlRoot = block['source']
            localDestination = self.makeFullPath(destination, block['path'])

            if (localDestination is None) or (not os.path.isdir(localDestination)):
                IJ.log("Failed to reach")
                return False

            for fi in block['files']:
                targetPath = os.path.join(localDestination, fi)
                fullURL    = "{0}/{1}".format(urlRoot, fi.replace(" ", "%20"))
                IJ.log("Fetching {0}".format(fullURL))

                with open(targetPath, 'wb') as f:
                    f.write(urllib2.urlopen(fullURL).read())
                    f.close()
                
                IJ.log("Downloaded {0}".format(targetPath))

        IJ.log("All files downloaded.")
        return True
            


    def run(self):
        if not self.checkMorphoLibJ():
            return False

        if not self.checkFeatureJ():
            return False

        if not self.downloadElements():
            return False
        
        self.status = "Installation successful. Restart Fiji."
        return True



w = Wizard(downloadsList)
w.run()
IJ.log(w.getStatus())


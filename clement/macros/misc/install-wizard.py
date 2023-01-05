from ij import IJ, Menus
import os
import urllib2
import sys

downloads = {
    "randomLUT-package": [
        {
        'path': "mriGeneral",
        'name': "RandomLUT.py",
        'url': "https://raw.githubusercontent.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/master/clement/packages/mriGeneral/RandomLUT.py"
        },
        {
            'path': "mriGeneral",
            'name': "__init__.py",
            'url': "https://raw.githubusercontent.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/master/clement/packages/mriGeneral/__init__.py"
        }
    ],
    "randomLUT-macro": [
        {
            'path': "general",
            'name': "Random_LUT.py",
            'url': "https://raw.githubusercontent.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/master/clement/macros/general/Random_LUT.py"
        }
    ],
    "randomLUT-toolset": [
        {
            'path': "",
            'name': "Random LUT.ijm",
            'url': "https://raw.githubusercontent.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/master/clement/toolsets/general/Random%20LUT.ijm"
        }
    ],
    "nucleiTools-package": [
        {
            'path': "nucleiTools",
            'name': "CountNuclei.py",
            'url': "https://raw.githubusercontent.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/master/clement/packages/nucleiTools/CountNuclei.py"
        },
        {
            'path': "nucleiTools",
            'name': "__init__.py",
            'url': "https://raw.githubusercontent.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/master/clement/packages/nucleiTools/__init__.py"
        }
    ],
    "nucleiTools-macro": [
        {
            'path': "solange-detection",
            'name': "Batch_Count_Maximas.py",
            'url': "https://raw.githubusercontent.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/master/clement/macros/solange-detection/Batch_Count_Maximas.py"
        },
        {
            'path': "solange-detection",
            'name': "Count_Nuclei.py",
            'url': "https://raw.githubusercontent.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/master/clement/macros/solange-detection/Count_Nuclei.py"
        },
        {
            'path': "solange-detection",
            'name': "Points_From_Labels.py",
            'url': "https://raw.githubusercontent.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/master/clement/macros/solange-detection/Points_From_Labels.py"
        },
        {
            'path': "solange-detection",
            'name': "Update_CSV.py",
            'url': "https://raw.githubusercontent.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/master/clement/macros/solange-detection/Update_CSV.py"
        }
    ],
    "nucleiTools-toolset": [
        {
            'path': "",
            'name': "Count Nuclei.ijm",
            'url': "https://raw.githubusercontent.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/master/clement/toolsets/solange_counting/Count%20Nuclei.ijm"
        }
    ]
}


class Wizard:


    def __init__(self):
        self.action      = 'INSTALL'
        self.actions     = ['INSTALL', 'UNINSTALL']
        self.status      = "Installation failed."
        self.packagesDir = None
        self.macrosDir   = IJ.getDirectory("plugins")
        self.toolsetsDir = os.path.join(IJ.getDirectory("macros"), "toolsets")

    
    def getStatus(self):
        return self.status


    def askOptions(self):
        pass


    def checkLabkit(self):
        try:
            from sc.fiji.labkit.ui.plugin import SegmentImageWithLabkitPlugin
        except:
            IJ.log("LabKit is not installed")
            return False
        
        IJ.log("LabKit detected")
        return True
    

    def checkRandomLUT(self):
        if Menus.getCommands().get("Random LUT") is None:
            IJ.log("Random LUT is missing.")
            return False

        IJ.log("Random LUT found")
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

    
    def downloadElements(self, id, location):
        for f in downloads[id]:
            folder = os.path.join(location, f['path'])
            fullPath = os.path.join(folder, f['name'])

            if not os.path.isdir(folder):
                os.mkdir(folder)

            with open(fullPath,'wb') as fi:
                fi.write(urllib2.urlopen(f['url']).read())
                fi.close()
            
            IJ.log("Downloaded {0}".format(fullPath))
            

    def getRandomLUT(self):
        
        pdir = self.getPackagesDir()
        if pdir is None:
            IJ.log("Can't install Random LUT without package folder.")
            return False

        self.downloadElements("randomLUT-package", pdir)
        self.downloadElements("randomLUT-macro", self.getMacrosDir())
        self.downloadElements("randomLUT-toolset", self.getToolsetsDir())

        IJ.log("Random LUT successfully installed.")

        return True


    def getNucleiTools(self):
        pdir = self.getPackagesDir()
        if pdir is None:
            IJ.log("Can't install Nuclei Tools without package folder.")
            return False

        self.downloadElements("nucleiTools-package", pdir)
        self.downloadElements("nucleiTools-macro", self.getMacrosDir())
        self.downloadElements("nucleiTools-toolset", self.getToolsetsDir())

        IJ.log("Nuclei Tools successfully installed.")

        return True


    def checkNucleiTools(self):
        if Menus.getCommands().get("Count Nuclei") is None:
            IJ.log("Nuclei Tools is missing.")
            return False

        IJ.log("Nuclei Tools found")
        return True


    def run(self):
        if not self.checkLabkit():
            return False

        if (not self.checkRandomLUT()) and (not self.getRandomLUT()):
            return False

        if (not self.checkNucleiTools()) and (not self.getNucleiTools()):
            return False
        
        self.status = "Installation successful. Restart Fiji."
        return True



w = Wizard()
w.run()
IJ.log(w.getStatus())


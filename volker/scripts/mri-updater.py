import os
import shutil
from urllib import urlopen
from  zipfile import ZipFile
from ij import IJ
from ij import Prefs
from ij.gui import GenericDialog


class Updater:


    def __init__(self):
        self.tool = "spine_analyzer" 
        self.folder = "Spine-Analyzer"
        self.author = "volker"
        self.libPath = IJ.getDirectory("imagej") + "/jars/Lib/"
        self.pythonModulesPath = 'fr/cnrs/mri/cialib/'
        self.tag = None
        
        self.readPreferences()          
            
        self.host = "https://github.com/"
        self.baseUrl = "MontpellierRessourcesImagerie/imagej_macros_and_scripts/"
        repositoryUrl = self.host + self.baseUrl 
        self.raw = "https://raw.githubusercontent.com"
        self.component = repositoryUrl + "/tree/<tag>/" + self.author + "/toolsets/" + self.tool
        self.tagsUrl = repositoryUrl + "tags"
        self.archiveUrl = repositoryUrl + 'archive/refs/tags/'
        self.downloadBaseUrl = repositoryUrl + "/releases/tag/"
        self.sourceFolder = ""        
        self.pluginsToolDir = IJ.getDirectory("plugins") + self.folder + "/"        
        self.toolsetsDir = IJ.getDirectory("macros") +  "toolsets/"
        
        if not os.path.exists(self.pluginsToolDir):
            os.makedirs(self.pluginsToolDir)
        if not os.path.exists(self.libPath + self.pythonModulesPath):
            os.makedirs(self.libPath + self.pythonModulesPath)
        moduleFolders = self.pythonModulesPath.split("/")
        currentPath = self.libPath
        for folder in moduleFolders:
            currentPath =  currentPath + "/" + folder
            open(currentPath + "/__init__.py", 'a').close()
        

    def runUpdate(self):    
        self.tag = self.getTargetVersionFromUser()
        if not self.tag:
            IJ.log("No version selected, update canceled...")
            return
        self.downloadTagFromGithub(self.tag)
        self.installTool()
        self.writeVersionInfo()
        IJ.log("Update finished, please restart ImageJ!")
        IJ.showMessage("Update finished, please restart ImageJ!")
    
        
    def writeVersionInfo(self):
        with open(self.pluginsToolDir + "version.txt", 'w') as file:
            file.write(self.tag)
    
    
    def installTool(self):
        files = [self.sourceFolder + f for f in os.listdir(self.sourceFolder ) if os.path.isfile(self.sourceFolder+f)]
        for file in files:
            if self.isToolset(file):                
                IJ.log("writing toolset " + file + " to " + self.toolsetsDir);
                shutil.copy(file, self.toolsetsDir)
                continue
            if self.isModule(file):     
                IJ.log("writing python module " + file + " to " + self.libPath + self.pythonModulesPath);
                shutil.copy(file, self.libPath + self.pythonModulesPath)
                continue
            IJ.log("writing file " + file + " to " + self.pluginsToolDir);
            shutil.copy(file, self.pluginsToolDir)
            
                    
    def isToolset(self, file):
        result = True
        content = IJ.openAsString(file)
        result = result and file.endswith('.ijm')
        result = result and 'macro "' in content
        return result
        
        
    def isMacroCommand(self, file):
        result = True
        content = IJ.openAsString(file)
        result = result and file.endswith('.ijm')
        result = result and not 'macro "' in content
        return result
    
    
    def isScript(self, file):
        result = True
        content = IJ.openAsString(file)
        result = result and file.endswith('.py')
        result = result and "def main():" in content
        return result
        
        
    def isModule(self, file):
        result = True
        content = IJ.openAsString(file)
        result = result and file.endswith('.py')
        result = result and not "def main():" in content
        return result
        
    
    def downloadTagFromGithub(self, tag):
        downloadUrl = self.archiveUrl + tag + ".zip"
        tmpFolder = IJ.getDirectory("temp")
        outputFilePath = tmpFolder + "/" + "imagej_macros_and_scripts" + "_" + tag + ".zip"
        response = urlopen(downloadUrl)
        CHUNK = 16 * 1024
        with open(outputFilePath, 'wb') as f:
            while True:
                chunk = response.read(CHUNK)
                if not chunk:
                    break
                f.write(chunk)
        with ZipFile(outputFilePath, 'r') as zObject:
            zObject.extractall(path=tmpFolder)
        self.sourceFolder = IJ.getDirectory("temp") + "imagej_macros_and_scripts" + "-" + tag[1:] + "/" + self.author + "/toolsets/" + self.tool + "/"
        
    
    def getTargetVersionFromUser(self):
        currentVersion = self.getCurrentVersion()
        tags = self.getTags()
        if len(tags) < 1:
            IJ.log("No versions found")
            return False
        self.tag = tags[0]
        gd = GenericDialog(self.tool + " - Install or Update")
        gd.addMessage("Installed versions: " + str(currentVersion))
        gd.addChoice("version: ", tags, self.tag)
        gd.showDialog()
        if gd.wasCanceled():
            return False
        self.tag = gd.getNextChoice()
        return self.tag
    
    
    def getTags(self):
        IJ.log("Getting versions from github...")
        tagsPage = IJ.openUrlAsString(self.tagsUrl)
        lines = tagsPage.split("\n")
        tags = [];
        for line in lines:
            if self.baseUrl + "releases/tag/" in line:
                parts = line.split("/")
                parts = parts[5].split('"')
                tag = parts[0]
                if not tag in tags:
                    tags.append(tag)
        tagsWithTool = []
        for tag in tags:
            url = self.component.replace("<tag>", tag)
            answer = IJ.openUrlAsString(url)
            if not answer.startswith("<Error"):
                tagsWithTool.append(tag)
        return tagsWithTool
    
        
    def readPreferences(self):
        toolToBeUpdated = Prefs.get("mri.update.tool", "")
        updateFolder = Prefs.get("mri.update.folder", "")
        updateAuthor = Prefs.get("mri.update.author", "")
        updateModulesFolder = Prefs.get("mri.update.modules", "")        
        if toolToBeUpdated:
            self.tool = toolToBeUpdated
        if updateFolder:
            self.folder = updateFolder
        if updateAuthor: 
            self.autor = updateAuthor
        if updateModulesFolder:
           self.pythonModulesPath = updateModulesFolder
    
        
    def getCurrentVersion(self):
        pluginsDir = IJ.getDirectory("plugins")
        pluginsToolDir = pluginsDir + self.folder + "/"
        if not os.path.exists(pluginsToolDir):
            return None    
        if not os.path.exists(pluginsToolDir + "version.txt"):
            return None    
        version = IJ.openAsString(pluginsToolDir + "version.txt")
        return version



if __name__ == "__main__":
    Updater().runUpdate()


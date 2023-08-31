import os
from urllib import urlopen
from  zipfile import ZipFile
from ij import IJ
from ij import Prefs
from ij.gui import GenericDialog
import time 


class Updater:


    def __init__(self):
        self.tool = "width_profile_tools" 
        self.folder = "Width-Profile-Tools"
        self.author = "volker"
        self.pythonModulesPath = IJ.getDirectory("imagej") + '/jars/Lib/fr/cnrs/mri/cialib/'
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
                

    def runUpdate(self):    
        self.tag = self.getTargetVersionFromUser()
        self.downloadTagFromGithub(self.tag);
        
        IJ.showMessage("Update finished, please restart ImageJ!");    
    
    
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
        
        
    
    def getTargetVersionFromUser(self):
        currentVersion = self.getCurrentVersion()
        tags = self.getTags()
        self.tag = tags[0]
        gd = GenericDialog("Spine Analyzer - Install or Update")
        gd.addMessage("Installed versions: " + currentVersion)
        gd.addChoice("version: ", tags, self.tag)
        gd.showDialog()
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
        return tagsWithTool;
    
    
    
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


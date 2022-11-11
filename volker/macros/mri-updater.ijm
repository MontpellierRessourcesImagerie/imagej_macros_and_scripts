var TOOL = "width_profile_tools";
var FOLDER = "Width-Profile-Tools";
var AUTHOR = "volker";

var HOST = "https://github.com";
var RAW = "https://raw.githubusercontent.com";
var COMPONENT = HOST + "/MontpellierRessourcesImagerie/imagej_macros_and_scripts/tree/<tag>/"+AUTHOR+"/toolsets/" + TOOL;
var TAGS_URL = 'https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/tags';


toolToBeUpdated = call("ij.Prefs.get", "mri.update.tool", "");
updateFolder = call("ij.Prefs.get", "mri.update.folder", "");
updateAuthor = call("ij.Prefs.get", "mri.update.author", "");

if (toolToBeUpdated != "" && updateFolder != "" && updateAuthor != "") {
    TOOL = toolToBeUpdated;
    FOLDER = updateFolder;
    AUTHOR = updateAuthor;
}

currentVersion = getCurrentVersion();

tags = getTags(COMPONENT, TAGS_URL);
tag = tags[0];
Dialog.create("Update " + TOOL);
Dialog.addMessage("Installed version: " + currentVersion);
Dialog.addChoice("version: ", tags, tag);
Dialog.show();
tag = Dialog.getChoice();
files = getFiles(tag);
download(files, tag);

showMessage("Update finished, please restart ImageJ!");

function getCurrentVersion() {
    pluginsDir = getDirectory("plugins");
    pluginsToolDir = pluginsDir + FOLDER + "/";
    if (!File.exists(pluginsToolDir)) {
        return "None";    
    } 
    if (!File.exists(pluginsToolDir + "version.txt")) {
        return "None";    
    }
    version = File.openAsString(pluginsToolDir + "version.txt");
    return version;
}

function download(files, tag) {
    raw_url = replace(COMPONENT, HOST, RAW);
    raw_url = replace(raw_url, "tree/<tag>", tag);
    raw_url = raw_url + "/";
    
    pluginsDir = getDirectory("plugins");
    pluginsToolDir = pluginsDir + FOLDER + "/";
    toolsetsDir = getDirectory("macros");
    toolsetsDir = toolsetsDir + "toolsets/";
    
    if (!File.exists(pluginsToolDir)) {
        File.makeDirectory(pluginsToolDir);
    }
    for (i = 0; i < files.length; i++) {
        file = files[i];
        url = raw_url + file;
        print("Downloading " + url);
        content = File.openUrlAsString(url);
        if (indexOf(content, 'macro "') != -1) {
            File.saveString(content, toolsetsDir + file);
        } else {
            File.saveString(content, pluginsToolDir + file);
        }
    }
    File.saveString(tag, pluginsToolDir + "version.txt");
}


function getFiles(tag) {
    print("Getting files...");
    url = replace(COMPONENT, "tree/<tag>", "blob/" + tag);
    content = File.openUrlAsString(url);
    searchString = replace(url, HOST, "");
    lines = split(content, "\n");
    files = newArray(0);
    for (i = 0; i < lines.length; i++) {
        line = lines[i];
        if (indexOf(line, searchString) != -1) {
            parts = split(line, "/");
            parts = split(parts[8], '"');
            file = parts[0];
            files = Array.concat(files, file);
        }
    }
    return files;
}


function getTags(component, tagsURL) { 
    print("Getting versions from github...");
    tagsPage = File.openUrlAsString(tagsURL);
    lines = split(tagsPage, "\n");
    tags = newArray(0);
    for (i = 0; i < lines.length; i++) {
        line = lines[i];
        if (indexOf(line, "/MontpellierRessourcesImagerie/imagej_macros_and_scripts/releases/tag/") != -1 ) {
            parts = split(line, "/");
            parts = split(parts[5], '"');
            tag = parts[0];
            if (!contains(tags, tag)) tags = Array.concat(tags, parts[0]);
        }
    }
    tagsWithTool = newArray(0);
    for (i = 0; i < tags.length; i++) {
        tag = tags[i];
        url = replace(component, "<tag>", tag);
        answer = File.openUrlAsString(url);
        if (!startsWith(answer, "<Error")) {
            tagsWithTool = Array.concat(tagsWithTool, tag);
        }
    }
    return tagsWithTool;   
}


function contains(anArray, aString) {
    for (i = 0; i < anArray.length; i++) {
        if (anArray[i] == aString) {
            return true
        }
    }
    return false;
}

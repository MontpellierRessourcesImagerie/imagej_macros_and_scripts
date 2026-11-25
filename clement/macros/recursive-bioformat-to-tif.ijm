var extension = "";
var inputRoot = "";
var outputRoot = "";
var exportProperties = false;
var extCount = 0;


function scanDirectory(currentDir) {
    list = getFileList(currentDir);

    for (i = 0; i < list.length; i++) {
        item = list[i];

        if (endsWith(item, "/")) {
            folderName = substring(item, 0, lengthOf(item) - 1);

            if (startsWith(folderName, "_")) {
                continue;
            }

            scanDirectory(currentDir + item);

        } else if (endsWith(toLowerCase(item), extension)) {
            processExtFile(currentDir + item);
        }
    }
}

function processExtFile(extPath) {
    extCount++;

    relativePath = substring(extPath, lengthOf(inputRoot));

    relativeDir = File.getDirectory(extPath);
    relativeDir = substring(relativeDir, lengthOf(inputRoot));
    outputDir = outputRoot + relativeDir;

    if (!File.exists(outputDir)) {
        File.makeDirectory(outputDir);
        ensureDirectoryExists(outputDir);
    }

    fileName = File.getName(extPath);
    print("[" + extCount + "] Trouvé : " + extPath);
    outputFileName = replace(fileName, extension, ".tif");
    output_path = outputDir + outputFileName;
    print("    -> Sortie prévue dans : " + output_path);

    run("Bio-Formats", "open=["+extPath+"] color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
    saveAs("TIFF", output_path);
    if (exportProperties) {
        print("!!! "+output_path);
        propertiesAsJson(output_path);
    }
    run("Close All");
}

function ensureDirectoryExists(dir) {
    if (File.exists(dir)) {
        return;
    }
    parent = File.getParent(dir);
    if (!File.exists(parent)) {
        ensureDirectoryExists(parent);
    }
    File.makeDirectory(dir);
}

function propertiesAsJson(output_tif_path) {
    getVoxelSize(width, height, depth, unit);
    buffer = "";
    buffer += "{";
    buffer += "\"x\": " + width + ", ";
    buffer += "\"y\": " + height + ", ";
    buffer += "\"z\": " + depth + ", ";
    buffer += "\"unit\": \"" + unit + "\"";
    buffer += "}";
    output_path = replace(output_tif_path, "\\.tif", ".json");
    print(">>> "+output_path);
    File.saveString(buffer, output_path);
    print("    -> Propriétés sauvegardées dans : " + output_path);
    return buffer;
}

function askSettings() {
    Dialog.create("Paramètres");
    Dialog.addString("Extension des images", ".nd2");
    Dialog.addDirectory("Dossier racine des images", "");
    Dialog.addDirectory("Dossier racine de sortie", "");
    Dialog.addCheckbox("Exporter les propriétés?", false);
    Dialog.show();
    extension = Dialog.getString();
    inputRoot = Dialog.getString();
    outputRoot = Dialog.getString();
    exportProperties = Dialog.getCheckbox();
}

function main() {
	setBatchMode("hide");
    askSettings();

    if (!startsWith(extension, ".")) {
        extension = "." + extension;
    }

    if (inputRoot == "" || outputRoot == "") {
        exit("Sélection annulée, arrêt de la macro.");
    }

    print("=== Début du scan ===");
    print("Entrée  : " + inputRoot);
    print("Sortie  : " + outputRoot);
    print("----------------------------------------");

    extCount = 0;
    scanDirectory(inputRoot);

    print("----------------------------------------");
    print("=== Scan terminé : " + extCount + " fichier(s) " + extension + " trouvé(s) ===");
    setBatchMode("exit and display");
}

main();
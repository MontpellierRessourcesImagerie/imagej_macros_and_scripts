
// Cette macro permet de faire une vérification des MIP obtenus avec la macro "Flo_stackFocus_MIP"
//     On sélectionne le fichier MIP à vérifier, puis le fichier Raw correspondant
//     Chaque MIP s'ouvre un par un
//     Si MIP OK, on passe au MIP suivant
//     Si MIP pas OK, la macro ouvre le Raw correspondant et attend que l'utilisateur décide de l'image à focus
//         Un nouveau MIP (-3 +3) est fait et enregistré à la place du mauvais


function main() {
    
    redSuffix   = getString("redSuffix", "");                  // Suffix of red files
    greenSuffix = getString("greenSuffix", "");                // Suffix of green files
    redMIPDir   = getDirectory("Choose_MIP_Source Directory"); // Output of MIPs (2-MIP)
    rawDir      = getDirectory("Choose_Raw_Source Directory"); // Raw images directory
    slicesTol   = getNumber("Slices tolerance", 5);            // Number of slices taken to the left and right of the most in focus.

    splitted    = split(redSuffix, ".");
    redMIPDir   = joinPath(redMIPDir, splitted[0]);

    // Tout fermer avant de lancer la macro
    run("Close All");

    list1 = getFileList(redMIPDir);
    list2 = getFileList(rawDir);

    // Boucle pour ouvrir un par un les MIP et les vérifier
    for (i = 0; i < list1.length; i++) {
        mipTitle = list1[i];
        open(joinPath(redMIPDir, mipTitle));
        IJ.log("Currently checking: " + getTitle());
        run("Enhance Contrast", "saturated=0.35");

        //Demander si le focus est OK. Si non, demande l'image où faire le focus, puis fait un MIP -3 +3 de cette nouvelle image et la sauvegarde
        waitForUser("[Shift + OK]: Focus is bad.\n[OK]: Focus is good.");
        focusOk = !isKeyDown("shift");
        if (focusOk) {
            close();
            continue; // Z suivant
        }

        // Ouvir la meme mais avec MIP_ en moins = Raw
        rawTitle = getFileWithCase(list2, replace(mipTitle, "MIP_", ""));
        open(joinPath(rawDir, rawTitle));
        run("Enhance Contrast", "saturated=0.35");

        waitForUser("Select the Z focus");
        slice = getSliceNumber();
        mipProjectAroundFocus(slice);
        save(joinPath(redMIPDir, mipTitle));
        
        parts = split(redSuffix, ".");
        redChannelName = parts[0];
        parts = split(greenSuffix, ".");
        greenChannelName = parts[0];

        greenMIPDir = replace(redMIPDir, redChannelName, greenChannelName);

        if (File.isDirectory(greenMIPDir)) {
            rawTitle = replace(rawTitle, redChannelName, greenChannelName);
            open(joinPath(rawDir, rawTitle));
            mipProjectAroundFocus(slice);

            mipTitle = replace(mipTitle, redChannelName, greenChannelName);
            save(joinPath(greenMIPDir, mipTitle));
        }
        run("Close All"); 
    }
}


function getFileWithCase(namesList, name) {
    for (i = 0 ; i < namesList.length ; i++) {
        t1 = toLowerCase(name);
        t2 = toLowerCase(namesList[i]);
        if (t1.matches(t2)) {
            return namesList[i];
        }
    }
    return "-";
}

// Joins a new element to a path, considering that the first part doesn't necessarily ends with the path separator.
function joinPath(parent, leaf) {
    if (parent.endsWith(File.separator)) {
        return parent + leaf;
    } else {
        return parent + File.separator + leaf;
    }
}

function mipProjectAroundFocus(slice) {
    min = maxOf(slice - slicesTol, 1);
    max = minOf(slice + slicesTol, nSlices);
    run("Z Project...", "start="+min+" stop="+max+" projection=[Max Intensity]");
}


main();
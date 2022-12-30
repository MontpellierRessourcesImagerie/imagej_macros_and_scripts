//Cette macro permet de faire une vérification des MIP obtenus avec la macro "Flo_stackFocus_MIP"
	//On sélectionne le fichier MIP à vérifier, puis le fichier Raw correspondant
	//Chaque MIP s'ouvre un par un
	//Si MIP OK, on passe au MIP suivant
	//Si MIP pas OK, la macro ouvre le Raw correspondant et attend que l'utilisateur décide de l'image à focus
		//Un nouveau MIP (-3 +3) est fait et enregistré à la place du mauvais

macro "Verif MIP" {

    redSuffix = "w1CY3.tif";
    greenSuffix = "w2GFP.tif";

    //Tout fermer avant de lancer la macro
    run("Close All");

    // Choisir le fichier MIP et le fichier Raw correspondant
    redMIPDir = getDirectory("Choose MIP_Source Directory");
    rawDir = getDirectory("Choose Raw_Source Directory");

    list1 = getFileList(redMIPDir);
    list2 = getFileList(rawDir);

    // Boucle pour ouvrir un par un les MIP et les vérifier
    for (i = 0; i < list1.length; i++) {
        mipTitle = list1[i];
        open(redMIPDir + mipTitle);
        
        run("Enhance Contrast", "saturated=0.35");

        //Demander si le focus est OK. Si non, demande l'image où faire le focus, puis fait un MIP -3 +3 de cette nouvelle image et la sauvegarde
        focusOk = askUserIfMipOK();
        if(focusOk){
            //Z suivant
            close();
            continue;
        }

        //Ouvir la meme mais avec MIP_ en moins = Raw
        rawTitle = replace(mipTitle,"MIP_","");
        open(rawDir + rawTitle);
        run("Enhance Contrast", "saturated=0.35");
        waitForUser("Select the Z focus");
        slice = getSliceNumber();
        mipProjectAroundFocus(slice);
        save(redMIPDir+mipTitle);
        
        parts = split(redSuffix, ".");
        redChannelName = parts[0];
        parts = split(greenSuffix, ".");
        greenChannelName = parts[0];
        rawTitle = replace(rawTitle, redChannelName, greenChannelName);
        open(rawDir + rawTitle);
        mipProjectAroundFocus(slice);
        mipTitle = replace(mipTitle, redChannelName, greenChannelName);
        greenMIPDir = replace(redMIPDir, redChannelName, greenChannelName);
        save(greenMIPDir+mipTitle);
        run("Close All"); 
    }
}

function mipProjectAroundFocus(slice) {
    name=getTitle();
    min=maxOf(slice-1, 1);
    max = minOf(slice+1, nSlices);
    run("Z Project...", "start="+min+" stop="+max+" projection=[Max Intensity]");
}

//Boîte de dialogue utilisée dans la macro :
function askUserIfMipOK(){
    Dialog.createNonBlocking("Validate Mip ?")
    Dialog.addCheckbox("Focus Correct", true);
    Dialog.show();
    return Dialog.getCheckbox();
}

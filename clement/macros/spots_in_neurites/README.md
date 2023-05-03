
# Spots in neurites

This is a toolbar aggregating several macros (written in ImageJ's macro language) triggered and articulated through Python scripts.

Settings are managed by a dedicated script, and can be exported and loaded as we need them.

A part of the macros is located in the subsection "clement/macros":
    - "Neurons_Spots.ijm"
    - "stack-focus_mip.ijm"
    - "Verif_Segmentation.ijm"
    - "Verif_Spots.ijm"

And the other part is in "leo/macros":
    - "verif_mip.ijm"
    - "measure-intensity-in-nucleus.ijm"

The following ImageJ plugins are required:
    - ComDet
    - Find_focused_slices

For the segmentation part, you will need some pieces of the dl4mic plugin (https://github.com/MontpellierRessourcesImagerie/dl4mic/releases).
You will also need an installation of miniconda.



Files to pick from dl4mic:
    - "environment.yml" if you are on Linux/Mac
    - "environment_win.yml" if you are on Windows (pfff...)
    - Tout le package dl4mic


Common sources of errors:
    - The file extension varies from a file to another and doesn't match the one provided in the settings (that problem is quite often observed on Windows users, where file extension is hidden and can't see that a mix of ".tif" and ".TIF" is present.)

# Manual install

1. Download and unzip the folder https://dev.mri.cnrs.fr/attachments/download/2962/spotsInNeurites.zip
2. Move this folder (not just its content) in the Fiji's folder (it should be named Fiji.app).
3. Aller récupérer le fichier "clement/toolsets/assemblage_audrey/Spots in neurites.ijm" et le placer dans "macro/toolsets" de Fiji.
4. Prendre le dossier "clement/macros/spots_in_neurites" et le placer dans "plugins" de Fiji.
5. Dans les macros de Léo, aller récupérer "stack-focus_mip.ijm" et "verif_mip.ijm" et les placer dans le dossier "spots_in_neurites" de l'étape d'avant.
6. Prendre le dossier "clement/packages/spotsInNeurites" et le placer dans "jars/Lib" du dossier de Fiji. Le dossier "Lib" peut ne pas exister, il faut le créer.
7. Récupérer les plugins ComDet et Find_focused_slices, et les mettre dans le dossier de plugins d'ImageJ.
8. Si ce n'est pas encore fait, il faut installer miniconda. Faire une copie des fichiers de miniconda au cas où on fail l'installation.
9. Créer l'environnement avec le bon fichier yml en utilisant la commande: "conda env create -f environment.yml".
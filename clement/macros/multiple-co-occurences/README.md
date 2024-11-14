# Multiple co-occurrences

This set of scripts aims to segment blobs/spots in 3D over several channels (with LabKit)
Then, co-occurences are processed in all combinations of channels.
Classifiers must be named "c1.classifier", "c2.classifier", ... for every channel you want to segment and have to be placed in a folder.
For each image, channels will be split and segmented in a new folder.
Each mask will be named "c1.tif", "c2.tif", ...
These folders will be the source of the second script.

Find some examples of classifiers:
- [2064](https://dev.mri.cnrs.fr/attachments/download/3483/2064-classifiers.zip)
- [2068](https://dev.mri.cnrs.fr/attachments/download/3570/classifiers.zip)

---

The method is based on the intersection of masks to count co-occurences.

## Requirements

- LabKit (package name: `LabKit`)
- MorphoLibJ (package name: `IJPB-plugins`)

## Optional

- Python + CellPose

## Usage

### 1. Segment spots/blobs (main workflow)

1. Place all your images in a folder and open `make-masks.py` in Fiji.
2. Fill the variables (`_CLASSIFIERS_PATH`, `_SOURCES_FOLDER`, `_OUTPUT_FOLDER` and `_EXTENSION`)
3. Click run.
4. After the Logs window displayed "DONE.", you will find the segmentation masks in the output folder

### 2. Find co-occurences (main workflow)

1. Open the script `find-co_occ.py`.
2. Fill the `_TABLE_NAME` and `_INPUT_FOLDER` variables.
3. Wait for the Logs window to show "DONE."
4. A result table should contain the count of every combination.

### 3. Segment nuclei (side workflow)

1. Créer un dossier vide "mips" qui va recevoir les z projections des noyaux.
2. Ouvrir la macro "make-mips.ijm"
- `input` = la ou sont les CZI
- `mip` = le nouveau dossier vide "mip"
- `nuclei channel` = l'index du channel ou sont les noyaux (commence à 1)
- `extension` = extension des images dans le dossiers d'inputs
3. Lancer la macro et attendre le "DONE."
4. Ouvrir dans n'import quel éditeur de texte le script "run-cellpose.py"
- `mip folder` = dossier dans le quel on vient d'exporter les projections
5. Ouvrir un terminal et lancer l'environnement de cellpose avec la commande "conda activate cellpose-env"
6. Écrire dans le terminal "python && " (ne pas oublier l'espace après la dernière esperluette)
7. Drag'n'drop le script "run-cellpose.py" dans le terminal
8. Appuyer sur Entrée pour lancer le script et attendre que le terminal rende la main.

### 4. Count nuclei (side workflow)

1. Ouvrir le script "count-nuclei.py"
- `_MIP_DIRECTORY` = le dossier qui contient les projections
2. Lancer le script, il devrait mettre à jour la table qui a été ouverte par la macro des co-occurences. 



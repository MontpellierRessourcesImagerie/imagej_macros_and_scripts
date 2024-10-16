
## 1. Install Python and required packages

- Start by installing MiniConda.
- In the list of applications, search for « Anaconda Prompt », and open it. A terminal should open.
- In that terminal, type : `conda create -n astro-env -y python=3.9`. Then press Enter.
- Once the envionment is created, type in the terminal : `pip3 install numpy scipy pymeshlab`, and once again, press Enter.

## 2. Install Blender

- Go on the Blender’s website and download Blender. The download should begin just by clicking on the link. What you just acquired is a zip archive, simply unzip it where you want.

## 3. Get the scripts

- Get to the ![featuresFromIsosurfaces.py](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/blob/master/clement/stand-alones/astrocytesBloodVessels/featuresFromIsosurface.py) and the ![generateBlenderFile.py](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/blob/master/clement/stand-alones/astrocytesBloodVessels/generateBlenderFile.py) from the hierarchy above.
- Download them by clicking on the icon with the arrow pointing down (in the upper right corner).
- On Windows, go in the folder your scripts are. On the menu bar (upper left) go on Display , and then check the option to show file extensions. Verify that Windows didn’t add « .txt » after the « .py » in your scripts name. If it did, rename them by removing the « .txt »

## 4. Run the scripts

- Start by opening `featuresFromIsosurfaces.py` with notepad, or your favorite raw text editor (not Word for example, that doesn’t produce raw text)
- In there, you should see a line starting with `state = {`, this is the begining of the configuration, you will have to edit it. Beware to not remove the quotes while editing it. Also, Windows paths are written with \, but in the Python script, you should replace all the \ by simple / (to avoid problems)
    - `outputDirectory` : The path to which everything produced by the script will be written. You should provide the path of an empty folder.
    - `target` : Here you can provide either the path of a `.wrl` (to process only that mesh) or the path of a folder containing only `.wrl` files (to process all of them at the same time).
    - The exports : `{}` can remain untouched.
    - `blenderPath` : In the Blender folder that you unzipped previously, you should find an application simply named « blender ». It is the path of this application that you must copy here.
    - `blenderScript` : The path of the other script (generateBlenderFile.py)
    - Now, you can save and close the script.
    - Go back in your anaconda terminal, type `python ` with a space at the end, and then drag and drop the script `featuresFromIsosurface.py` in the terminal. You can now press the Enter key.
    - At the end of the execution, the terminal will display a list of files successfully processed, and a list of failed files.

## 5. Check the results

- Go in the folder that you declared as output directory.
- In there you should find :
    - A bunch of `.obj` (useless for you)
    - A file `result.csv` containing all your measures
    - A set of `.blend` files that you will use to visually check that nothing failed.
- To check that the output is correct :
    - Open the Blender application
    - Drag and drop any .blend file in there. Do not move your mouse too quickly after you droped the file, because you must click on « open » in the little menu that will appear below your mouse.
    - Check that no piece is missing and if you effectively have a blue side and a red side.
    - In Blender you can :
        - Click on the mouse wheel to rotate around the object
        - Click on the mouse wheel while holding shift to move laterally
        - Zoom by scrolling with the mouse wheel
        - In the files containing several contact points, all the contact points will be represented in the same blender file. If you only want to see one of them, look the upper-right part of the blender window. You should see objects named « Contact-001 », « Contact-002 », … followed by a checkbox, an eye and a camera. Simply uncheck the checkbox of what you don’t want to see.
    - If you want to export clean images, instead of taking screenshots :
        - Press 0 (zero on the numpad)
        - Press the space key to start or pause the rotation
        - Press F12 to render
        - In the new window, go in the Image menu, save as…

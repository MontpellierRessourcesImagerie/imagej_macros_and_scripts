
## 1. Install Python and the required packages

- Start by installing MiniConda.
- In the list of applications, search for « Anaconda Prompt » and open it. A terminal should open.
- In that terminal, type: `conda create -n astro-env -y python=3.9`. Then press Enter.
- Activate your newly created environment: `conda activate astro-env`, and press Enter.
- You can now install all the dependencies: `pip install numpy scipy pymeshlab`, and once again, press Enter.

## 2. Install Blender

Go to Blender’s website and download It. The download should begin by clicking on the link. What you just acquired is a zip archive; simply unzip it where you want.

## 3. Get the scripts

- Get to the [featuresFromIsosurfaces.py](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/blob/master/clement/stand-alones/astrocytesBloodVessels/featuresFromIsosurface.py) and the [generateBlenderFile.py](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/blob/master/clement/stand-alones/astrocytesBloodVessels/generateBlenderFile.py) from the hierarchy above.
- Download them by clicking the icon with the arrow pointing down (in the upper right corner).
- On Windows, go in the folder your scripts are. On the menu bar (upper left), go to Display and check the option to show file extensions. Verify that Windows didn’t add « .txt » after the « .py » in your script's name. If it did, rename them by removing the « .txt »

## 4. Run the scripts

**First, verify that none of your `.wrl` files contain a `#` in their name; it is a reserved character.**

- Start by opening `featuresFromIsosurfaces.py` with Notepad or your favorite raw text editor (not Word, for example, that doesn’t produce raw text)
- In there, you should see a line starting with `state = {`, this is the begining of the configuration, you will have to edit it. Beware not to remove the quotes while editing it. Also, Windows paths are written with \, but in the Python script, you should replace all the `\` with simple `/` (to avoid problems)
    - `outputDirectory`: The path to which everything produced by the script will be written. You should provide the path of an empty folder.
    - `target`: Here, you can provide either the path of a `.wrl` (to process only that mesh) or a folder containing only `.wrl` files (to process all of them simultaneously).
    - The exports : `{}` can remain untouched.
    - `blenderPath`: In the Blender folder that you unzipped previously, you should find an application simply named « blender.» You must copy the path of this application here.
    - `blenderScript` : The path of the other script (generateBlenderFile.py)
    - Now, you can save and close the script.
    Go back to your Anaconda terminal, type `python ` with a space at the end, and then drag and drop the script `featuresFromIsosurface.py` into the terminal. You can now press the Enter key.
    - At the end of the execution, the terminal will display a list of files successfully processed and a list of failed files.

## 5. Check the results

- Go to the folder that you declared to be the output directory.
- In there, you should find :
    - A bunch of `.obj` (useless for you)
    - A file `result.csv` containing all your measures
    - A set of `.blend` files that you will use to check that nothing failed visually.
- To check that the output is correct :
    - Open the Blender application
    Drag and drop any ` file into it. Do not move your mouse too quickly after you drop the file because you must click « open » in the little menu below your mouse.
    - Check that no piece is missing and if you effectively have a blue and red side.
    - In Blender, you can :
        - Click on the mouse wheel to rotate around the object
        - Click on the mouse wheel while holding shift to move laterally
        - Zoom by scrolling with the mouse wheel
        - All the contact points will be represented in the same blender file in the files containing several contact points. If you only want to see one, you can just look at the upper-right part of the blender window. You should see objects named « Contact-001 » and « Contact-002 », … followed by a checkbox, an eye, and a camera. Uncheck the checkbox of what you don’t want to see.
    - If you want to export clean images instead of taking screenshots :
        - Press 0 (zero on the numpad)
        - Press the space key to start or pause the rotation
        - Press F12 to render
        - In the new window, go to the Image menu, save as…

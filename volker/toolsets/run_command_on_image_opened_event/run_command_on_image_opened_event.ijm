var ON_IMAGE_OPEN_ON = false;    // if true commands are run when an image is opened
var ON_IMAGE_OPEN_COMMANDS = newArray("HiLo", "Enhance Contrast, saturated=0.35");
var ON_IMAGE_OPEN_COMMANDS_CHECKED = newArray(true, true);

macro "AutoRun" {
    script = getJSRemoveAllImageListeners();
    runJS(script);
    ON_IMAGE_OPEN_ON = call("ij.Prefs.get", "roots.on_image_open_on", false);
    if (ON_IMAGE_OPEN_ON) {
         script = getJSAddListeners();
         runJS(script);
    }
}

macro "Run Command on Image Open Event Action Tool - C000T4b12r" {
    runCommandOnImageOpenEventOprions();
}  

function runCommandOnImageOpenEventOprions() {
    ON_IMAGE_OPEN_ON = call("ij.Prefs.get", "roots.on_image_open_on", false);
    Dialog.create("Root Tools - Options");
    Dialog.addCheckbox("auto run commands when image opened", ON_IMAGE_OPEN_ON);
    for (i=0; i<lengthOf(ON_IMAGE_OPEN_COMMANDS_CHECKED); i++) {
        Dialog.setInsets(0, 40, 0);
        Dialog.addCheckbox(ON_IMAGE_OPEN_COMMANDS[i], ON_IMAGE_OPEN_COMMANDS_CHECKED[i]);
    }
    Dialog.show();
    ON_IMAGE_OPEN_ON = Dialog.getCheckbox();
    for (i=0; i<lengthOf(ON_IMAGE_OPEN_COMMANDS_CHECKED); i++) {
        ON_IMAGE_OPEN_COMMANDS_CHECKED[i] = Dialog.getCheckbox();
    }
    script = getJSRemoveAllImageListeners();
    runJS(script);
    if (ON_IMAGE_OPEN_ON) {
        call("ij.Prefs.set", "roots.on_image_open_on", true);
         script = getJSAddListeners();
         runJS(script);
    } else {
        call("ij.Prefs.set", "roots.on_image_open_on", false);
    }
}

function getJSAddListeners() {
    events = newArray("imageOpened", "imageUpdated", "imageClosed");
    event = "imageOpened";
    commands = ON_IMAGE_OPEN_COMMANDS;
    commandFlags = ON_IMAGE_OPEN_COMMANDS_CHECKED;
    script = "listenerImpl = {";
     for (i=0; i<lengthOf(events); i++) {
         script = script + events[i] + ": function(imp){";
         if (events[i]==event) {
              for (j=0; j<lengthOf(commands); j++) {
                if (commandFlags[j]) {
                    components = split(commands[j],",");
                    if (lengthOf(components)==1) 
                        script = script + "IJ.run(\"" + commands[j] + "\");";
                    else
                        script = script + "IJ.run(\"" + components[0] + "\",\""+components[1]  +"\");";
                    }
              }
         }
         script = script + "}";
         if (i<lengthOf(events)-1) script = script + ",";
     }
    script = script + "}; listener = new ImageListener(listenerImpl); ImagePlus.addImageListener(listener);";
    return script;
}

function runJS(script) {
     eval("script", script);
}

function getJSRemoveAllImageListeners() {
    script = "cl = new ImagePlus().getClass(); df = cl.getDeclaredField(\"listeners\"); df.setAccessible(true); df.get(null).removeAllElements();";
    return script;
}
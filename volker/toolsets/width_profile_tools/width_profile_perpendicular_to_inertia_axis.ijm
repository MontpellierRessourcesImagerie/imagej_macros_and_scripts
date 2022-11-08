var SAMPLE_WIDTH = 5;
var COLORS = newArray("black", "blue", "cyan", "darkGray", "gray", "green", "lightGray", "magenta", "orange", "pink", "red", "white", "yellow");
var LINE_COLOR = "pink";
var START_OFFSET = 5;
var END_OFFSET = 5;
var SAVE_OPTIONS = true;
var SHOW_PROFILE_PLOT = true;
var TABLE_TITLE = "width measurements";
var _URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Width-Profile-Tools";

optionsOnly = call("ij.Prefs.get", "mri.options.only", "false");
showDialog();
if (optionsOnly=="true") exit;
runPerpendicularLines();

function showDialog() {
    if (File.exists(getOptionsPath())) loadOptions();
    Dialog.create("Options of width profile perpendicular to inertia axis");
    Dialog.addNumber("Sample_width: ", SAMPLE_WIDTH);
    Dialog.addNumber("Left_offset: ", START_OFFSET);
    Dialog.addNumber("Right_offset: ", END_OFFSET);
    Dialog.addChoice("Line_color: ", COLORS, LINE_COLOR);
    Dialog.addCheckbox("Show profile plot", SHOW_PROFILE_PLOT);
    Dialog.addCheckbox("Save_options", SAVE_OPTIONS);
    Dialog.addHelp(_URL);
    Dialog.show();
    SAMPLE_WIDTH = Dialog.getNumber();
    START_OFFSET = Dialog.getNumber();
    END_OFFSET = Dialog.getNumber();
    LINE_COLOR = Dialog.getChoice();
    SHOW_PROFILE_PLOT = Dialog.getCheckbox();
    SAVE_OPTIONS = Dialog.getCheckbox(); 
    
    if (SAVE_OPTIONS) saveOptions();
}

function runPerpendicularLines() {
    startTime = getTime();
    getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
    print(year + "-" + IJ.pad(month+1, 2) + "-" + IJ.pad(dayOfMonth, 2) + " " + hour + ":" + minute + ":" + second + "." + msec);
    print("width_profile_perpendicular_to_inertia_axis.ijm");
    print(getOptionsString());
    title = getTitle();
    toUnscaled(START_OFFSET);
    toUnscaled(END_OFFSET);
    run("Set Measurements...", "min centroid fit display redirect=None decimal=3");
    getVoxelSize(pixelWidth, pixelHeight, voxelDepth, unit);
    Image.removeScale();
    Overlay.remove;
    width = getWidth();
    height = getHeight();
    newWidth = width;
    newHeight = height;
    if (bitDepth()==8) setThreshold(1, 255);
    else setThreshold(1, 65535);
    run("Analyze Particles...", "display clear");
    angle = Table.get("Angle", 0);
    rotated = false;
    if (round(angle)%180 != 0) {
        run("Rotate... ", "angle="+angle+" grid=1 interpolation=Bilinear fill enlarge");
        rotated = true;
        newWidth = getWidth();
        newHeight = getHeight();
    }
    setThreshold(1, 255);
    setOption("BlackBackground", true);
    run("Convert to Mask");
    run("Create Selection");
    run("To Bounding Box");
    bbx = getValue("BX") + START_OFFSET;
    bby = getValue("BY");
    bbWidth = getValue("Width") - START_OFFSET - END_OFFSET;
    bbHeight = getValue("Height");
    SAMPLES = round(bbWidth / SAMPLE_WIDTH);
    for (i = 0; i < SAMPLES; i++) {
        x = bbx + (i * SAMPLE_WIDTH);
        lastColor = 0;
        changes = newArray(0);
        for (y = bby-1; y < bby + bbHeight+1; y++) {
            v = getPixel(x, y);
            if (v == 255 && lastColor == 0) {
                changes = Array.concat(changes, y);
            }
            if (v == 0 && lastColor == 255) {
                changes = Array.concat(changes, y-1);              
            }
            lastColor = v;
        }
        changesLength = changes.length;
        if (changesLength==0 || changesLength % 2 == 1) {
            print("anomaly at x = " + x);
            print("number of contrast changes: " + changesLength);
            print("positions of coordinate changes: ");
            Array.print(changes);
            continue;
        }
        maxDist = 0;
        maxIndex = 0;
        for (c = 0; c < changesLength; c = c + 2) {
            dist = changes[c+1] - changes[c];
            if (dist > maxDist) {
                maxIndex = c;
                maxDist = dist;
            }
        }
        makeLine(x, changes[maxIndex]-0.5, x, changes[maxIndex+1]+0.5);
        Overlay.addSelection(LINE_COLOR);
    }
    run("Select None");
    run("Set Scale...", "distance=1 known="+pixelWidth+" unit="+unit);
    run("Properties...", "pixel_width=" + pixelWidth + " pixel_height=" + pixelHeight + " voxelDepth=" + voxelDepth + " unit" + unit); 
    if (rotated) {
        run("Rotate... ", "angle="+(-angle)+" grid=1 interpolation=Bilinear fill enlarge");
        run("Canvas Size...", "width="+width+" height="+height+" position=Center");
    }
    lengths = measure(title);
    if (SHOW_PROFILE_PLOT) showProfilePlot(title, lengths, pixelWidth, unit);
    endTime = getTime();
    getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
    print("execution time: ", ((endTime - startTime) / 1000), "sec.");
    print(year + "-" + IJ.pad(month+1, 2) + "-" + IJ.pad(dayOfMonth, 2) + " " + hour + ":" + minute + ":" + second + "." + msec);
}

function showProfilePlot(title, values, pixelWidth, unit) {
    xValues = Array.getSequence(values.length);
    for (i = 0; i < xValues.length; i++) {
        xValues[i] = xValues[i] * pixelWidth * SAMPLE_WIDTH;
    }
    Plot.create("Width profile of " + title, "distance [" + unit + "]", "width [" + unit + "]"); 
    Plot.add("line", xValues, values); 
    Plot.setStyle(0, "green,green,2.0,Line");
    Plot.show();  
}

function measure(title) {
    run("Clear Results");
    Overlay.measure;
    lengths = Table.getColumn("Length", "Results");
    Array.getStatistics(lengths, min, max, mean, stddev);
    copyOfLengths = Array.copy(lengths);
    median = calculateMedian(copyOfLengths);
    mode = calculateMode();
    if (!isOpen(TABLE_TITLE)) {
        Table.create(TABLE_TITLE);
    }
    row = Table.size(TABLE_TITLE);
    Table.set("Image", row, title);    
    Table.set("Mean", row, mean);
    Table.set("StdDev", row, stddev);
    Table.set("Mode", row, mode);
    Table.set("Min", row, min);
    Table.set("Max", row, max);
    Table.set("Median", row, median);
    Table.set("Method", row, "width profile perpendicular to inertia axis");
    return lengths;
}

function calculateMode() {
    run("Distribution...", "parameter=Length automatic");
    selectWindow("Length Distribution");
    Plot.getValues(bins, counts);
    close("Length Distribution");
    ranks = Array.rankPositions(counts);
    index = ranks[ranks.length-1];
    return bins[index];
}

function calculateMedian(values) {
    Array.sort(values);
    N = values.length;
    median = 0;
    if ((N % 2) == 1) {
        index = floor(N / 2);
        median = values[index];
    } else {
        index2 = N / 2;
        index1 = index2 - 1;
        median = (values[index1] + values[index2]) / 2;
    }
    return median;
}

function loadOptions() {
    optionsPath = getOptionsPath();
    optionsString = File.openAsString(optionsPath);
    optionsString = replace(optionsString, "\n", "");
    options = split(optionsString, " ");
    SHOW_PROFILE_PLOT = false;
    for (i = 0; i < options.length; i++) {
        option = options[i];
        parts = split(option, "=");
        key = parts[0];
        value = "";
        if (indexOf(option, "=") > -1) value = parts[1];
        if (key=="sample_width") SAMPLE_WIDTH = value;
        if (key=="left_offset") START_OFFSET = value;
        if (key=="right_offset") END_OFFSET = value;
        if (key=="line_color") LINE_COLOR = value;
        if (key=="show") SHOW_PROFILE_PLOT = true;
    }
}

function getOptionsPath() {
    pluginsPath = getDirectory("plugins");
    optionsPath = pluginsPath + "Width-Profile-Tools/wppia-options.txt";
    return optionsPath;
}

function getOptionsString() {
    optionsString = "";
    optionsString = optionsString + "sample_width=" + SAMPLE_WIDTH;
    optionsString = optionsString + " left_offset=" + START_OFFSET;
    optionsString = optionsString + " right_offset=" + END_OFFSET;
    optionsString = optionsString + " line_color=" + LINE_COLOR;
    if (SHOW_PROFILE_PLOT) optionsString = optionsString + " show";
    return optionsString;
}

function saveOptions() {
    optionsString = getOptionsString();
    optionsPath = getOptionsPath();
    File.saveString(optionsString, optionsPath);
}
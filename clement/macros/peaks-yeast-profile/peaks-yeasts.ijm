// CNRS-MRI-CIA:MIIY#1989

// = = = = = = = = USER'S SETTINGS = = = = = = = =

_MIN_PEAK_WIDTH     = 10;
_MAX_PEAK_WIDTH     = 100;
_EXCLUDE_EDGE_PEAKS = true;
_OUTPUT_DIRECTORY   = "/home/benedetti/Desktop/peaks/";
_PRESMOOTH          = -1;
_CHANNEL            = 2;
_MIN_PEAKS_DISTANCE = 0.75;
// Only for batch:
_RUN_BATCH          = false;
_INPUT_DIRECTORY    = "/home/benedetti/Desktop/in_peaks/";
_EXTENSION          = ".tif";


// = = = = = = = = = = CONSTANTS = = = = = = = = = =


_PLOT_NAME = "Plot Values";


// = = = = = = = = = = TOP LEVEL = = = = = = = = = =

if (_RUN_BATCH) {
    run_batch();
} else {
    main();
}
IJ.log(">>> DONE.");


// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =


/**
 * Joins two pieces of path together, making sure there is exactly one separator between them.
 * Returns the joined path.
 */
function join(p1, p2) {
    sep = File.separator;
    if (endsWith(p1, sep)) {
        return p1 + p2;
    }
    return p1 + sep + p2;
}

/**
 * On out images, only one channel is used for the analysis.
 * This function duplicates the channel of interest in a new image.
 * The original image is closed after the operation.
 * The new image is renamed after the original image.
 * Works on the active image.
 */
function get_channel() {
    getDimensions(width, height, channels, slices, frames);
    if (channels == 1) { return; }
    Roi.selectNone;
    imIn = getImageID();
    title = File.getNameWithoutExtension(getTitle()) + ".ch" + _CHANNEL;
    run("Duplicate...", "duplicate channels="+_CHANNEL+"-"+_CHANNEL);
    imOut = getImageID();
    selectImage(imIn);
    close();
    selectImage(imOut);
    rename(title);
}

/**
 * Renames all the ROIs in the RoiManager with a padded number, corresponding to their rank.
 * Works on the active RoiManager.
 * The content of the ROI manager is saved in a zip file in the output directory.
 */
function rename_rois(output) {
    nROIs = roiManager("count");
    for (i = 0 ; i < nROIs ; i++) {
        roiManager("select", i);
        roiManager("remove slice info");
        roiManager("rename", IJ.pad(i+1, 3));
    }
    out_dir = join(output, File.getNameWithoutExtension(getTitle()) + "-rois.zip");
    roiManager("save", out_dir);
}

/**
 * Creates the MIP for all the frames of a given hyperstack.
 * The original image is closed after the operation.
 * Works on the active image.
 */
function make_mip() {
    imIn = getImageID();
    title = File.getNameWithoutExtension(getTitle()) + ".mip";
    run("Z Project...", "projection=[Max Intensity] all");
    rename(title);
    imOut = getImageID();
    selectImage(imIn);
    close();
    selectImage(imOut);
}

/**
 * Registers the frames on themselves to align each instance of yeast along the time axis.
 * StackReg is destructive, it modifies the original image.
 */
function register_frames() {
    run("StackReg", "transformation=Translation");
    rename(File.getNameWithoutExtension(getTitle()) + ".reg");
}

/**
 * Sorts a column in a Table instance and keeps its associated data on the good row.
 * 
 * Args:
 *    t_name (str): The name of the Table to sort.
 *    reference (str): The name of the column containing the values to sort on.
 *    followers (array of str): The names of the columns (must include the reference) to move along with the reference column.
 */
function sort_table(t_name, reference, followers) {
    nRows = Table.size(t_name);
    for (i = 0; i < nRows - 1; i++) {
        minIndex = i;
        for (j = i + 1; j < nRows; j++) {
            if (isNaN(Table.get(reference, j, t_name))) { break; }
            if (Table.get(reference, j, t_name) < Table.get(reference, minIndex, t_name)) {
                minIndex = j;
            }
        }
        if (minIndex != i) {
            swap(t_name, followers, i, minIndex);
        }
    }
}

function swap(t_name, columns, i, j) {
    for (c = 0; c < lengthOf(columns); c++) {
        temp = Table.get(columns[c], i, t_name);
        Table.set(columns[c], i, Table.get(columns[c], j, t_name), t_name);
        Table.set(columns[c], j, temp, t_name);
    }
}

/**
 * Searches for the minimal intensity to find to detect a peak.
 * We use the line ROI provided by the user to produce a circle in which we take the mean intensity.
 * The mean intensity is then used as a threshold to detect the peaks.
 * It is supposed to be a good approximation of the background intensity.
 */
function lower_bound(roi) {
    Roi.getBounds(x, y, width, height);
    diam = Math.sqrt(width*width + height*height);
    Roi.selectNone;
    makeOval(x, y, diam, diam);
    getStatistics(area, mean, min, max, std, histogram);
    Roi.selectNone;
    roiManager("Select", roi);
    return (min + max) / 2;
}

/**
 * Extends the results table with the new values extracted from the current frame.
 * The plugin "BAR" produces a table with the following columns: 'X0', 'Y0', 'X1', 'Y1', 'X2', 'Y2'
 *   - X0: the x-coordinate of the value in the plot referential.
 *   - Y0: the intensity of the value in the plot referential.
 *   - X1: the x-coordinate of the maxima peaks in the plot referential.
 *   - Y1: the intensity of the maxima peaks in the plot referential.
 *   - X2: the x-coordinate of the minima peaks in the plot referential.
 *   - Y2: the intensity of the minima peaks in the plot referential.
 * The final results table adds a suffix corresponding to the frame index to each of there columns and bundles them in a unique table.
 */
function concatenate_results(t_name, frame) {
    raw_headings = Table.headings(_PLOT_NAME);
    headings = split(raw_headings, "\t");
    nRows = Table.size(_PLOT_NAME);
    nCols = lengthOf(headings);
    disp_fr = frame+1;

    followers = newArray("X1", "Y1");
    sort_table(_PLOT_NAME, "X1", followers);
    followers = newArray("X2", "Y2");
    sort_table(_PLOT_NAME, "X2", followers);

    for (c = 0 ; c < nCols ; c++) {
        heading = headings[c] + "-t" + IJ.pad(disp_fr, 2);
        for (r = 0 ; r < nRows ; r++) {
            v = Table.get(headings[c], r, _PLOT_NAME);
            if (isNaN(v)) { continue; }
            Table.set(heading, r, v, t_name);
        }
        Table.update(t_name);
    }
}

/**
 * Extracts the profile for a given ROI, currently selected on the active image.
 * The profile must be extracted along time.
 */
function make_profile(roi, output) {
    getDimensions(width, height, channels, slices, frames);
    t_name = "ROI-"+IJ.pad(roi+1, 3);
    Table.create(t_name);
    IJ.log("Created table: " + t_name);
    prefix = "peaks-" + t_name + "-";
    for (f = 0 ; f < frames ; f++) {
        Stack.setFrame(f+1);
        roiManager("Select", roi);
        mpa = 100 ; // lower_bound(roi);
        chart_name = prefix + IJ.pad(f+1, 3) + ".png";
        full_path = join(output, chart_name);
        IJ.log("Frame: " + f + "; ROI: " + (roi+1) + "; Min amplitude: " + mpa);
        run("Plot Profile");
        run("Find Peaks", "min._peak_amplitude="+mpa+" min._peak_distance="+_MIN_PEAKS_DISTANCE+" min._value=[] max._value=[] exclude list");
        save(full_path);
        close("Peaks in *");
        close("Plot of *");
        concatenate_results(t_name, f);
        close(_PLOT_NAME);
    }
    csv_path = join(output, t_name+".csv");
    Table.save(csv_path, t_name);
    close(t_name);
}

/**
 * Processes the profiles and extracts the peaks for each ROI in the RoiManager.
 * Skips any ROI that is not a line.
 * Works on the active image and the active RoiManager.
 */
function extract_profiles(output) {
    roiManager("deselect");
    nROIs = roiManager("count");
    for (i = 0 ; i < nROIs ; i++) {
        roiManager("Select", i);
        if (Roi.getType() != "line") { continue; }
        make_profile(i, output);
    }
}

/**
 * Creates the output directory for the current image if it doesn't exist already.
 */
function make_output_dir(working_dir) {
    dir_name = "controls-" + File.getNameWithoutExtension(getTitle());
    output_dir = join(working_dir, dir_name);
    if (!File.isDirectory(output_dir)) {
        File.makeDirectory(output_dir);
    }
    return output_dir;
}

/**
 * Applies a Gaussian smoothing to the active image if the provided radius is >0.
 * The radius is in physical units.
 * The operation is destructive, it modifies the original image.
 */
function presmooth() {
    if (_PRESMOOTH < 1e-4) { return; }
    run("Gaussian Blur...", "sigma="+_PRESMOOTH+" scaled stack");
}

/**
 * One-shot function to extract the profiles and the extremas from a given image.
 */
function main() {
    target = File.getNameWithoutExtension(getTitle());
    IJ.log(">>> Processing: " + target);
    output = make_output_dir(_OUTPUT_DIRECTORY);
    IJ.log("Output directory: " + output);
    rename(target);
    rename_rois(output);
    get_channel();
    make_mip();
    presmooth();
    register_frames();
    extract_profiles(output);
}

// = = = = = = = = BATCH FUNCTIONS = = = = = = = = = = = = =

function get_images() {
    images = newArray();
    files  = getFileList(_INPUT_DIRECTORY);
    for (i = 0 ; i < lengthOf(files) ; i++) {
        if (endsWith(files[i], _EXTENSION)) {
            images = Array.concat(images, files[i]);
        }
    }
    return images;
}

function valid_items(images) {
    items = newArray();
    for (i = 0 ; i < lengthOf(images) ; i++) {
        no_ext = images[i].replace(_EXTENSION, "");
        image_path = join(_INPUT_DIRECTORY, images[i]);
        rois_path  = join(_INPUT_DIRECTORY, no_ext + ".zip");
        if (!File.exists(image_path)) { continue; }
        if (!File.exists(rois_path))  { continue; }
        na = newArray(no_ext);
        items = Array.concat(items, na);
    }
    return items;
}

function validSettings() {
    if (!File.isDirectory(_OUTPUT_DIRECTORY)) {
        IJ.log("Output directory does not exist. Abort.");
        return false;
    }
    if (!File.isDirectory(_INPUT_DIRECTORY)) {
        IJ.log("Input directory does not exist. Abort.");
        return false;
    }
    if (!_EXTENSION.startsWith(".")) {
        IJ.log("Invalid extension. It should start with a '.' (ex: '.tif', '.czi'). Abort.");
        return false;
    }
    return true;
}

/**
 * Batch processing.
 */
function run_batch() {
    run("Close All");
    run("Collect Garbage");
    if (!validSettings()) { return; }
    images = get_images();
    pairs = valid_items(images);
    Array.print(images);
    
    for (i = 0 ; i < lengthOf(pairs) ; i++) {
        run("Close All");
        run("Collect Garbage");
        roiManager("reset");
        item = pairs[i];
        image_path = join(_INPUT_DIRECTORY, item+_EXTENSION);
        rois_path  = join(_INPUT_DIRECTORY, item+".zip");
        open(image_path);
        roiManager("open", rois_path);
        main();
    }

    run("Close All");
    run("Collect Garbage");
}
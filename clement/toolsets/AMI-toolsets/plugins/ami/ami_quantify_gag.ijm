var INPUT_FOLDER     = "";
var INFERENCE_PREFIX = "inference_";
var SPOTS_PREFIX     = "spots_";

function join(a, b) {
    if (a.endsWith(File.separator)) { return a + b; }
    return a + File.separator + b;
}

function ask_settings() {
    Dialog.create("Quantify Gag settings");
    Dialog.addDirectory("Input directory", "");
    Dialog.addString("Inference prefix", "inference_");
    Dialog.addString("Spots prefix", "spots_");
    Dialog.show();
    INPUT_FOLDER = Dialog.getString();
    INFERENCE_PREFIX = Dialog.getString();
    SPOTS_PREFIX = Dialog.getString();
}

function get_max_from_stack() {
    selectImage("nuclei");
    maximum = 0;
    getDimensions(width, height, channels, slices, frames);
    for (i = 1 ; i <= slices ; i++) {
        Stack.setSlice(i);
        getRawStatistics(nPixels, mean, min, max, std, histogram);
        if (max > maximum) { maximum = max; }
    }
    return maximum;
}

function make_measurements(base_name) {
    max_nuclei_label = get_max_from_stack();
    buffer_count     = newArray(max_nuclei_label+1);
    buffer_volume    = newArray(max_nuclei_label+1);
    run("Intensity Measurements 2D/3D", "input=nuclei labels=spots max volume");
    t_name = Table.title;
    t_size = Table.size(t_name);
    for (i = 0; i < t_size; i++) {
        nucleus_label = Table.get("Max", i, t_name);
        nucleus_label = parseInt(nucleus_label);
        volume = Table.get("Volume", i, t_name);
        volume = parseFloat(volume);
        buffer_count[nucleus_label]++;
        buffer_volume[nucleus_label] += volume;
    }
    close(t_name);
    res_name = replace(base_name, ".tif", ".csv");
    res_name = "volume_" + res_name;
    Table.create(res_name);
    for (i = 1 ; i < max_nuclei_label; i++) {
        Table.set("Nucleus", i-1, i);
        Table.set("Count", i-1, buffer_count[i]);
        Table.set("Volume", i-1, buffer_volume[i]);
    }
    res_path = join(INPUT_FOLDER, res_name);
    Table.save(res_path);
    close(res_name);
}

function main() {
    setBatchMode("hide");
    run("Close All");
    ask_settings();
    filelist = getFileList(INPUT_FOLDER);
    
    for (i = 0; i < lengthOf(filelist); i++) {
        current = filelist[i];
        if (!endsWith(current, ".tif"))  { continue; }
        if (!startsWith(current, INFERENCE_PREFIX)) { continue; }
        base_name = replace(current, INFERENCE_PREFIX, "");
        print("Processing: " + base_name);

        nuclei_name = current;
        spots_name = SPOTS_PREFIX + base_name;
        spots_path = join(INPUT_FOLDER, spots_name);
        nuclei_path = join(INPUT_FOLDER, nuclei_name);
        
        open(nuclei_path);
        rename("nuclei");

        open(spots_path);
        rename("spots");

        make_measurements(base_name);
        run("Close All");
    }
    setBatchMode("exit and display");
    print("DONE.");
}

main();
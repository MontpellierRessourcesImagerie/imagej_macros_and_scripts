var data_folder      = "/home/clement/Downloads/2026-03-12-cchamontin/pool";
var cells_prefix     = "inference_";
var spots_prefix     = "spots_";
var max_n_channels   = 3;
var measure_channels = newArray(1, 2);
var channels_name    = newArray("Channel1", "Channel2");
var base_table_name  = "Extracted spots";
var metrics          = newArray("Mean", "Volume", "Max", "Mode");

function prompt_settings() {
	Dialog.create("Count & measure");
	
	Dialog.addDirectory("Cells, spots & images directory", "");
	Dialog.addString("Cells prefix", "inference_");
	Dialog.addString("Spots prefix", "spots_");
	
	for (i = 0 ; i < max_n_channels ; ++i) {
		Dialog.addNumber("Channel:", i+1);
		Dialog.addToSameRow();
		Dialog.addString("As:", "C"+i);
		Dialog.addToSameRow();
		Dialog.addCheckbox("Use slot?", true);
	}
	
	Dialog.show();
	
	data_folder = Dialog.getString();
	cells_prefix = Dialog.getString();
	spots_prefix = Dialog.getString();
	
	_measure_channels = newArray();
	_channel_names = newArray();
	rank = 0;
	
	for (i = 0 ; i < max_n_channels ; ++i) {
		c = Dialog.getNumber();
		n = Dialog.getString();
		u = Dialog.getCheckbox();
		if (!u) { continue; }
		_measure_channels[rank] = c;
		_channel_names[rank] = n;
		rank++;
	}
	measure_channels = _measure_channels;
	channels_name = _channel_names;
}

function join(a, b) {
	if (endsWith(a, File.separator)) {
		return a + b;
	}
	return a + File.separator + b;
}

function clean_up() {
	run("Close All");
	titles = getList("window.titles");
	for (i = 0 ; i < titles.length ; ++i) {
		t = titles[i];
		if (startsWith(t, base_table_name)) { continue; }
		close(t);
	}
}

function all_paths_ok(cells_path, spots_path, original_path) {
	if (!File.exists(cells_path)) {
		print("Cells not found: " + cells_path);
		return false;
	}
	if (!File.exists(spots_path)) {
		print("Spots not found: " + spots_path);
		return false;
	}
	if (!File.exists(original_path)) {
		print("Original not found: " + original_path);
		return false;
	}
	return true;
}

/**
 * Bind spots to cells and return the name of the table containing the results.
 * The binding is made by measuring the intensity in the labels-map of cells within each spot.
 */
function bind_spots_to_cells(spots_path, cells_path) {
	open(spots_path);
	rename("Spots");
	
	open(cells_path);
	rename("Cells");
	
	run("Intensity Measurements 2D/3D", "input=Cells labels=Spots max");
	spot_bindings = Table.title();
	run("Close All");

	return spot_bindings;
}

/**
 * Measure intensities in each cell and return an array of tables containing the title of the result tables.
 * There is one results table per channel, using the same order as in 'measure_channels' and 'channels_name'.
 */
function measure_intensities_per_cell(original_path, cells_path) {
	open(cells_path);
	rename("Cells");
	
	open(original_path);
	rename("Original");
	
	intensity_tables = newArray();
	
	for (j = 0 ; j < measure_channels.length ; ++j) {
		selectImage("Original");
		c_idx = measure_channels[j];
		run("Duplicate...", "duplicate channels=" + c_idx + "-" + c_idx);
		run("Median 3D...", "x=2 y=2 z=2");
		ch_ttl = channels_name[j];
		rename(ch_ttl);
		run("Intensity Measurements 2D/3D", "input=[" + ch_ttl + "] labels=Cells mean max mode volume");
		intensity_tables[j] = Table.title();
	}

	run("Close All");
	return intensity_tables;
}

/**
 * Produces an array that can be accessed using the cell ID as index.
 * Each slot corresponds to the number of spots found for the cell with the corresponding ID.
 * 0 is reserved for the background and is ignored in the rest of the code.
 */
function count_spots_per_cell(spot_bindings) {
	n_items     = 65536;
	count_spots = newArray(n_items);
	
	for (j = 0 ; j < n_items ; ++j) {
		count_spots[j] = 0;
	}
	
	for (j = 0 ; j < Table.size(spot_bindings) ; ++j) {
		cell = Table.get("Max", j, spot_bindings);
		cell = parseInt(cell);
		count_spots[cell]++;
	}

	return count_spots;
}

function compile_info(count_spots, intensity_tables, table_name) {
	for (j = 0 ; j < intensity_tables.length ; ++j) {
		intensity_table = intensity_tables[j];
		for (k = 0 ; k < Table.size(intensity_table) ; ++k) {
			cell_id = Table.getString("Label", k, intensity_table);
			cell_id = parseInt(cell_id);
			Table.set("Cell ID", k, cell_id, table_name);
			n_spots = count_spots[cell_id];
			Table.set("Num spots", k, n_spots, table_name);
			for (m = 0 ; m < metrics.length ; ++m) {
				m_name = metrics[m];
				cell_value = Table.get(m_name, k, intensity_table);
				col_name = channels_name[j] + " (" + m_name + ")";
				Table.set(col_name, k, cell_value, table_name);
			}
		}
	}
	Table.update(table_name);
}

function main() {
	prompt_settings();
	fileslist = getFileList(data_folder);
	setBatchMode(true);

	for (i = 0 ; i < fileslist.length ; ++i) {
		cells_name = fileslist[i];
		
		if (!startsWith(cells_name, cells_prefix)) { continue; }
		print("Processing " + cells_name);
		
		original_name = replace(cells_name, cells_prefix, "");
		spots_name    = spots_prefix + original_name;
		cells_path    = join(data_folder, cells_name);
		spots_path    = join(data_folder, spots_name);
		original_path = join(data_folder, original_name);

		if (!all_paths_ok(cells_path, spots_path, original_path)) { continue; }
		
		table_name = base_table_name + " (" + original_name + ")";
		Table.create(table_name);
		
		spot_bindings = bind_spots_to_cells(spots_path, cells_path);
		
		intensity_tables = measure_intensities_per_cell(original_path, cells_path);
		
		count_spots = count_spots_per_cell(spot_bindings);
		
		compile_info(count_spots, intensity_tables, table_name);

		output_path = join(data_folder, table_name + ".csv");
		Table.save(output_path, table_name);
		print("Results saved to " + output_path);

		clean_up();
	}
	print("DONE.");
}

main();

var data_folder      = "/home/clement/Downloads/2026-03-12-cchamontin/pool";
var cells_prefix     = "inference_";
var spots_prefix     = "spots_";
var max_n_channels   = 3;
var measure_channels = newArray(1, 2);
var channels_name    = newArray("Channel1", "Channel2");
var base_table_name  = "Extracted spots";

function prompt_settings() {
	Dialog.create("Spots: Count & measure");
	
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

function main() {
	prompt_settings();
	fileslist = getFileList(data_folder);

	for (i = 0 ; i < fileslist.length ; ++i) {
		cells_name = fileslist[i];
		if (!startsWith(cells_name, cells_prefix)) { continue; }
		original_name = replace(cells_name, cells_prefix, "");
		spots_name    = spots_prefix + original_name;
		
		cells_path    = join(data_folder, cells_name);
		spots_path    = join(data_folder, spots_name);
		original_path = join(data_folder, original_name);
		if (!File.exists(cells_path)) {
			print("Cells not found: " + cells_name);
			continue;
		}
		if (!File.exists(spots_path)) {
			print("Spots not found: " + spots_name);
			continue;
		}
		if (!File.exists(original_path)) {
			print("Original not found: " + original_name);
			continue;
		}
		
		table_name = base_table_name + " (" + original_name + ")";
		Table.create(table_name);
		
		// Cell ID extraction
		open(spots_path);
		spots_ttl = getTitle();
		
		open(cells_path);
		cells_ttl = getTitle();
		
		run("Intensity Measurements 2D/3D", "input=[" + cells_ttl + "] labels=[" + spots_ttl + "] max");
		t1 = Table.title();
		selectImage(cells_ttl);
		run("Close All");
		
		// Measure intensities in each channel
		open(cells_path);
		cells_ttl = getTitle();
		
		open(original_path);
		original_ttl = getTitle();
		
		i_tables = newArray();
		for (j = 0 ; j < measure_channels.length ; ++j) {
			selectImage(original_ttl);
			c_idx = measure_channels[j];
			run("Duplicate...", "duplicate channels=" + c_idx + "-" + c_idx);
			run("Median 3D...", "x=2 y=2 z=2");
			ch_ttl = getTitle();
			run("Intensity Measurements 2D/3D", "input=[" + ch_ttl + "] labels=[" + cells_ttl + "] mean max mode volume");
			i_tables[j] = Table.title();
		}
		run("Close All");
		
		// Count spots per cell
		tb_cell   = i_tables[0];
		last_line = Table.size(tb_cell) - 1;
		max_cell  = Table.getString("Label", last_line, tb_cell);
		max_cell  = parseInt(max_cell)+1;
		count_spots = newArray(max_cell);
		for (j = 0 ; j < max_cell ; ++j) { count_spots[j] = 0; }
		
		for (j = 0 ; j < Table.size(t1) ; ++j) {
			cell = Table.get("Max", j, t1);
			count_spots[cell]++;
		}
		
		// Init the table
		rank = 0;
		cell_id_to_rank = newArray(max_cell);
		for (j = 0 ; j < max_cell ; ++j) { cell_id_to_rank[j] = -1; }
		
		for (j = 0 ; j < max_cell ; ++j) {
			if (j == 0) { continue; }
			if (count_spots[j] == 0) { continue; }
			Table.set("Cell ID", rank, j, table_name);
			cell_id_to_rank[j] = rank;
			rank++;
		}
		
		// Extract intensities
		metrics = newArray("Mean", "Volume", "Max", "Mode");
		for (j = 0 ; j < measure_channels.length ; ++j) {
			for (y = 0 ; y < metrics.length ; ++y) {
				m = metrics[y];
				col = channels_name[j] + " (" + m + ")";
				ch_name = channels_name[j];
				t_tgt = i_tables[j];
				for (k = 0 ; k < Table.size(t_tgt) ; ++k) {
					cell_id = Table.getString("Label", k, t_tgt);
					cell_id = parseInt(cell_id);
					row_idx = cell_id_to_rank[cell_id];
					if (cell_id == 0) { continue; }
					cell_value = Table.get(m, k, t_tgt);
					cell_vol = Table.get("Volume", k, t_tgt);
					if (count_spots[cell_id] == 0) { continue; }
					Table.set("Volume", row_idx, cell_vol, table_name);
					Table.set("Num spots", row_idx, count_spots[cell_id], table_name);
					Table.set(col, row_idx, cell_value, table_name);
				}
			}
		}
		Table.update(table_name);
	}
	clean_up();
}


main();








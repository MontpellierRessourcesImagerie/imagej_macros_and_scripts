var f_before = 1;
var f_after  = 1;
var f_first  = 0;
var f_last   = 0;
var n_images = 2;
var t_name   = "Measurements";
var suffix   = "_preprocessed.tif";
var titles = getList("image.titles");

if (titles.length != n_images) {
	exit("!!! Only " + n_images + " images should be opened!!!");
}

function join(a, b) {
	if (endsWith(a, File.separator)) {
		return a + b;
	}
	return a + File.separator + b;
}

function update_frames() {
	Dialog.create("N. of frames in sequence to analyze");
	Dialog.addNumber("N. frames before", 1);
	Dialog.addNumber("N. frames after", 1);
	Dialog.show();

	getDimensions(width, height, channels, slices, frames);
	Stack.getPosition(channel, slice, frame);

	f_before = Dialog.getNumber();
	f_after  = Dialog.getNumber();
	f_first  = frame - f_before;
	f_last   = frame + f_after;

	if (f_first < 1) {
		print("Too many frames before requested");
		return false;
	}
	if (f_last > frames) {
		print("Too many frames after requested");
		return false;
	}
	
	print("Going from frames " + f_first + " to " + f_last + ".");
	return true;
}

function preprocess() {
	waitForUser("Preprocessing", "Apply BG subtraction and registration?\n[OK] Yes\n[Alt+OK] No");
	if (!isKeyDown("alt")) {
		for (z = 0 ; z < n_images ; ++z) {
			selectImage(titles[z]);
			print("Subtracting background...");
			run("Subtract Background...", "rolling=50 stack");
			print("Registering the stack...");
			run("StackReg ", "transformation=[Rigid Body]");
			name = File.getNameWithoutExtension(titles[z]);
			output_path = join(File.directory, name);
			print("Saving image at: " + output_path);
			saveAs("TIFF", output_path);
		}
	}
	
	roiManager("reset");
	Table.reset(t_name);
}

function measure(cell_index, f) {
	current = getImageID();
	Roi.copy();
	n_lines = f_last - f_first + 1;
	row = (cell_index - 1) * n_lines + (f - f_first);
	Table.set("Frame", row, f, t_name);
	Table.set("Cell", row, cell_index, t_name);
	for (i = 0 ; i < titles.length ; ++i) {
		name = titles[i];
		selectImage(name);
		Roi.paste();
		Stack.setFrame(f);
		getStatistics(area, mean, min, max, std, histogram);
		Table.set("Area", row, area, t_name);
		Table.set(name, row, mean, t_name);
	}
	Table.update(t_name);
	selectImage(current);
}

function analyze_cell(cell_index) {
	run("Select None");
	while (Roi.size == 0) {
		setTool("line");
		waitForUser(
			"New rectangle",
			"Draw a thick line perpenticular to the ring"
		);
	}
	update_frames();
	Stack.setFrame(f_first);
	getSelectionCoordinates(x, y);
	center_x = (x[0] + x[1]) / 2;
	center_y = (y[0] + y[1]) / 2;
	run("Line to Area");
	Roi.copy();
	
	for (f = f_first ; f <= f_last ; ++f) {
		Stack.setFrame(f);
		is_roi_ok = false;
		while ((f >= f_first) && (!is_roi_ok)) {
			Roi.copy();
			run("Select None");
			while (Roi.size == 0) {
				setTool("point");
				makePoint(center_x, center_y);
				waitForUser(
					"New center",
					"Move the point to update the rectangle's center"
				);
			}
			getSelectionCoordinates(x, y);
			shift_x = x[0] - center_x;
			shift_y = y[0] - center_y;
			run("Select None");
			Roi.paste();
			Roi.translate(shift_x, shift_y);
			center_x += shift_x;
			center_y += shift_y;
			waitForUser(
				"Is ROI OK?",
				"[OK]: The ROI is OK\n[Alt+OK]: The ROI is misplaced"
			);
			is_roi_ok = !isKeyDown("alt");
		}
		roiManager("add");
		measure(cell_index, f);
	}
}

function main() {
	cell_index = 1;
	preprocess();
	while(true) {
		analyze_cell(cell_index);
		cell_index++;
		waitForUser(
			"Go to the next cell?",
			"[0K] Yes\n[Alt+OK] Exit"
		);
		if (isKeyDown("alt")) {
			print("DONE.");
			exit; 
		}
	};
}

main();


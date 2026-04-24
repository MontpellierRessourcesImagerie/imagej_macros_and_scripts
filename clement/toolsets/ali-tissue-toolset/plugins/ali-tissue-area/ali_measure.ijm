
directory = getDirectory("Images & labels location");
filelist = getFileList(directory);
run("Close All");

final_name = "summary";
Table.create(final_name);

function add_to_summary(table_name, index) {
	src_name = replace(table_name, ".csv", "");
	src_name = replace(src_name, "labeled-", "");
	
	total_area = 0.0;
	total_perimeter = 0.0;
	n_items = 0;
	
	for (i = 0 ; i < Table.size(table_name) ; ++i) {
		n_items++;
		area = Table.get("Area", i, table_name);
		perimeter = Table.get("Perimeter", i, table_name);
		total_area += area;
		total_perimeter += perimeter;
	}
	
	Table.set("Source", index, src_name, final_name);
	Table.set("Num. islands", index, n_items, final_name);
	Table.set("Area", index, total_area, final_name);
	Table.set("Perimeter", index, total_perimeter, final_name);
}

next_index = 0;
for (i = 0; i < lengthOf(filelist); i++) {
    current = filelist[i];
    if (!endsWith(current, ".tif")) { 
        continue;
    }
    if (!startsWith(current, "labeled")) { 
        continue;
    }
    path = directory + current;
    open(path);
    
    run("Analyze Regions", "area perimeter");
    table_name = replace(current, ".tif", ".csv");
    table_path = directory + table_name;
    saveAs("Results", table_path);
    
    add_to_summary(table_name, next_index);
    next_index++;
    
    close(table_name);
    run("Close All");
}

Table.update(final_name);
final_path = directory + final_name + ".csv";
saveAs("Results", final_path);






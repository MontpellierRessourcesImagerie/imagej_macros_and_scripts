var TABLE_TITLE = "width measurements";

title = getTitle();
mean = getValue("Mean");
stddev = getValue("StdDev");
mode = getValue("Mode");
min = getValue("Min");
max = getValue("Max");
median = getValue("Median");
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
Table.set("Method", row, "width profile by local thickness");
var _TABLE_NAME = "Spots in tracks statistics.csv";
var _X_ROW_TITLE = "POSITION_X";
var _Y_ROW_TITLE = "POSITION_Y";
var _FRAME_TITLE = "FRAME";

selectWindow(_TABLE_NAME);
count = Table.size;
maskID = getImageID();
run("Select None");
setBatchMode(true);
for (i = 0; i < count; i++) {
	x = Table.get(_X_ROW_TITLE, i);
	y = Table.get(_Y_ROW_TITLE, i);
	toUnscaled(x, y);
	frame = Table.get(_FRAME_TITLE, i);
	Stack.setFrame(frame+1);
	doWand(x, y);
	getStatistics(area);
	run("Select None");
	Table.set("Area", i, area);
}
setBatchMode(false);
Table.update;
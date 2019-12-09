var _TABLE_NAME = "Spots in tracks statistics.csv";
var _X_ROW_TITLE = "POSITION_X";
var _Y_ROW_TITLE = "POSITION_Y";
var _FRAME_TITLE = "FRAME";
var _TRACK_TITLE = "TRACK_ID";

selectWindow(_TABLE_NAME);
i = Table.getSelectionStart(_TABLE_NAME);
x = Table.get(_X_ROW_TITLE, i);
y = Table.get(_Y_ROW_TITLE, i);
toUnscaled(x, y);
frame = Table.get(_FRAME_TITLE, i);
Stack.setFrame(frame+1);
makePoint(x, y);
doWand(x, y);
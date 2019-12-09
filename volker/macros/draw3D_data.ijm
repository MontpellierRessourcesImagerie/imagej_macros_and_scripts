var _COLORS = newArray("green", "red");
var _MAX = 1000;
var _X_VAR="Mean";
var _Y_VAR="Min";
var _Z_VAR="StdDev";
var _I_VALUE="class";

selectWindow("MIN_true +.csv");

xValues = Table.getColumn(_X_VAR);
yValues = Table.getColumn(_Y_VAR);
zValues = Table.getColumn(_Z_VAR);
iValues = Table.getColumn(_I_VALUE);

newImage("3D data", "RGB black", _MAX, _MAX, _MAX);

for(i=0; i<xValues.length; i++) {
	if (iValues[i]=="right") setColor(_COLORS[0]);
	else setColor(_COLORS[1]);
	Stack.setSlice(round(abs(zValues[i])));
	fillOval(round(abs(xValues[i])), round(abs(yValues[i])), 3, 3);
}

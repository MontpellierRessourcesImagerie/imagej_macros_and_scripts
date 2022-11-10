

path = File.openDialog("Select a File");
content = File.openAsString(path);
lines = split(content, "\n");
xpoints = newArray(lines.length);
ypoints = newArray(lines.length);
for (i=0; i<lines.length; i++) {
    line = lines[i];
    parts = split(line, ", ");
    ypoints[i] = parseFloat(parts[0]);
    xpoints[i] = parseFloat(parts[1]);
}

makeSelection("point", xpoints, ypoints);
roiManager("add");


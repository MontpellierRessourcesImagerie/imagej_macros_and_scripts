path = File.openDialog("Select a File");
content = File.openAsString(path);
lines = split(content, "\n");
xpoints = newArray(lines.length);
ypoints = newArray(lines.length);
zpoints = newArray(lines.length);
for (i=0; i<lines.length; i++) {
    line = lines[i];
    parts = split(line, ", ");
    z = parseFloat(parts[0]);
    y = parseFloat(parts[1]);
    x = parseFloat(parts[2]);
    Stack.setSlice(z);
    makePoint(x, y);
    roiManager("add");    
}



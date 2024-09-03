Image.removeScale;

Overlay.activateSelection(0);
width = getValue("Width");
height = getValue("Height");
size = minOf(width, height);
iterations = floor(size / 2)

for (i = 0; i < iterations; i++) {
    run("Area to Line");
    run("Measure");
    run("Line to Area");
    run("Enlarge...", "enlarge=-1");
}
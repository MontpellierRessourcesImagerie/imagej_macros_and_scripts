var XDIR = newArray(-1, 0, 1, -1, 0, 1, -1, 0, 1);
var YDIR = newArray(-1, -1, -1, 0, 0, 0, 1, 1, 1);
width = getWidth();
height = getHeight();
Roi.getCoordinates(xpoints, ypoints);
run("Select None");
maxWidth = getValue("Max");

x1 = xpoints[0];
y1 = ypoints[0];
x2 = xpoints[1];
y2 = ypoints[1];
deltaX = x2 - x1;
deltaY = y2 - y1;
sign = (deltaX + deltaY) >= 0
directSquaredDist = (deltaX * deltaX) + (deltaY * deltaY);
pathX = newArray(1);
pathY = newArray(1);
pathX[0] = x1;
pathY[0] = y1;

DONE = false;
steps = 0;
maxSteps = width + height;
while(!DONE && steps<maxSteps) {
    lastIndex = pathX.length-1;
    nextPointAndCost = getBestNeighbor(pathX[lastIndex], pathY[lastIndex], x2, y2);
    pathX = Array.concat(pathX, nextPointAndCost[0]);
    pathY = Array.concat(pathY, nextPointAndCost[1]);
    if (nextPointAndCost[2]==0) DONE = true;
    steps++;
}
makeSelection("freeline", pathX, pathY);


function getBestNeighbor(x, y, xDest, yDest) {
    costs = newArray(8);
    costs[0] = ((maxWidth - getPixel(x-1, y-1)) / maxWidth) + ( pow(xDest - (x-1), 2) +  pow(yDest - (y-1), 2) ) / directSquaredDist;
    costs[1] = ((maxWidth - getPixel(x, y-1)) / maxWidth) + ( pow(xDest - x, 2) +  pow(yDest - (y-1), 2) ) / directSquaredDist;
    costs[2] = ((maxWidth - getPixel(x+1, y-1)) / maxWidth) + ( pow(xDest - (x+1), 2) +  pow(yDest - (y-1), 2) ) / directSquaredDist;
    costs[3] = ((maxWidth - getPixel(x-1, y)) / maxWidth) + ( pow(xDest - (x-1), 2) +  pow(yDest - y, 2) ) / directSquaredDist;
    costs[4] = 18;
    costs[5] = ((maxWidth - getPixel(x+1, y)) / maxWidth) + ( pow(xDest - (x+1), 2) +  pow(yDest - y, 2) ) / directSquaredDist;
    costs[6] = ((maxWidth - getPixel(x-1, y+1)) / maxWidth) + ( pow(xDest - (x-1), 2) +  pow(yDest - (y+1), 2) ) / directSquaredDist;
    costs[7] = ((maxWidth - getPixel(x, y+1)) / maxWidth) + ( pow(xDest - x, 2) +  pow(yDest - (y+1), 2) ) / directSquaredDist;
    costs[8] = ((maxWidth - getPixel(x+1, y+1)) / maxWidth) + ( pow(xDest - (x+1), 2) +  pow(yDest - (y+1), 2) ) / directSquaredDist;
    
    ranks = Array.rankPositions(costs);
    dir = ranks[0];
    res = newArray(XDIR[dir], YDIR[dir], costs[dir]);
    return res;
}

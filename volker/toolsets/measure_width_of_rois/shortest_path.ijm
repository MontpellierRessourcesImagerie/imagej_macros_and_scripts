var XDIR = newArray(-1, 0, 1, -1, 0, 1, -1, 0, 1);
var YDIR = newArray(-1, -1, -1, 0, 0, 0, 1, 1, 1);
var LAST_X = 0;
var LAST_Y = 0;
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
    nextPointAndCost = getBestNeighbor(pathX[lastIndex], pathY[lastIndex], x2, y2, directSquaredDist);
    pathX = Array.concat(pathX, nextPointAndCost[0]);
    pathY = Array.concat(pathY, nextPointAndCost[1]);
    if (nextPointAndCost[2]==0) DONE = true;
    steps++;
}
makeSelection("freeline", pathX, pathY);


function getBestNeighbor(x, y, xDest, yDest, directSquaredDist) {
    width = newArray(9);
    dist = newArray(9);
    directSquaredDist = pow(xDest - x, 2) +  pow(yDest - y, 2);
    width[0] = getPixel(x-1, y-1) / maxWidth;
    dist[0] =( pow(xDest - (x-1), 2) +  pow(yDest - (y-1), 2) ) / directSquaredDist;
    width[1] = getPixel(x, y-1) / maxWidth;
    dist[1] = ( pow(xDest - x, 2) +  pow(yDest - (y-1), 2) ) / directSquaredDist;
    width[2] = getPixel(x+1, y-1) / maxWidth;
    dist[2] = ( pow(xDest - (x+1), 2) +  pow(yDest - (y-1), 2) ) / directSquaredDist;
    width[3] = getPixel(x-1, y) / maxWidth;
    dist[3] = ( pow(xDest - (x-1), 2) +  pow(yDest - y, 2) ) / directSquaredDist;
    width[4] = 0;
    dist[4] = 0;
    width[5] = getPixel(x+1, y) / maxWidth;
    dist[5] = ( pow(xDest - (x+1), 2) +  pow(yDest - y, 2) ) / directSquaredDist;
    width[6] = getPixel(x-1, y+1) / maxWidth;
    dist[6] = (pow(xDest - (x-1), 2) +  pow(yDest - (y+1), 2) ) / directSquaredDist;
    width[7] = getPixel(x, y+1) / maxWidth;
    dist[7] = ( pow(xDest - x, 2) +  pow(yDest - (y+1), 2) ) / directSquaredDist;
    width[8] = getPixel(x+1, y+1) / maxWidth;
    dist[8] = ( pow(xDest - (x+1), 2) +  pow(yDest - (y+1), 2) ) / directSquaredDist;
    
    Array.print(width);
    
    ranks = Array.rankPositions(width);
    Array.print(ranks);
 
    index1 = ranks[ranks.length-1];
    index2 = ranks[ranks.length-2];
    
    dir = index1;
    if (dist[index2] < dist[index1]) dir = index2;
    if ((x + XDIR[index1] == LAST_X) && (y + YDIR[index1] == LAST_Y)) dir = index2;
    if ((x + XDIR[index2] == LAST_X) && (y + YDIR[index2] == LAST_Y)) dir = index1;
        
    LAST_X = x+XDIR[dir];
    LAST_Y = y+YDIR[dir];
    res = newArray(LAST_X, LAST_Y, width[dir]);
    Array.print(res);
    return res;
}

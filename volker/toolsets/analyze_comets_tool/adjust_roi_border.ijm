var _DELTA_X = 2;
var _MAX_RADIUS = 100;
var _LINE_WIDTH = 13;
var _MIN_TOLERANCE = 0.3;
run("Interpolate", "interval=1 smooth adjust");
getSelectionCoordinates(xpoints, ypoints);
N = xpoints.length;
xPointsCorrected = newArray(xpoints.length);
yPointsCorrected = newArray(xpoints.length);
for (i = 0; i < xpoints.length; i++) {
	i0 = i-_DELTA_X;
	if (i0<0) i0 = N + i0;
	i1 = (i+_DELTA_X) % N;
	makeLine(xpoints[i0], ypoints[i0], xpoints[i1], ypoints[i1]);
	run("Rotate...", "angle=90");
 	getSelectionCoordinates(xL, yL);
    x1 = xL[0];
    y1 = yL[0];
    x2 = xL[xL.length-1];	
    y2 = yL[yL.length-1];
	dx = x2-x1;	
    dy = y2-y1;
    n = round(sqrt(dx*dx + dy*dy));
    xInc = _MAX_RADIUS * (dx / n);
    yInc = _MAX_RADIUS * (dy / n);
    makeLine(xpoints[i], ypoints[i], xpoints[i]+xInc, ypoints[i1]+yInc, _LINE_WIDTH);
    profile1 = getProfile();
    minima1 = Array.findMinima(profile1, _MIN_TOLERANCE);
    if(minima1.length==0) min = 0;
    else min = minima1[0];
    makeLine(xpoints[i], ypoints[i], xpoints[i]-xInc, ypoints[i1]-yInc, _LINE_WIDTH);
    profile2 = getProfile();
    minima2 = Array.findMinima(profile2, _MIN_TOLERANCE);
    if(minima2.length==0) min2 = 0;
    else min2 = minima2[0];
    if (profile1[min]<profile2[min2]) {
    	xPointsCorrected[i] = xpoints[i]+min*(dx / n);
    	yPointsCorrected[i] = ypoints[i]+min*(dy / n);
    } else {
    	xPointsCorrected[i] = xpoints[i]-min2*(dx / n);
    	yPointsCorrected[i] = ypoints[i]-min2*(dy / n);    
    }
}
makeSelection("freehand", xPointsCorrected, yPointsCorrected);
run("Fit Spline");
run("Interpolate", "interval=1 smooth adjust");
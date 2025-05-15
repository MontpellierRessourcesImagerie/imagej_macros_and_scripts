nrOfRois = Overlay.size
for (i = 0; i < nrOfRois; i++) {
    angles = newArray(0);
    events = newArray(0);
    Overlay.activateSelection(i);  
    getSelectionCoordinates(xpoints, ypoints);
    direction = 1;
    for(j=1; j<xpoints.length; j++) { 
        x1 = xpoints[j-1];
        y1 = ypoints[j-1];
        x2 = xpoints[j];
        y2 = ypoints[j];
        l = sqrt(pow(x2 - x1, 2) + pow(y2-y1, 2));
        angleRad = asin((x2-x1) / l);
        angle = Math.toDegrees(angleRad);
        if (j==1) {
            if (angle < 0) direction = -1;
        }
        angle = angle * direction;
        angles = Array.concat(angles, angle);
    }
    Array.print(angles);
    if (angles.length < 2) continue;
    for(j=1; j<angles.length; j++) {
        angle1 = angles[j-1];
        angle2 = angles[j];
        event = "Speed change";
        if (angle1>0 && angle2<0) event = "Catastrophe";
        if (angle1<0 && angle2>0) event = "Rescue";
        events = Array.concat(events, event);
    }
    Array.print(events);
}



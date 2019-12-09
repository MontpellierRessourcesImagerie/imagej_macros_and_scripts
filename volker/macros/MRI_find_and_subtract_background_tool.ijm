var _SUBTRACT_BACKGROUND_RADIUS = 1;
var _SUBTRACT_BACKGROUND_OFFSET = 1;
var _SUBTRACT_BACKGROUND_ITERATIONS = 2;

back = findBackground(_SUBTRACT_BACKGROUND_RADIUS, _SUBTRACT_BACKGROUND_OFFSET, _SUBTRACT_BACKGROUND_ITERATIONS);
print(back);

function findBackground(radius, offset, iterations) {
	width = getWidth();
	height = getHeight();
	for(i=0; i<iterations; i++) {
    	getStatistics(area, mean, min, max, std, histogram); 
        minPlusOffset =  min + offset;
        currentMax = 0;
        for(x=0; x<width; x++) {
			for(y=0; y<height; y++) {
				intensity = getPixel(x,y);
				if (intensity<=minPlusOffset) {
				     value = getMaxIntensityAround(x, y, mean, radius, width, height);
				     if (value>currentMax) currentMax = value;	
				}
			}
        }
        result = currentMax / (i+1);
	}
	return result;
}

function getMaxIntensityAround(x, y, mean, radius, width, height) {
    max = 0;
    for(i=x-radius; i<=x+radius; i++) {
        if (i>=0 && i<width) {
               for(j=y-radius; j<=y+radius; j++) {
                      if (j>=0 && j<height) {
	    					value = getPixel(i,j);
                            if (value<mean && value>max)  max = value;
                      }
               }
        }
    }
    return max;
}
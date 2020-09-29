_IMG_WIDTH = 1024;
_IMG_HEIGHT = 1024;
_NR_OF_IMAGES = 1;
_NR_OF_NUCLEI_MEAN = 4;
_NR_OF_NUCLEI_STD = 1;
_RADIUS_MEAN = 30;
_RADIUS_STD = 3;


for (i = 0; i < _NR_OF_IMAGES; i++) {
	newImage("Untitled", "8-bit black", 1024, 1024, 1);	
	nrOfNuclei = round(random("gaussian")*_NR_OF_NUCLEI_STD + _NR_OF_NUCLEI_MEAN);	
	for (n = 0; n < nrOfNuclei; n++) {
		radius =  round(random("gaussian")*_RADIUS_STD + _RADIUS_MEAN);	
		x = round(random * _IMG_WIDTH);
		y = round(random * _IMG_HEIGHT);
		fillOval(x-radius, y-radius, 2*radius+1, 2*radius+1);
		angle = random * 2 * PI;
		r = random * radius;
		x2 = x + r * cos(angle);
		y2 = y + r * sin(angle);
		radius2 =  round(random("gaussian")*_RADIUS_STD*2 + _RADIUS_MEAN);	
		fillOval(x2-radius2, y2-radius2, 2*radius2+1, 2*radius2+1);
	}

	print(nrOfNuclei);
	//close();
}


macro "Random LUT" {
    reds = newArray(256); 
    greens = newArray(256); 
    blues = newArray(256);
    
    for (i = 0 ; i < 256 ; i++){
    	reds[i] = Math.floor(256 * random);
    	greens[i] = Math.floor(256 * random);
    	blues[i] = Math.floor(256 * random);
    }
    
    reds[0] = 0;
	greens[0] = 0;
	blues[0] = 0;
    
    setLut(reds, greens, blues);
}
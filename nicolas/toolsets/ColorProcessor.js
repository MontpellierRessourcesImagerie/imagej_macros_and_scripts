count = 100;
centre = count/2;
print("hello word");

for(i = 0; i < count; i++){ 
	
	// centre = count/2;
	
	x= (i-centre)/80;
	
	amplitude = 1/(Math.sqrt(2)*80);
	
	color = amplitude * Math.exp(-1*Math.power(x,2)/2 )*65536;
	
	print("color  " + color);
	
	waitForUser;
	
}

Math.pow(base, exponent)
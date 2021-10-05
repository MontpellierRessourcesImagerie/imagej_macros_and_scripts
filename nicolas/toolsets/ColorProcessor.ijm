count = 100;
centre = count/2;
print("hello word");
color = newArray();

for(i = 0; i < count; i++){ 
	
	// centre = count/2;
	
	x= (i-centre)/80;
	
	amplitude = 1/(Math.sqrt(2)*80);
	
	color[i] = amplitude * Math.exp(-1*Math.pow(x,2)/2 )*65536;
	//color[i] = Math.exp(-1*Math.pow(x,2)/2 );
	
	
	print("color  " + color[i]);
	
	// waitForUser;
	
}

Array.print(color);

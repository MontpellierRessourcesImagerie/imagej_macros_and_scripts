
width = getWidth();
height = getHeight();

BB = newArray(width/2*height/2);
BH = newArray(width/2*height/2);
HB = newArray(width/2*height/2);
HH = newArray(width/2*height/2);

run("8-bit");
id_noise = getImageID();
selectImage(id_noise);

// print(id_noise);
Title_Image_Noise = getTitle();

// print("Title_Image_Noise "+Title_Image_Noise);
selectImage(id_noise);

run("Duplicate...", " ");

run("Subtract Background...", "rolling=100");

for(i=1; i<=4; i++) {
	
}


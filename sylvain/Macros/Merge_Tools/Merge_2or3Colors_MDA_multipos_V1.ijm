//MACRO developpée pour Marion Peter
//S.DeRossi_Juin2018
//Permet d'automatiser les merges en 2 ou 3 couleurs d'images provenant de MetaMorph (via l'acquisition du MDA)
//channels possibles : DAPI - GFP - DsRed
//Permet de choisir si les acquisitions ont été réalisées en multiple positions ou non (option)
//***************************************************************************************************************

//In and out folders
dir1 = getDirectory("Choose Source Directory ");
dir2 = getDirectory("Choose Destination Directory ");

list = getFileList(dir1);

Number_Colors=getNumber("Number of channels (2 or 3 only)", 2);
Pos=getBoolean("Say YES for multiple positions");

//Condition for multiple positions or not
if (Pos==1) {
Number_Positions=getNumber("Number of positions", 2);
Name=getString("Write name of images","");
}

//--------------MAIN PROGRAM-------------
//***************************************

//condition for 2 or 3 colors
if (Number_Colors==2) {
W1=getString("First color","GFP");
W2=getString("Second color","DAPI");}
else {
W1=getString("First color","DsRed");
W2=getString("Second color","GFP");
W3=getString("Third color","DAPI");}

	//Case : Multiple positions------------
	if (Number_Colors==2 && Pos==1) {
		for (s=1; s<Number_Positions+1; s++) {
			open (dir1+Name+"_w1"+W1+"_s"+s+".tif");
			name1=getTitle();
			open (dir1+Name+"_w2"+W2+"_s"+s+".tif");
			name2=getTitle();
		
			TwoColors();
			save(dir2+Name+"_merge_s"+s);
			run("Close All");
		}
	}

	if (Number_Colors==3 && Pos==1) {
		for (s=1; s<Number_Positions+1; s++) {
			open (dir1+Name+"_w1"+W1+"_s"+s+".tif");
			name1=getTitle();
			open (dir1+Name+"_w2"+W2+"_s"+s+".tif");
			name2=getTitle();
			open (dir1+Name+"_w3"+W3+"_s"+s+".tif");
			name3=getTitle();
		
			ThreeColors();
			save(dir2+Name+"_merge_s"+s);
			run("Close All");
		}
	}

	//Case : single position -------------
	if (Number_Colors==2 && Pos==0) {
		for (i=0; i<list.length ;i+=2) {
			open(dir1+list[i]);
			name1=getTitle();
			open(dir1+list[i+1]);
			name2=getTitle();

			TwoColors();
			
			index=indexOf(name1, "_w");
			name=substring(name1, 1, index);
			save(dir2+name+"_MERGE");
			run("Close All");
		}
	}
	
	if (Number_Colors==3 && Pos==0) {
		for (i=0; i<list.length ;i+=3) {
			open(dir1+list[i]);
			name1=getTitle();
			open(dir1+list[i+1]);
			name2=getTitle();
			open(dir1+list[i+2]);
			name3=getTitle();

			ThreeColors();
			
			index=indexOf(name1, "_w");
			name=substring(name1, 1, index);
			save(dir2+name+"_MERGE");
			run("Close All");
		}
	}

//------------FUNCTIONS--------------

function TwoColors() {

		if (endsWith(W1,"I") && endsWith(W2,"P")) {
		run("Merge Channels...", "c2=["+name2+"] c3=["+name1+"] create");}

		if (endsWith(W1,"I") && endsWith(W2,"d")) {
		run("Merge Channels...", "c1=["+name2+"] c3=["+name1+"] create");}
		
		if (endsWith(W1,"P") && endsWith(W2,"I")) {
		run("Merge Channels...", "c2=["+name1+"] c3=["+name2+"] create");}

		if (endsWith(W1,"d") && endsWith(W2,"I")) {
		run("Merge Channels...", "c1=["+name1+"] c3=["+name2+"] create");}
		
}
		
function ThreeColors() {

		if (endsWith(W1,"d") && endsWith(W2,"P") && endsWith(W3,"I")) {
		run("Merge Channels...", "c1=["+name1+"] c2=["+name2+"] c3=["+name3+"] create");}

		if (endsWith(W1,"P") && endsWith(W2,"d") && endsWith(W3,"I")) {
		run("Merge Channels...", "c1=["+name2+"] c2=["+name1+"] c3=["+name3+"] create");}
		
		if (endsWith(W1,"d") && endsWith(W2,"I") && endsWith(W3,"P")) {
		run("Merge Channels...", "c1=["+name1+"] c2=["+name3+"] c3=["+name2+"] create");}

		if (endsWith(W1,"P") && endsWith(W2,"I") && endsWith(W3,"d")) {
		run("Merge Channels...", "c1=["+name2+"] c2=["+name3+"] c3=["+name1+"] create");}

		if (endsWith(W1,"I") && endsWith(W2,"P") && endsWith(W3,"d")) {
		run("Merge Channels...", "c1=["+name3+"] c2=["+name2+"] c3=["+name1+"] create");}

		if (endsWith(W1,"I") && endsWith(W2,"d") && endsWith(W3,"P")) {
		run("Merge Channels...", "c1=["+name3+"] c2=["+name1+"] c3=["+name2+"] create");}
		
}

/**
  * discrete_histogram_entropy_.ijm
  * 
  * Calculates the discrete histogram entropy 
  * for the result of the Directionality plugin
  *   
  * (c) 2019, INSERM
  * 
  * written by Volker Baecker at Montpellier Ressources Imagerie (www.mri.cnrs.fr)
  *
  * USAGE:
  *  Run the Directionality plugin (see https://imagej.net/Directionality) on your image
  *  Select "Display table" in the dialog. Activate the results table containing for each direction
  *  the normalized frequency of the data and the fit. Run the macro. The discrete histogram entropy 
  *  is written to the log window.
  *  
  *  The macro is available on git-hub:
  *  https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/blob/master/volker/macros/discrete_histogram_entropy_.ijm
  *  
  */
  
content = getInfo("window.contents");
lines = split(content, "\n");
line0 = split(lines[0],"\t");
imageTitle = line0[1];
directions = newArray(lines.length-1);
frequencies = newArray(lines.length-1);
for (i = 1; i < lines.length; i++) {
	line =  split(lines[i],"\t");
	directions[i-1] = parseFloat(line[0]);
	frequencies[i-1] = parseFloat(line[1]);
}

binWidth = abs(directions[0]-directions[1]);

entropy = 0;
for(i=0; i<directions.length; i++) {
	entropy += frequencies[i]*log(frequencies[i]/binWidth);
}

entropy *= -1;

print("Entropy of " + imageTitle + ": "+entropy);
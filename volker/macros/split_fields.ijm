NUMBER_OF_FIELDS = 5;

title = getTitle();
zSlices = nSlices / NUMBER_OF_FIELDS;
field = 1;
inputImageID = getImageID();
for(startSlice = 1; startSlice   < nSlices; startSlice = startSlice + zSlices) {
    fieldText = IJ.pad(field, 2);
    endSlice = startSlice + zSlices - 1;
    print(startSlice, endSlice);
    run("Duplicate...", "duplicate range=" + startSlice + "-" + endSlice);
    rename("f" + fieldText + "-" + title); 
    selectImage(inputImageID);
    field++;
}




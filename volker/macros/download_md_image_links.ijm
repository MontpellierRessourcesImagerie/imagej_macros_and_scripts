names = newArray(0);
urls = newArray(0);
path = File.openDialog("Please select a file containing a list of markdown links!");
outputDir = getDir("Please select the output directory!");
links = File.openAsString(path);
linksList = split(links, "\n");
for (i = 0; i < linksList.length; i++) {
    line = linksList[i];
    if (indexOf(line, "]")<0) continue;
    parts = split(line, "]");
    name = parts[0];
    name = replace(name, '[', '');
    name = replace(name, '!', '');
    url = parts[1];
    url = replace(url, '(', '');
    url = replace(url, ')', '');
    names = Array.concat(names, name);
    urls = Array.concat(urls, url);
}
setBatchMode(true);
for (i = 0; i < urls.length; i++) {
    IJ.log("Saving image " + (i+1) + " of " + urls.length);
    open(urls[i]);
    save(outputDir + "/" + names[i]);
    close();
}
setBatchMode(false);

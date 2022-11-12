
Plot.getValues(xpoints, ypoints);
id = getImageID();
title = getTitle();
Array.reverse(ypoints);

Plot.create(title, "distance [pixels]", "width [pixels]");
Plot.useTemplate(id);
Plot.add("line", xpoints, ypoints);

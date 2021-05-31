# Imagej macros and scripts
ImageJ macros and scripts written at the imaging facility MRI. Have a look at the project's [wiki](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki) to get more information about the image analysis tools.

### <a id="biat">Biological Image Analysis Toolsets</a>

#### [3D_Nuclei_Clustering_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/3D_Nuclei_Clustering_Tool)

<img align='right'  src="https://camo.githubusercontent.com/bbacc018a6355a54cde721db6afc5523a640683b/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323134382f636c7573746572732e706e67" height='100'/> Analyze the clustering behavior of nuclei in 3D images. The centers of the nuclei are detected. The nuclei are filtered by the presence of a signal in a different channel. The clustering is done with the density based algorithm DBSCAN. The nearest neighbor distances between all nuclei and those outside and inside of the clusters are calculated.
 
#### [Adipocytes Tools](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Adipocytes-Tools)

<img align='right' src="https://camo.githubusercontent.com/22f44aa8689f32c7f146d8fd9de9bd6aef85d0e7/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f3139352f726573756c742e706e67" height='100'/> The Adipocytes Tools help to analyze fat cells in images from histological section.

####   [MRI_Analyze_Alignment_of_Muscles_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Analyze_Alignment_of_Muscles_Tool)

<img align='right'  src="https://camo.githubusercontent.com/f380f817eba0675348fbe9a1068e7b8a35468e3b/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323137382f6578616d706c655f6f665f726573756c74732e706e67" height='100'/> The tool uses the Directionality plugin to measure the main direction of the structures in the image and the dispersion. It is used in this context to analyze to which degree the muscles in the image are vertically aligned. The tool allows to run the Directionality plugin in batch-mode on a series of images. The direction-histograms and the measurements are exported as csv-files. 
####   [Analyze_Calcium_Signals_In_Spines](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Analyze_Calcium_Signals_In_Spines)

<img align='right' src="https://camo.githubusercontent.com/fc1205eebe78576b143b37d90e5d9059e4390dd7/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323036332f74696d652d7365726965732e676966" height='100'/> Analyze calcium signals in dendritic spines. The images consist of time-series of calcium signals. Each image contains a selection that marks the point of stimulation. The tool finds the region to analyze close to the point of stimulation. It measures the intensity of the calcium signal in the whole region of interest and in the segmented spots. 
####   [Analyze_Cardiomyocytes](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Analyze_Cardiomyocytes)

<img  align='right' src="https://camo.githubusercontent.com/8edc2919658e4f9b23c909114448dd7411681a06/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f313736302f726573756c742d696d6167652e706e67" height='100'/> Analyze images from second harmonics microscopy of cardiac muscle cells (cardiomyocytes). The tool measures the length of the sarcomeres using the FFT of the image and the degree of organization of the sarcomeres by using the dispersion provided by the Directonality command of FIJI. Although the input images can be stacks only the middle slice is used for the analysis. 
#### [MRI_Analyze_Comets_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Analyze_Comets_Tool)

<img  align='right' src="https://camo.githubusercontent.com/42ebc19d3498eefc6e9266a4203b6d3029ea6a37/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323235352f636f6d6574732e706e67" height='100'/> The tool measures the areal number density of comets in cells.
####   [Analyze_Complex_Roots_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Analyze_Complex_Roots_Tool)

<img  align='right' src="https://camo.githubusercontent.com/8bac5dbeb7dffd377713c69d4a492b954d1d001a/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323037382f6d61736b2e6a7067" height='100'/> This tool allows to analyze morphological characteristics of complex roots. While for young roots the root system architecture can be analyzed automatically, this is often not possible for more developed roots. The tool is inspired by the Sholl analysis used in neuronal studies. The tool creates a binary mask and the Euclidean Distance Transform from the input image. It then allows to draw concentric circles around a base point and to extract measures on or within the circles. Instead of circles, which present the distance from the base point, horizontal lines can be used, which present the distance in the soil from the base-line.  
####   [Analyze Spheroid Cell Invasion In 3D Matrix](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Analyze-Spheroid-Cell-Invasion-In-3D-Matrix)

<img align='right' src="https://camo.githubusercontent.com/e7c145a696d067044b15e62cb436fa3619d54ffb/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323032312f63656c6c5f696e766173696f6e2e676966" height='100'/> The tool allows to measure the area of the invading spheroïd in a 3D cell invasion assay. It can also count and measure the area of the nuclei within the speroïd.  
####   [Analyse Spots Per Protoplast](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Analyse-Spots-Per-Protoplast)

<img  align='right' src="https://camo.githubusercontent.com/781a8b16ce76e195318d22645a022e22dbad32b5/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f313732312f726573756c742d69616d67652e706e67" height='100'/> The tool counts the spots per protoplast. If a third channel is provided it is used to filter out detected protoplasts that do not have exactly one nucleus. 
####   [Arabidopsis Seedlings Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Arabidopsis-Seedlings-Tool)

<img align='right' src="https://camo.githubusercontent.com/cce4e169e9b41e67944c5ec80ec6bb997e9a7b0d/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f3436302f413030386430352d312d312e6a7067" height='100'/> The Arabidopsis Seedlings Tool allows to measure the surface of green pixels per well in images containing multiple wells. It can be run in batch mode on a series of images. It writes a spreadsheet file with the measured area per well and saves a control image showing the green surface that has been detected per well. 
####   [Cluster Analysis of Nuclei Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Cluster-Analysis-of-Nuclei-Tool)

<img align='right' src="https://camo.githubusercontent.com/b107e3e2354a4be28166bdd71e35dcd6c7c2ce89/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f313937312f323031382d30362d32302d6c696e65732d6563684c372d30335f7732444150492d312e6a7067" height='100'/> Analyze the clustering behavior of nuclei in DAPI stained images. The nuclei are detected as the maxima in the image. Using a threshold intensity value, maxima below the threshold are eliminated. The resulting points are clustered using the DBSCAN algorithm. The nearest neighbor distances between all nuclei, and those outside and inside of the clusters are calculated. 
####   [Count Axonal Projections Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Count-Axonal-Projections-Tool)

<img align='right' src="https://camo.githubusercontent.com/e87acfaf56e95c80511ec4f77c35f1af6919a083/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323231392f70726f6a656374696f6e732e706e67" height='100'/> Count the number of axonal projections that cross a given line. The tool detects and counts the maxima along a line-selection, for example a segmented line. 
####   [Count Satellites Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Count_Satellites_Tool)

<img align='right' src="https://camo.githubusercontent.com/8af7ef68b0988b52db3a292c7a04dda428d9bbeb0083e1886ad3bc30e05a6ada/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323239392f73656c5f544e452532305036302532302532304d656469616c25323041253230436f7274657825323046726f6e74616c253230353078302e36372532303230782532304e65754e253230446170692d315f323032302d31312d31375431372d32392d33302e3437342e706e67" height='100'/> The tool detects and counts the neurons and the neurons with satellite cells. 
####   [MRI_Count_Spot_Populations_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Count_Spot_Populations_Tool)   

<img align='right' src="https://camo.githubusercontent.com/9c839fa70455c2ebe7b82400bb5afa2f7763f116/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323230372f64657465637465645f73706f74732e706e67" height='100'/> The tool detects and and counts the spots (or blobs) in an image. It has been created for the counting of bacteria colonies in in Petri-dishes. It separates the spots into two populations and counts each population individually. The populations are separated by the area of the spots. The tool uses expectation maximisation clustering from the weka software. 
#### [Distance_Between_Minima_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Distance_Between_Minima_Tool)

<img align='right' src="https://camo.githubusercontent.com/0c6397df2c058969b4b9d242c8939a6c248ed878c4dad57a05f36863668e39c4/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323232342f706c6f742e706e67" height='100'/> The tool measures the mean distance between the minima in the profile plot. 
####   [MRI_Create_Synthetic_Spots_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Create_Synthetic_Spots_Tool)

<img align='right' src="https://camo.githubusercontent.com/054649b1a184aa24155b0feb633c20bf28c5dc03/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323035352f73706f74732e706e67" height='100'/> The tool creates images of 2D-spots for the evaluation and benchmarking of spot detection tools. Two populations of spots with different means and variations of the size can be created in the same image. 
####   [MRI_Fibrosis_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Fibrosis_Tool) 

<img align='right' src="https://camo.githubusercontent.com/7571589a6dbdd5b6ee98470e3c269bd353e12ebf/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f313532342f726573756c7430312e706e67" height='100'/> Measure the relative area of sirius red stained fibrosis. The tool uses the colour deconvolution plugin from Gabriel Landini. 
#### [Filament_Morphology_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Filament_Morphology_Tool)

<img align='right' src="https://camo.githubusercontent.com/32d07390b1741f99ff862054ca4f2ec5c73ee63472f8793c3cfdb5a80b4eb4b9/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323337362f696e7075745f696d6167652e706e67" height='100'/> The tool count filaments and measure their areas and forms. It specially measures the geodesic diameter of the objects and its curvature, counts the branches and measures their lengths.
#### [Filament_Tools](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Filament_Tools)

<img align='right' src="https://camo.githubusercontent.com/55fa2e7d5fbe76abc245f93b23a7f0a69bfc3926186b3664a0cee70f0f6a0d0d/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323333322f496d61676525323035395f4f75742d332e706e67" height='100'/> Calculate the area-fraction of the image filled with (septin) filaments.
####   [FLIM FRET_Volume_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/FLIM-FRET_Volume_Tool)   

<img align='right' src="https://camo.githubusercontent.com/6fac8a1722752fb2895d5c014ee84feb9a56c4ea/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323230302f4d6f7669652e676966" height='100'/> The tool measures in FLIM-FRET images, for each cell, the total volume of the cell and the volume occupied by values in a given range. It displays the positions of the values in the range in a result image. 
####   [Foci-Per-Nucleus-Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Foci-Per-Nucleus-Tool)

<img align='right' src="https://camo.githubusercontent.com/fa2414f47f58efce8420a34244e45aaf9aeca0b8/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323131382f666f63695f696e7075745f696d6167652e706e67" height='100'/> The tool detects, counts and measures the foci per nucleus. It reports the number of small, medium sized and big fosci per nucleus. It also measures the area and mean intensity of the nuclei. 
####   [MRI_g-ratio_Tools](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_g_ratio_Tools)

<img align='right' src="https://camo.githubusercontent.com/bd9b2d705282549818281cfe401c3db8e3bd2ba5384fd3eed08712ad04e24d1b/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f313831372f726573756c7430312e706e67" height='100'/> In images from transmission electron microscopy of the optic nerve, calculate the g-ratio of the axons. The pg-factor and the ag-factor will be measured. The pg-factor is the inner perimeter of the neuron divided by the outer perimeter including the myelin. The ag-factor is the square-root of the area of the inner surface divided by the area of the outer surface including the myelin. 
####   [MRI_Heights_of_Surfaces_Tools](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Heights_of_Surfaces_Tools)   

<img align='right' src="https://camo.githubusercontent.com/45baa9649b8929c3bf7ed3df623db8d3e945a3d3/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323135382f537572666163655f506c6f745f6f665f736461746130332e706e67" height='100'/> The tools help to compare the height in the z-dimension of the signals in different channels. It calculates the heights normalized by the maximum height in a reference channel. Only places where the signal is not zero and the reference channel maximal are taken into account. 
####   [Intensity Per Nucleus Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Intensity-Per-Nucleus-Tool)   

<img align='right' src="https://camo.githubusercontent.com/9b2b727905f39cf931003370c0202c36f6577618/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323131312f696e74656e736974795f7065725f6e75636c6575732e706e67" height='100'/> The tool segments the nuclei in the dapi or hoechst channel of the image and measures the mean intensity per nuclei in the other channels of the image. The macro can be applied recursively to all images in a folder and its subfolders. 
#### [Intensity Ratio Nuclei Cytoplasm Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Intensity-Ratio-Nuclei-Cytoplasm-Tool)

<img align='right' src="https://camo.githubusercontent.com/07e85430f821147445b434ccacbd250f7c0d851d/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f313231362f636f6e74726f6c2d696d6167652e706e67" height='100'/> The tool calculates the ratio of the intensity in the nuclei and the cytoplasm. It needs two images as input: the cytoplasm channel and the nuclei channel. The nuclei channel is used to segment the nuclei. The measurements are made in the cytoplasm channel after the background intensity has been corrected. 
####   [Measure_Border_And_Spots_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Measure_Border_And_Spots_Tool)

<img align='right' src="https://camo.githubusercontent.com/f52961f446b8594da6641fe0a26f7d024671f0931b9dea20feb64b2b39b77611/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323431352f6f75747075742e706e67" height='100'/> The tool counts the number of spots (foci) per nucleus and measures the intensity, form, size and position of the spots. It also optionally measures the intensity in the membrane of the nucleus. 
####   [Phase Contrast Cell Analysis Tool (Trainable WEKA Segmentation)](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Phase-Contrast-Cell-Analysis-Tool-%28Trainable-WEKA-Segmentation%29)

<img align='right' src="https://camo.githubusercontent.com/e595d2688291bbd480dd5f8e81736f126e4b04f9/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f313337372f726573756c7430312e706e67" height='100'/> The tool allows to segment cells in non fluorescent microscopy images using the trainable WEKA segmentation. It allows to run a preprocessing that crops and converts images, to apply a classifier created with the Trainable Weka Segmentation plugin to a folder containing images and to open the images in a folder as a stack in the "Trainable Weka Segmentation plugin" to create a classifier. 
####   [MRI_Plot_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Plot_Tool)

<img align='right' src="https://camo.githubusercontent.com/f7db852a5dce858eb90d258cbf47de76d9cfb11f/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323133382f506c6f742532306f66253230626c6f62735f48695265732d312e706e67" height='100'/> Calculate the first derivative of a plot and the zero-crossings of the derivate.
####   [MRI_Root_Hair_Tools](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Root_Hair_Tools)

<img align='right' src="https://camo.githubusercontent.com/f66c0184fed6d7bde076b10551b360cba144d47b/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f313834332f636f6e74726f6c2d696d6167652e706e67" height='100'/> The tool allows to measure the diameter of the root and the density of the root hair. 
####  [MRI_Spot_Coloc_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Spot_Coloc_Tool)
<img align='right' src="https://camo.githubusercontent.com/c1f38e7b32f8cf61fe5f1fcd0ee1e26ed4a87bfc/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323238312f35322d37302d485345542d313030704d2d3438382d3536312d343070657263656e742d3430306d732d32736563315f7731544952462d3536315f74312d312e706e67" height='100'/> The tool counts the number of co-localized spots in two channels over time. It also exports the intensity of each spot over time.
####   [Track_Microtubules_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Track_Microtubules_Tool) 

<img align='right' src="https://camo.githubusercontent.com/4e7f5ad704e7609d61df7097e28f456f06024fb0/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323034332f6578616d706c652e706e67" height='100'/> The tool allows to track the ends of fluorescently labelled microtubules, which are becoming shorter and to measure the speed of the movement of each end. It also creates kymograms and plots distance-per-time. 
####   [Transfection_Efficiency_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Transfection_Efficiency_Tool)

<img align='right' src="https://camo.githubusercontent.com/90f1403c7933b9517065f2f0daf0276772d0bd63/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323234312f7472616e736665637465642d73656c65637465642e706e67" height='100'/> The tool helps to measure the transfection efficiency. It reports the percentage of transfected cells in the image. It has tools to manually correct the segmented nuclei (merge and split). 
####   [Wound Healing Coherency Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Wound-Healing-Coherency-Tool) 

<img align='right' src="https://camo.githubusercontent.com/ac401c70a37ff4fd48c975f6e417e6f37a4da0ce/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f313738352f72657330312e706e67" height='100'/> The Wound Healing Coherency Tool can be used to analyze scratch assays. It measures the area of a wound in a cellular tissue on a stack of images representing a time-series. 

####   [Wound Healing Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Wound-Healing-Tool) 

<img align='right' src="https://camo.githubusercontent.com/3d2bc865f27ab24e3f5e84bf384b0dfb9a39e48d/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f3332342f776f756e642d6865616c696e672d72657330312e706e67" height='100'/> The MRI Wound Healing Tool can be used to analyze scratch assays. It measures the area of a wound in a cellular tissue on a stack of images representing a time-series. 

### Workflow and Conversion Toolsets

####   [MRI_Convert_Nikon_Andor_To_Hyperstack](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Convert_Nikon_Andor_To_Hyperstack) 

<img align='right' src="https://camo.githubusercontent.com/f59bd75632ac2d638b2641fbe37ddf2b6e3778f9/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f313935352f746f6f6c6261722e706e67" height='20'/> Because of the big size of the images the microscope cuts images along the time dimension into multiple files each with a number of frames. This tool will for each position and wavelength convert the image. It will do a z-projection, concatenate all time-chunks and save the resulting image. The user has to provide the number of slices in the z-dimension. The pixel size and time interval can automatically be set when provided by the user. 
####   [MRI_Convert_Opera_To_Hyperstack](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Convert_Opera_To_Hyperstack) 

<img align='right' src="https://camo.githubusercontent.com/224c68fe6180011d5fe9e65824f0cf34d861704d/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f313933382f746f6f6c7365742e706e67" height='20'/> The tool converts images taken with the Opera into hyperstacks. The image names are in the form ``r02c04f01p01-ch1sk1fk1fl1.tiff`` where r is the row, c the column, f the field, p the z-position and ch the channel. The tool converts all images in the input folder. 
####   [MRI_Image_Conversion_Tools](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Image_Conversion_Tools) 

<img align='right' src="https://camo.githubusercontent.com/1a2c09cafcaab7de2ba8571df623cab293b94ac8f47fd7f074431e8701b21160/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f3238382f6d72695f696d6167655f636f6e76657273696f6e5f746f6f6c7365742e706e67" height='20'/>  The tools allow to convert .lei or .lif and .lsm files to tif-files. It works on a folder containing the input images. Results are written into a sub-folder `tif`. Each channel of a multi-channel file is saved separately. Besides this an rgb-snapshot of the image is saved. A z-projection can optionally be applied to the images.
####   [Load-Corresponding-Images](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Load-Corresponding-Images)

<img align='right' src="https://camo.githubusercontent.com/50b8fe6bc3fd3dd13f0ef8570f0d3cd73a1b774a/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323032362f746f6f6c6261722e706e67" height='20'/> The tool allows to open for each image a second image with the same name from another folder. It displays the two images next to each other. It provides navigation through the list of images. 
####   [MRI_ND_To_Hyperstack](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_ND_To_Hyperstack)

<img align='right' src="https://camo.githubusercontent.com/e3017f74f83089448d82a920f85ab1a2f2acf959/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f313936332f746f6f6c6261722e706e67" height='20'/> The tools converts images in the .nd format to ImageJ hyperstacks. The user selects an .nd file. An image can consist of multiple positions, frames, z-slices and channels. Each position is converted into an ImageJ hyperstack and written into a subfolder of the folder containing the input image. 
#### [NDPI export regions](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/NDPI_Export_Regions_Tool)
 <img align='right' src="https://camo.githubusercontent.com/8c6723099eb5741d403866becad3bafed04d1af2/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323237332f6578706f72742d6e6470692d746f6f6c6261722e706e67" height='20'/>The tool exports rectangular regions, defined with the NDP.view 2 software from the highest resolution version of the image and saves them as tif-files.
####  [MuVi SPIM_Convert_Tools](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MuVi-SPIM_Convert_Tools)

<img align='right' src="https://raw.githubusercontent.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/master/sylvain/Macros/MuVi_SPIM_Convert_MIP_Tools/wiki_images/1.montage.PNG" height='100'/> The Muvi-SPIM-Convert_Tools help to convert your hdF5 files comming from a MuVi-SPIM setup. 
 
### Single Plugin Tools

#### [Discrete_Histogram_Entropy_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Discrete_Histogram_Entropy_Tool)

<img align='right' src="https://camo.githubusercontent.com/216da1acd9d419fa0405d0d2d9817aef62d85ddc/687474703a2f2f63686172742e617069732e676f6f676c652e636f6d2f63686172743f6368743d74782663686c3d482858293d2d25354373756d5f253742693d312537442535452537426e2537446628785f692925354363646f742535436c6f672535436c65667428253742253543667261632537426628785f69292537442537427728785f6929253744253744253543726967687429" height='50'/> The tool calculates the discrete histogram entropy H(X), where w is the width of the i-th histogram bin and f the frequency of the value xi. 
#### [Distance_Between_Minima_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Distance_Between_Minima_Tool)

<img align='right' src="https://camo.githubusercontent.com/0ee4ca81c3c478384212e86d06a0ff033ad46973/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323232342f706c6f742e706e67" height='100'/> The tool measures the mean distance between the minima in the profile plot. 
#### [MRI_DoG_Filter](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_DoG_Filter)

<img align='right'  src="https://camo.githubusercontent.com/45ee7567107da46ec5967dea62e16f3505256fe35e5efbd54cc3c81012841114/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323331372f646f672e706e67" height='100'/> The DoG-filter is a bandpass filter. It is calculated as: Gauss_s1(img) - Gauss_s2(img) where img is the input image, Gauss_s1 is a Gaussian-filter with sigma s1 and Gauss_s2 is a Gaussian-filter with sigma s2 (s2>s1). 
#### [Find_and_Subtract_Background_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Find_and_Subtract_Background_Tool)

<img align='right' src="https://camo.githubusercontent.com/fff7a01f22b1ae644811fad5c6b00c47353f4f52/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323139322f696d6167652d7365726965732e706e67" height='100'/> The tool finds the background intensity value and subtract it from the current image. It searches for the maximum intensity value around pixels that are below or equal to the minimum intensity in the image plus an offset. 
#### [MRI_Random_Selection_From_Table_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Random_Selection_From_Table_Tool)

<img align='right' src="https://camo.githubusercontent.com/2319c1d2f934317d19955a5cd63d3e1a8086542d2e06f6da37fe5593b108f8ff/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323332352f7461626c655f696e2e706e67" height='100'/> The tool allows to create a sub-population of your data by randomly copying a configurable portion of lines from the active table to a new table. 
#### [Time_Reverse_Hyperstack_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Time_Reverse_Hyperstack_Tool)

<img align='right' src="https://camo.githubusercontent.com/c7e429b163c90bb887961de5077c966aa148d6c8d9fd7021715777b38ab090d7/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323333362f74696d652d726576657273655f746f6f6c7365742e706e67" height='20'/> The tool reverses the order of the frames in a hyperstack. 

### Scripts
#### [MRI_Spiral_Mosaic_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Spiral_Mosaic_Tool)

<img align='right' src="https://camo.githubusercontent.com/1286c071c479eb1d7ed1a1eb5dc51f035fb323fe/687474703a2f2f6465762e6d72692e636e72732e66722f6174746163686d656e74732f646f776e6c6f61642f323237382f74312d686561642e7469662d2532307265636f6e73747275637465642d312e706e67" height='100'/> The tool copies the images in a stack into a new image and places them in a spiral order, i.e. the first image is in the middle, the second right of the first, the third above the second, the fourth left of the third, and so on. 

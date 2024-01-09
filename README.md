# Imagej macros and scripts
ImageJ macros and scripts written at the imaging facility MRI. Have a look at the project's [wiki](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki) to get more information about the image analysis tools.

### <a id="biat">Biological Image Analysis Toolsets</a>

#### [3D_Nuclei_Clustering_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/3D_Nuclei_Clustering_Tool)

<img align='right'  src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/f84d0433-a66d-4b52-83f6-61e9afca5496" height='100'/> Analyze the clustering behavior of nuclei in 3D images. The centers of the nuclei are detected. The nuclei are filtered by the presence of a signal in a different channel. The clustering is done with the density based algorithm DBSCAN. The nearest neighbor distances between all nuclei and those outside and inside of the clusters are calculated.
 
#### [Adipocytes Tools](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Adipocytes-Tools)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/91b8272e-27c8-427a-975f-211b839c8e1d" height='100'/> The Adipocytes Tools help to analyze fat cells in images from histological section.

####   [MRI_Analyze_Alignment_of_Muscles_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Analyze_Alignment_of_Muscles_Tool)

<img align='right'  src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/e7e55b9a-575c-4ab3-8336-ffb770976221" height='100'/> The tool uses the Directionality plugin to measure the main direction of the structures in the image and the dispersion. It is used in this context to analyze to which degree the muscles in the image are vertically aligned. The tool allows to run the Directionality plugin in batch-mode on a series of images. The direction-histograms and the measurements are exported as csv-files. 
####   [Analyze_Calcium_Signals_In_Spines](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Analyze_Calcium_Signals_In_Spines)

<img align='right' src="http://dev.mri.cnrs.fr/attachments/download/2063/time-series.gif" height='100'/> Analyze calcium signals in dendritic spines. The images consist of time-series of calcium signals. Each image contains a selection that marks the point of stimulation. The tool finds the region to analyze close to the point of stimulation. It measures the intensity of the calcium signal in the whole region of interest and in the segmented spots. 
####   [Analyze_Cardiomyocytes](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Analyze_Cardiomyocytes)

<img  align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/55a69edb-61cf-4374-bb8f-200885ab2b43" height='100'/> Analyze images from second harmonics microscopy of cardiac muscle cells (cardiomyocytes). The tool measures the length of the sarcomeres using the FFT of the image and the degree of organization of the sarcomeres by using the dispersion provided by the Directonality command of FIJI. Although the input images can be stacks only the middle slice is used for the analysis. 
#### [MRI_Analyze_Comets_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Analyze_Comets_Tool)

<img  align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/0990f1e6-8dc5-422d-9ac2-02a6250fe739" height='100'/> The tool measures the areal number density of comets in cells.
####   [Analyze_Complex_Roots_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Analyze_Complex_Roots_Tool)

<img  align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/1b1504d3-7a49-4105-84fd-076e11c43f76" height='100'/> This tool allows to analyze morphological characteristics of complex roots. While for young roots the root system architecture can be analyzed automatically, this is often not possible for more developed roots. The tool is inspired by the Sholl analysis used in neuronal studies. The tool creates a binary mask and the Euclidean Distance Transform from the input image. It then allows to draw concentric circles around a base point and to extract measures on or within the circles. Instead of circles, which present the distance from the base point, horizontal lines can be used, which present the distance in the soil from the base-line.  
####   [Analyze Spheroid Cell Invasion In 3D Matrix](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Analyze-Spheroid-Cell-Invasion-In-3D-Matrix)

<img align='right' src="https://dev.mri.cnrs.fr/attachments/download/2021/cell_invasion.gif" height='100'/> The tool allows to measure the area of the invading spheroïd in a 3D cell invasion assay. It can also count and measure the area of the nuclei within the speroïd.  
####   [Analyse Spots Per Protoplast](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Analyse-Spots-Per-Protoplast)

<img  align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/82fa2ab8-1a5e-4f9f-921d-46615f15fec0" height='100'/> The tool counts the spots per protoplast. If a third channel is provided it is used to filter out detected protoplasts that do not have exactly one nucleus. 
####   [Arabidopsis Seedlings Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Arabidopsis-Seedlings-Tool)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/29fd2726-c46d-45ff-8309-3c0a131c0a8f" height='100'/> The Arabidopsis Seedlings Tool allows to measure the surface of green pixels per well in images containing multiple wells. It can be run in batch mode on a series of images. It writes a spreadsheet file with the measured area per well and saves a control image showing the green surface that has been detected per well. 
####   [Cluster Analysis of Nuclei Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Cluster-Analysis-of-Nuclei-Tool)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/6c5446cc-d436-4454-898d-bc268e4b5fe8" height='100'/> Analyze the clustering behavior of nuclei in DAPI stained images. The nuclei are detected as the maxima in the image. Using a threshold intensity value, maxima below the threshold are eliminated. The resulting points are clustered using the DBSCAN algorithm. The nearest neighbor distances between all nuclei, and those outside and inside of the clusters are calculated. 
####   [Cochlea Hair Cell Counting](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Cochlea-Hair-Cell-Counting)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/a820cda3-1e65-4fe2-a21c-6229a7ac5545" height='100'/> The aim of this tool is to count the hair cells in sections of 200µm from the apex of the cochlear to its base. The tool needs two types of input images: the 3d stack of the hair cells and a binary mask created from this stack by using the spot detection algorithm of Imaris (Bitplane). After the detection of the spots the background has been set to 0 and the volumes of the spots to 255 and the image has been exported as a tif-series. The tool allows to make the MIP-projections of the two kinds of input images in batch mode. 
####   [Count Axonal Projections Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Count-Axonal-Projections-Tool)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/cb5ae67b-52a0-4dcc-9402-7bc8e7162498" height='100'/> Count the number of axonal projections that cross a given line. The tool detects and counts the maxima along a line-selection, for example a segmented line. 
####   [Count Satellites Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Count_Satellites_Tool)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/71d7ca0e-36b5-425e-8d50-6c3754c5b6e1" height='100'/> The tool detects and counts the neurons and the neurons with satellite cells. 
####   [MRI_Count_Spot_Populations_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Count_Spot_Populations_Tool)   

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/51929842-b09b-4bc0-bc0e-585542a17bd1" height='100'/> The tool detects and and counts the spots (or blobs) in an image. It has been created for the counting of bacteria colonies in in Petri-dishes. It separates the spots into two populations and counts each population individually. The populations are separated by the area of the spots. The tool uses expectation maximisation clustering from the weka software. 
####   [MRI_Create_Synthetic_Spots_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Create_Synthetic_Spots_Tool)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/4159f06c-52da-4979-af22-d957d6303f63" height='100'/> The tool creates images of 2D-spots for the evaluation and benchmarking of spot detection tools. Two populations of spots with different means and variations of the size can be created in the same image. 
####   [MRI Dynamic Zones Analyzer](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Dynamic_Zones_Analyzer)

<img align='right' src="https://dev.mri.cnrs.fr/attachments/download/2640/active_zones.gif" height='100'/> Find and segment zones in which the intensity changes over time. Classify the zones into zones with increasing, decreasing, constant, u-shaped and n-shapes intensity profiles.  
####   [MRI_Fibrosis_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Fibrosis_Tool) 

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/020df5c3-4a25-49e6-9268-ffd12463bbaa" height='100'/> Measure the relative area of sirius red stained fibrosis. The tool uses the colour deconvolution plugin from Gabriel Landini. 
#### [Filament_Morphology_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Filament_Morphology_Tool)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/daacc38b-862d-4abe-ac8f-d11730f80e88" height='100'/> The tool count filaments and measure their areas and forms. It specially measures the geodesic diameter of the objects and its curvature, counts the branches and measures their lengths.
#### [Filament_Tools](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Filament_Tools)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/4d912e4c-c54f-4724-b9ca-631482d9930b" height='100'/> Calculate the area-fraction of the image filled with (septin) filaments.
####   [FLIM FRET_Volume_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/FLIM-FRET_Volume_Tool)

<img align='right' src="https://dev.mri.cnrs.fr/attachments/download/2200/Movie.gif" height='100'/> The tool measures in FLIM-FRET images, for each cell, the total volume of the cell and the volume occupied by values in a given range. It displays the positions of the values in the range in a result image. 
####   [Foci-Per-Nucleus-Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Foci-Per-Nucleus-Tool)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/73c0794b-c475-4512-8bed-0b396013022c" height='100'/> The tool detects, counts and measures the foci per nucleus. It reports the number of small, medium sized and big fosci per nucleus. It also measures the area and mean intensity of the nuclei. 
####   [MRI_g-ratio_Tools](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_g_ratio_Tools)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/b016b14c-e328-4067-8c38-f740445b4aa6" height='100'/> In images from transmission electron microscopy of the optic nerve, calculate the g-ratio of the axons. The pg-factor and the ag-factor will be measured. The pg-factor is the inner perimeter of the neuron divided by the outer perimeter including the myelin. The ag-factor is the square-root of the area of the inner surface divided by the area of the outer surface including the myelin. 
####   [Growth_Cone_Visualizer](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Growth_Cone_Visualizer)

<img align='right' src="https://user-images.githubusercontent.com/89924862/145095277-5ab225c5-a3dd-4973-8d2e-5d3286746294.png" height='100'/> The Growth Cone Visualizer Software is an imageJ-marco toolset that visualizes the morphological variability of neuronal growth cones. 
####   [MRI_Heights_of_Surfaces_Tools](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Heights_of_Surfaces_Tools)   

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/d89d394c-8c4f-4668-84dc-6a4419633205" height='100'/> The tools help to compare the height in the z-dimension of the signals in different channels. It calculates the heights normalized by the maximum height in a reference channel. Only places where the signal is not zero and the reference channel maximal are taken into account. 
####   [Intensity Per Nucleus Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Intensity-Per-Nucleus-Tool)   

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/44a435b6-da98-4cab-9275-b2ea32b27590" height='100'/> The tool segments the nuclei in the dapi or hoechst channel of the image and measures the mean intensity per nuclei in the other channels of the image. The macro can be applied recursively to all images in a folder and its subfolders. 
#### [Intensity Ratio Nuclei Cytoplasm Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Intensity-Ratio-Nuclei-Cytoplasm-Tool)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/7340d927-cc85-4b88-91d0-7b1eb6c92bfb" height='100'/> The tool calculates the ratio of the intensity in the nuclei and the cytoplasm. It needs two images as input: the cytoplasm channel and the nuclei channel. The nuclei channel is used to segment the nuclei. The measurements are made in the cytoplasm channel after the background intensity has been corrected. 
####   [Measure_Border_And_Spots_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Measure_Border_And_Spots_Tool)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/c8e40b77-8bb8-4ab0-ae66-9ce884528a83" height='100'/> The tool counts the number of spots (foci) per nucleus and measures the intensity, form, size and position of the spots. It also optionally measures the intensity in the membrane of the nucleus. 
####   [MRI Neurite Analyzer](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Neurite_Analyzer)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/d475988c-e939-4a3d-9fa9-1f213b2bf060" height='100'/> The toolset helps to segment neurites, measure the distances on the neurites to the closest soma, assign each neurite to a soma and to measure the FISH-signal on the neurites.
####   [Measure_Nuclei_And_Membranes](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Measure_Nuclei_And_Membranes_Tool)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/d7dcc245-8adc-45a5-8387-6488b2c5fbab" height='100'/> The tool measures the membranes and nuclei, of cells segmented with cellpose, in all channels but the nuclei-channel.
####   [Phase Contrast Cell Analysis Tool (Trainable WEKA Segmentation)](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Phase-Contrast-Cell-Analysis-Tool-%28Trainable-WEKA-Segmentation%29)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/9ce4400a-d5d2-4ecd-a3e7-692dc15dba43" height='100'/> The tool allows to segment cells in non fluorescent microscopy images using the trainable WEKA segmentation. It allows to run a preprocessing that crops and converts images, to apply a classifier created with the Trainable Weka Segmentation plugin to a folder containing images and to open the images in a folder as a stack in the "Trainable Weka Segmentation plugin" to create a classifier. 
####   [MRI_Plot_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Plot_Tool)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/3b53cb7a-c255-45a5-bb92-fa3800354cff" height='100'/> Calculate the first derivative of a plot and the zero-crossings of the derivate.
####   [Radial Movement Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Radial_Movement_Tool)

<img align='right' src="https://dev.mri.cnrs.fr/attachments/download/2562/simulated_faster.gif" height='100'/> The tool takes a results table of tracking data (as created by Trackmate) and calculates the difference of the distances between the start point of the track and a given point c and the end point of the track and c, i.e. how much the particle has moved away from c (negative if it moved towards c).
####   [MRI_Root_Hair_Tools](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Root_Hair_Tools)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/6ea28ca3-9094-46aa-9912-95fb3b007b03" height='100'/> The tool allows to measure the diameter of the root and the density of the root hair. 
####   [Skin_Tools](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Skin-Tools)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/bdfd60a1-de2d-4974-8831-a7561f694112" height='100'/> The Skin Tools allow to analyze masks of skin tissue that touch the right and left border of the image. The length of the lower border line is measured. For each extremum on the lower border line of the mask the length of a vertical line across the mask is measured. The advanced analysis allows to measure the interdigitation index and the filaggrin thickness. The filaggrin thickness is calculated using a number of random lines perpendicular to the border across the mask.  
####  [MRI_Spot_Coloc_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Spot_Coloc_Tool)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/756e2861-c8d8-48b5-a9ba-62cade8d1c5f" height='100'/> The tool counts the number of co-localized spots in two channels over time. It also exports the intensity of each spot over time.
#### [Spot_Distances_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Spot_Distances_Tool)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/9b930088-9047-4367-bfff-a9ef29194015" height='100'/> The tool detects spots and measures the nearest neighbour distances between the spots in the image.
#### [Synthetic_Tracking_Data_Generator](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Synthetic_Tracking_Data_Generator)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/19eaaff0-c6b3-43b9-837d-86916719f70c" height='100'/> The tool allows to simulate particles moving away from a center, moving towards a center or particles diffusing around a center.
####   [Track_Microtubules_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Track_Microtubules_Tool) 

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/f9023f28-0803-41b8-9886-584db240b93e" height='100'/> The tool allows to track the ends of fluorescently labelled microtubules, which are becoming shorter and to measure the speed of the movement of each end. It also creates kymograms and plots distance-per-time. 
####   [Transfection_Efficiency_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Transfection_Efficiency_Tool)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/97cf9547-193f-47ff-b630-422611e71b04" height='100'/> The tool helps to measure the transfection efficiency. It reports the percentage of transfected cells in the image. It has tools to manually correct the segmented nuclei (merge and split). 
####   [Width-Profile-Tools](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Width-Profile-Tools) 

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/08e49b93-b26b-4882-adc3-a3b1a2c71701" height='100'/> Tools to estimate the width-profile of an object given as a binary mask image. Calculate the width profile of the object as local thickness, as voronoi distance between two parts of the contour-line, perpendicular to the axis of inertia or at regular distances using rays perpendicular to a centerline segment.
####   [Witness based drift correction Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Witness_based_drift_correction_Tool) 

<img align='right' src="https://dev.mri.cnrs.fr/attachments/download/2550/CombinedStacks.gif" height='100'/> The tool corrects a constant drift in a time-series. When the objects in the images move, drift-correction can be difficult. Here a second channel is provided, in which there are no moving objects, however in order to be able to acquire images fast enough, for the second channel only the images of the first and the last frame are taken. 
####   [Wound Healing Coherency Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Wound-Healing-Coherency-Tool) 

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/c9c6cec9-4ecb-4801-b8eb-7b230bd3db06" height='100'/> The Wound Healing Coherency Tool can be used to analyze scratch assays. It measures the area of a wound in a cellular tissue on a stack of images representing a time-series. 

####   [Wound Healing Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Wound-Healing-Tool) 

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/ab37a6d6-c5ff-48b3-a03e-acf82ba1dd55" height='100'/> The MRI Wound Healing Tool can be used to analyze scratch assays. It measures the area of a wound in a cellular tissue on a stack of images representing a time-series. 

### Workflow and Conversion Toolsets

####   [MRI_Convert_Nikon_Andor_To_Hyperstack](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Convert_Nikon_Andor_To_Hyperstack) 

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/6e6d2c0d-a183-4a8e-a6d3-4f22466c7c56" height='20'/> Because of the big size of the images the microscope cuts images along the time dimension into multiple files each with a number of frames. This tool will for each position and wavelength convert the image. It will do a z-projection, concatenate all time-chunks and save the resulting image. The user has to provide the number of slices in the z-dimension. The pixel size and time interval can automatically be set when provided by the user. 
####   [MRI_Convert_Opera_To_Hyperstack](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Convert_Opera_To_Hyperstack) 

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/5ff52296-f5eb-4230-94ad-dfa652a3cc2f" height='20'/> The tool converts images taken with the Opera into hyperstacks. The image names are in the form ``r02c04f01p01-ch1sk1fk1fl1.tiff`` where r is the row, c the column, f the field, p the z-position and ch the channel. The tool converts all images in the input folder. 
####   [MRI_Image_Conversion_Tools](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Image_Conversion_Tools) 

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/7b714326-82ef-4584-956d-70b730140812" height='20'/>  The tools allow to convert .lei or .lif and .lsm files to tif-files. It works on a folder containing the input images. Results are written into a sub-folder `tif`. Each channel of a multi-channel file is saved separately. Besides this an rgb-snapshot of the image is saved. A z-projection can optionally be applied to the images.
####   [Load-Corresponding-Images](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Load-Corresponding-Images)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/8e6cda73-23c1-486b-9a3a-ebb7989a34d8" height='20'/> The tool allows to open for each image a second image with the same name from another folder. It displays the two images next to each other. It provides navigation through the list of images. 
####  [Copy_Random_Data_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Copy_Random_Data_Tool)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/2af9a357-210e-407d-bca7-f33de5406e2d" height='100'/>Randomly copy files from a number of input folders to create a test dataset. 
####  [MuVi SPIM_Convert_Tools](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MuVi-SPIM_Convert_Tools)

<img align='right' src="https://raw.githubusercontent.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/master/sylvain/Macros/MuVi_SPIM_Convert_MIP_Tools/wiki_images/1.montage.PNG" height='100'/> The Muvi-SPIM-Convert_Tools help to convert your hdF5 files comming from a MuVi-SPIM setup. 
####   [MRI_ND_To_Hyperstack](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_ND_To_Hyperstack)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/586b8153-9d45-4cfe-9ff0-3c2eea73c974" height='20'/> The tools converts images in the .nd format to ImageJ hyperstacks. The user selects an .nd file. An image can consist of multiple positions, frames, z-slices and channels. Each position is converted into an ImageJ hyperstack and written into a subfolder of the folder containing the input image. 
#### [NDPI export regions](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/NDPI_Export_Regions_Tool)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/7f57278c-f5b2-4ac4-b2b1-3172e0b84981" height='20'/>The tool exports rectangular regions, defined with the NDP.view 2 software from the highest resolution version of the image and saves them as tif-files.
####   [MRI_Opera_export_tools](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Opera_export_tools)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/b53ea89b-7f3f-4c85-810e-0880bdb711aa" height='20'/> The tool stitches images from the Opera Phenix HCS System. It reads the Index.idx.xml file to pre-arrange the images and then stitches and fuses them using the Grid/Collection stitching-plugin. Images are stitched by plane and channel. Z-stacks and multi-channel images can optionally be created. Projections can also be create.
 
### Single Plugin Tools

#### [Discrete_Histogram_Entropy_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Discrete_Histogram_Entropy_Tool)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/ca6f67f3-17f4-471d-b854-0f5c427a575f" height='50'/> The tool calculates the discrete histogram entropy H(X), where w is the width of the i-th histogram bin and f the frequency of the value xi. 

#### [Distance_Between_Minima_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Distance_Between_Minima_Tool)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/3a385362-8f52-4711-9e3f-d28c14c8548d" height='100'/> The tool measures the mean distance between the minima in the profile plot. 
#### [MRI_DoG_Filter](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_DoG_Filter)

<img align='right'  src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/a3bd19be-bc10-40e1-af8f-c1dfc0576f0f" height='100'/> The DoG-filter is a bandpass filter. It is calculated as: Gauss_s1(img) - Gauss_s2(img) where img is the input image, Gauss_s1 is a Gaussian-filter with sigma s1 and Gauss_s2 is a Gaussian-filter with sigma s2 (s2>s1). 
#### [Find_and_Subtract_Background_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Find_and_Subtract_Background_Tool)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/f0880444-8a62-47e5-92b5-e3d7159aa355" height='100'/> The tool finds the background intensity value and subtract it from the current image. It searches for the maximum intensity value around pixels that are below or equal to the minimum intensity in the image plus an offset. 
#### [MRI_Random_Selection_From_Table_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Random_Selection_From_Table_Tool)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/674e6a1f-987b-40f6-a030-9b7b3dca2aa3" height='100'/> The tool allows to create a sub-population of your data by randomly copying a configurable portion of lines from the active table to a new table. 
#### [Time_Reverse_Hyperstack_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Time_Reverse_Hyperstack_Tool)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/53c722b6-20b2-414c-a386-b0b03f1d0043" height='20'/> The tool reverses the order of the frames in a hyperstack. 

### Scripts
#### [MRI_Spiral_Mosaic_Tool](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Spiral_Mosaic_Tool)

<img align='right' src="https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/assets/7602420/6625d979-7a6d-4334-8a12-15e28a8844d2" height='100'/> The tool copies the images in a stack into a new image and places them in a spiral order, i.e. the first image is in the middle, the second right of the first, the third above the second, the fourth left of the third, and so on. 

### Macros
#### [Measure_Rois](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Measure_Rois)

<img align='right' src="https://user-images.githubusercontent.com/7602420/207379516-b6d80803-3fe4-45a9-ad89-f56ac1b41d3e.png" height='100'/> The macro calls the Measure Roi plugin for each selected ROI in the roi-manager or for all the ROIs in the roi-manager, if none are selected.  

# Segmentation et exploitation

## I. Procedure:

#### 1. Segmentation:

- Fix the voxels' dimensions.
- Split the segmentation channel from the data one. Applying segmentation operations to the data is useless and would result in a loss of accuracy and time.
- Apply a median filter to the global image to start reducing noise.
- Apply a Laplacian filter (from FeatureJ) with the "Detect zero crossings" option checked and a sigma of 1.0.
- Plot the resulting image along the z-axis, and export the values so the in-focus-detection Python script can use them. Once accomplished, we can discard the Laplacian image.
- Process the in-focus-range through the Python script (or a reimplementation is MacroJ)
- Process the Laplacian with the "zero crossings" unchecked and only keep the range returned by the script.
- Pass the result through LabKit to get an approximation of the segmentation. We will build seeds from the previously acquired result for the eventual watershed.
- LabKit returns images containing three labels. The black one corresponds to the background, the white one to what is considered a cell, and the gray highlights outlines. We apply a threshold to ditch both the background and the outlines. The only thing we want to keep is the cells.
- The outcome provides a reasonably reliable outlook of where the cells are. However, the result is still quite shabby and requires some refining.
- On each slice, independently of others, we will want to execute morphological operations to obtain an image giving at most one seed per cell.
	- Closing (Ball - 4, 4, 1)
	- 2D connected components -> Label size filtering [start ≤ label_size ≤ end]
	- Two erosions
	- Filling holes
- We must reassemble the slices into an image before continuing.
- Apply a threshold to one to remove all the connected components built during the slice-per-slice processing. By now, we should have a binary 3D image; we can launch a "Connected components labeling" that will, this time, operate in 3D.
- Take the original image, and apply a median filter, a Gaussian filter, and a threshold. Choose the values in a way that does not create holes in cells, even if it implies casting a wide net.
- Launch a "Marker Based Watershed" (from MorphoLibJ). The seeds are the first image on which we have worked. Both the input and the mask are the image we just created.
- We need a final erosion to avoid undesirable voxels knowing that the mask contains some background voxels and the watershed covers its entire surface systematically.

#### 2. Tracking:

- By now, we should have a serie of images (composed of slices) 

#### 3. Analysis:


__Notes:__
- Make internal threshold inside the detected label to remove excess of background?
- Maybe splitting the frames over time is purposeless; operators would not consider frames part of the same image as it does when we want to process something slice per slice.
- Try to train LabKit on a wider Laplacian to see if it will figure out something interesting despite the lack of context, the blurriness, and the massive loss of accuracy arising from σ≥3.0.

## II. Focus range detection:

By detecting the zero-crossings of a Laplacian, we can determine the in-focus range of slices for this particular image.  
A zero-crossing represents the border of an object, whether we get in or out of this object. We can determine which slices correspond to the in-focus area by plotting intensity values along the Z-axis.

> **Procedure:** LoG > Plot Z-axis > Export results > Python script

1. The LoG must be applied with the "Detect zero crossings" option checked. It will result in a binary image: *black*=uniform areas, *white*=zero crossing.
2. Plotting along this axis gives the average value for each slice. Knowing that we have a binary image, gives the average presence of zero-crossings. 
3. The problem is that it is not possible through a simple operator to export the values in a file for Python (the "save as" macro doesn't apply).
4. The Python script computes the derivative of the function represented by the previously acquired values, and locates the two maximums and the minimum *(when the derivative changes of sign)*.

On the graph right below, we can notice that the average intensity per slice always follow the same pattern: Two major peaks surround a very caracteristic valley.  
The valley area corresponds to the in-focus area. Then, we have to carefully chose the accepted range, knowing that the peak slices must be excluded.

![Plot along Z axis for 6 images](/home/benedetti/Bureau/procedure/focus_plots/montage-focus-plot.png)
**Green:** X-axis  
**Blue:** x = slice index **|** y = avg_intensity(x)  
**Orange:** Derivative of blue function

## III. Corrections de procédures:

- Abandonner le watershed qui donne des résultats minables et préférer faire l'intersection entre le threshold et les labels déterminés par le laplacien. Le résultat discutable du watershed donne cependant des frontières à peu près correctes. On pourrait utiliser ces frontières avec une intersection avec les masques convexes ou autre pour déterminer la véritable position de la cellule.
> **EDIT:** Le watershed donne un résultat qu'on peut exploiter en faisant une intersection avec un masque plus précis. Il faut aussi trouver un moyen de retirer les cellules sur-divisées.

- Une pré-segmentation via LabKit donne de bons résultats même s'il faut bien le nettoyer. L'image suivante est une slice du milieu de 

![LabKit output](/home/benedetti/Bureau/procedure/labkit-output.png)

- Retirer les couches hors-focus qui ne contiennent pas d'information.
  Que faire si les cellules bougent du plan de focus vers le hors-focus ? Doit-on les ditch au profit de la précision des mesures ?

- Peut-on détecter les cellules avec un Laplacien avant de virer tout ce qui c'est pas considéré comme une cellule ?
  En théorie on peut en jouant sur la taille des iles et sur leur convexité.
  -> Si l'enveloppe convexe est remplie à plus de N% par le label, on peut raisonablement considérer que nous sommes en présence d'une cellule.
  Ce traitement aurait lieu après toutes les phases d'épuration, pour enlever un maximum d'erreurs.

- Pour le tracking, essayer stardist. Les labels seront certainement déjà identifiés, on pourrait donc réimplémenter simplement l'algorithme de tracking par overlap.

- Étant donné que les scripts en Macro sont très sujets aux crashs, exporter les images une par une et les traiter au lieu de toutes les ouvrir en split. Voir également si le batch mode ne règlerait pas le problème des crashs.

- Est-il possible d'évaluer la rondeur d'une sélection ? En plaçant un centroid au même endroit et 

- Que pourrait produire une différence de Laplacien à différentes fréquences ?
  La Laplacien à 4.8 produit une map qui pourrait être intéressante à l'utilisation avec le watershed (elle ne présente pas de trou dans les cellules)

- Plutôt que prendre un nombre slices à droite et à gauche du minimum sur la courbe de focus, on peut simplement utiliser un "pourcentage de remontée" qui analyse le moment où on atteint un certain pourcentage entre le minimum et le plus haut des deux maximums. On aurait donc potentiellement quelque chose d'assymétrique, mais ce n'est pas un problème tant que la donnée contenue dans la range est exploitable.

![Relevés pixels/cellule/slice](/home/benedetti/Bureau/procedure/box-plot.png)

0. Clear toutes les sélections pour qu'elles ne foutent pas la merde pendant le process.
1. Partir de l'image de base.
2. Appliquer 2 filtres médians pour éliminer le bruit.
3. Appliquer un premier Laplacian à 1.0 pour isoler les objets de façon précise. Ce Laplacien doit évidemment être appliqué avant de ditch les frames jugées comme étant hors focus.
4. Appliquer un second Laplacian à 4.8 pour isoler les zones globales. Ce Laplacian doit être également thresholded (à ???).
5. Calculer l'intersection de ces 2 Laplacians pour former la nouvelle base de travail.
   L'image produite doit être split et exporté en slice par slice. Toutes les slices sont fermées et réouvertes au besoin.
6. Sur chaque slice, isoler les connected components et faire un premier filtrage par taille.
   Sur les labels restant, tracer la convex hull (opérateur convexify de MorpholibJ).
   Faire un threshold sur les images obtenues et une différence. Récupérer l'histogramme.
   On aimerait pouvoir batcher ces opérations, mais à voir comment les plugins s'en sortent.
   On peut se servir de l'enveloppe convexe pour rapatrier les morceaux de cellules séparés. Faire l'intersection entre l'image originale et notre label actuel. Si l'intersection est plus grande, on veut merge les labels qui ont été inclus.
   Le filtrage par taille devrait plutôt être réalisé sur les enveloppes convexes qui seront plus grandes sans les trous.
N. Retirer les îles connectées isolées (sélection par taille après aggrégation 3D).


# TO DO:

- [ ] Déterminer une méthode solide pour déterminer la in-focus-range depuis le graphe.
- [ ] Contacter Thomas Sabaté pour proposition de modification de procédure.
- [ ] Réimplémenter la dichotomie en langage macro.
- [ ] Analyser le plugin k-mean pour un exemple d'implémentation macroJ.
- [ ] Apprendre la façon dont faire un toolset. (utiliser les toolsets mis à disposition dans le GitHub)
- [ ] Terminer l'implémentation du HTML pour rendre des pages de knowledge-base propres.
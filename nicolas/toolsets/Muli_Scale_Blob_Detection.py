#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 14 16:21:07 2022

@author: nnafati
"""

from math import sqrt
from skimage import data
from skimage.feature import blob_dog, blob_log, blob_doh
from skimage.color import rgb2gray
import matplotlib.pyplot as plt
from skimage import feature, exposure
import cv2
import numpy as np
import skimage.io as io
import imutils
import gc

gc.collect()
cv2.destroyAllWindows()

image=[]
image = cv2.imread('/home/nnafati/Desktop/Data/images_tiff/spots.tif')
# image = cv2.imread('/home/nnafati/Desktop/Data/images_tiff/pyramide.png')
fichier = open("Result_File.txt", "w")
# image = exposure.equalize_hist(image)

image_gray = rgb2gray(image)

z_slice = range(5,30,5)
x_size = 500
y_size = 500

# distance = np.zeros((z_slice,x_size,y_size))
i=0
array_blobs = []
array_scale =  []
for max_sigma in range(5,30,5):
# for max_sigma in z_slice:
    array_scale = array_scale + [max_sigma]
    print('array_scale',array_scale)
    print(array_scale)
    
    i=i+1
    print("max_sigma")
    print(max_sigma)

    blobs_log = blob_log(image_gray, max_sigma=max_sigma,min_sigma=max_sigma, num_sigma=10, overlap = 0.1, threshold=.1)
   
    # Compute radii in the 3rd column.
    blobs_log[:, 2] = blobs_log[:, 2] * sqrt(2)
    
    array_blobs = array_blobs + [blobs_log]

    blobs_dog = blob_dog(image_gray, max_sigma=max_sigma, min_sigma=1,overlap=0.1, threshold=.1)
    blobs_dog[:, 2] = blobs_dog[:, 2] * sqrt(2)

    blobs_doh = blob_doh(image_gray, max_sigma=max_sigma, min_sigma=1,overlap=0.1,threshold=.01)

    blobs_list = [blobs_log, blobs_dog, blobs_doh]
    colors = ['yellow', 'lime', 'red']
    titles = ['LoG+sigma='+str(max_sigma), 'Difference of Gaussian',
              'Determinant of Hessian']
    
    sequence = zip(blobs_list, colors, titles)

    fig, axes = plt.subplots(1, 3, figsize=(9, 3), sharex=True, sharey=True)
    ax = axes.ravel()

    fichier.write("Scale=")
    fichier.write(str(max_sigma))
    fichier.write("\n")    # print('sequence', enumerate(sequence))

    for idx, (blobs, color, title) in enumerate(sequence):
        ax[idx].set_title(title)
        ax[idx].imshow(image)
        for blob in blobs:
            y, x, r = blob
            fichier.write(str(y))
            fichier.write(" ")
            fichier.write(str(x))
            fichier.write(" ")
            fichier.write(str(r))
            fichier.write("\n")
        
            c = plt.Circle((x, y), r, color=color, linewidth=2, fill=False)
            ax[idx].add_patch(c)
            ax[idx].set_axis_off()

    plt.tight_layout()
    plt.show()
fichier.close()

#isWritten = cv2.imwrite('/home/nnafati/Desktop/Data/images_tiff/found_spots_in_image_file.tif',array_blobs)
# if isWritten:
#	print('Image is successfully saved as file.')



 
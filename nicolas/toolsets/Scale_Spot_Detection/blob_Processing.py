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

import matplotlib as mpl

# from skimage import feature, exposure
import cv2
import numpy as np
import skimage.io as io
import imutils
import string
import gc
import pyqtgraph as pg

mpl.use('QtAgg') # <-- THIS MAKES IT FAST!





# ij = imagej.init('~/Desktop/soft/fiji-linux64/Fiji.app')

#  j.getVersion()
# ij.ui().showUI()

 # 
# def read_Text_file_to_matrix(file_name):
#     fichier = open(file_name, "r+")
#     blob_coord = fichier.read("Scale=")
#     fichier.read(str(max_sigma))
#   fichier.read("\n")

# empty memory forced
gc.collect()

file_name = '/home/nnafati/Desktop/Data/images_tiff/found_spots_in_image_file.tif'
# fichier = open(file_name, "r+")
# blob_coord_file = read_Text_file_to_matrix(file_name)



image=[]

# coord_blob_array = cv2.imread('/home/nnafati/Desktop/Data/images_tiff/found_spots_in_image_file.tif')

image = cv2.imread('/home/nnafati/Desktop/Data/images_tiff/spots.tif')

fichier = open("Result_File.txt", "w")

# image = cv2.imread('/home/nnafati/Desktop/Data/images_tiff/pyramide.png')

image_gray = rgb2gray(image)
z_slice = range(15,50,5)
x_size = 500
y_size = 500

# distance = np.zeros((z_slice,x_size,y_size))
i=0
array_blobs = []
array_scale =  []

for max_sigma in range(5,20,5):
# for max_sigma in z_slice:
    
    array_scale = array_scale + [max_sigma]
    print('array_scale',array_scale)
    print(array_scale)
    
    i=i+1
    print("max_sigma ")
    print(max_sigma)

    # blob_log(image, max_sigma, min_sigma, num_sigma, overlap, threshold) 
    blobs_log = blob_log(image_gray, max_sigma=max_sigma,min_sigma=max_sigma, num_sigma=10, overlap = 0.1, threshold=.1)
    # av blobs_log = blob_log(image_gray, max_sigma=15,num_sigma=10, threshold=.1)

    blobs_log[:, 2] = blobs_log[:, 2] * sqrt(2)
    
    array_blobs = array_blobs + [blobs_log]

    # print('blob_log(3,2)', blobs_log[1,1])  

    #nb_lignes,nb_colonnes = array_blobs.shape
    # print('hh',nb_lignes)
    # print('ww',nb_colonnes)
    # t = [['a' for j in range(colonnes)]for i in range(lignes)]

    # print('blob_log(1,1)', blobs_log[1,1])  
    # print('blob_log(0:2,0:3)', blobs_log[0:2,0:3])  
    # input('enter a number')

    # Compute radii in the 3rd column.
    
    ## av blobs_log[:, 2] = blobs_log[:, 2] * sqrt(2)

    # blobs_dog = blob_dog(image_gray, max_sigma=15, threshold=.1)
    # av blobs_dog = blob_dog(image_gray, max_sigma=15, min_sigma=1,overlap=0.1, threshold=.1)
    blobs_dog = blob_dog(image_gray, max_sigma=max_sigma, min_sigma=1,overlap=0.1, threshold=.1)
    blobs_dog[:, 2] = blobs_dog[:, 2] * sqrt(2)

    # blobs_doh = blob_doh(image_gray, max_sigma=15, threshold=.01)
    # av blobs_doh = blob_doh(image_gray, max_sigma=15, threshold=.01)
    # av blobs_doh = blob_doh(image_gray, max_sigma=15, min_sigma=1,overlap=0.1,threshold=.01)
    blobs_doh = blob_doh(image_gray, max_sigma=max_sigma, min_sigma=1,overlap=0.1,threshold=.01)

    blobs_list = [blobs_log, blobs_dog, blobs_doh]
    colors = ['yellow', 'lime', 'red','blue','yellow','green']
    titles = ['LoG+sigma='+str(max_sigma), 'Difference of Gaussian',
              'Determinant of Hessian']
    sequence = zip(blobs_list, colors, titles)

    # av fig, axes = plt.subplots(1, 3, figsize=(9, 3), sharex=True, sharey=True)
    # av ax = axes.ravel()

    fichier.write("Scale=")
    fichier.write(str(max_sigma))
    fichier.write("\n")
    # print('sequence', enumerate(sequence))

    for idx, (blobs, color, title) in enumerate(sequence):
        # av ax[idx].set_title(title)
        # av ax[idx].imshow(image)
        for blob in blobs:
            y, x, r = blob
        
            fichier.write(str(y))
            fichier.write(" ")
            fichier.write(str(x))
            fichier.write(" ")
            fichier.write(str(r))
            fichier.write("\n")
        

            # av c = plt.Circle((x, y), r, color=color, linewidth=2, fill=False)
            # av ax[idx].add_patch(c)
            # av ax[idx].set_axis_off()

    # av plt.tight_layout()
    # av plt.show()
fichier.close()

del blobs_log
del blobs_dog
del blobs_doh
del sequence
gc.collect()
cv2.destroyAllWindows()

fig, axes_1 = plt.subplots(1, 2, figsize=(9, 3), sharex=True, sharey=True)
ax = axes_1.ravel()

print("len(array_scale",len(array_scale))
print("len(array_blobs",len(array_blobs))
# cv2.waitKey(0) 
i=0
for scale_index in range(len(array_scale)):
    
    i=i+1
    if ((i>=1) & (i<=6)): 
        color = colors[i-1]
        print('color',color)
        
    for blob_index in range(len(array_blobs[scale_index])):
            
        len_blob_x = len(array_blobs[scale_index])
        # print("len(array_blobs[scale_index]) = ",len_blob_x)
            
        idx=0
        ax[idx].set_title('Results_Multi_Scale_Spots_Detection_Color_Around')
        ax[idx].imshow(image)
            
        if (scale_index>=1):
            # print("blob_index",blob_index)
            y_end,x_end,r_end = array_blobs[scale_index][blob_index]
            y,x,r = array_blobs[scale_index-1][blob_index]
           
        else:
            # print('blob_index[i]',blob_index)
            y_end,x_end,r_end =[0,0,0]
            y,x,r = array_blobs[scale_index][blob_index]
            
        # print('x',x,'y',y,'rayon',r)
        delta_x = abs(x-x_end)
        delta_y = abs(y-y_end)
        delta_r = abs(r-r_end)
        distance = sqrt(delta_x**2+delta_y**2)
        r_total = r_end + r
            
        if (r_total > distance):
            c0 = plt.Circle((x, y), r, color=color, linewidth=1, fill=False)
            ax[idx].add_patch(c0)
            c1 = plt.Circle((x_end, y_end), r_end, color=color, linewidth=1, fill=False)
            ax[idx].add_patch(c1)
            ax[0].set_axis_off()
            ax[1].set_axis_off()
            # print('chauivechement')
            continue
            
        elif (r_total<=distance):
            c0 = plt.Circle((x, y), r, color=color, linewidth=2, fill=False)
            ax[idx].add_patch(c0)
            c1 = plt.Circle((x_end, y_end), r_end, color=color, linewidth=1, fill=False)
            ax[idx].add_patch(c1)
            ax[0].set_axis_off()
            ax[1].set_axis_off()
            
            # plt.tight_layout()
            # plt.show()
            # print('blob is around') 
            continue
        
        else:
            # print('blob is not around')
            continue
        
        print('image',image)
        # pg.image(image)
  
        plt.tight_layout()
        plt.show()
    
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jan 25 09:42:22 2022

@author: nnafati
"""
import numpy as np
import cv2
import matplotlib.pyplot as plt

from skimage import data
from skimage.transform import pyramid_gaussian
from skimage import data
import imageio as io

from math import sqrt
from skimage import data
from skimage.feature import blob_dog, blob_log, blob_doh
from skimage.color import rgb2gray
import matplotlib.pyplot as plt
from skimage import feature, exposure
import cv2
import numpy as np
import skimage.io as io

image = cv2.imread('/home/nnafati/Desktop/Data/images_tiff/spots.tif')

rows, cols, dim = image.shape

image_gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

pyramid = tuple(pyramid_gaussian(image, downscale=2, channel_axis=-1))
 
composite_image = np.zeros((rows, cols + cols // 2, 3), dtype=np.double)

# composite_image[:rows, :cols, :3] = pyramid[0]
composite_image[:rows, :cols,:3] = pyramid[0]

i_row = 0
for p in pyramid[1:]:
    n_rows, n_cols = p.shape[:2]
    print('image composite n_row col+col/2',composite_image[i_row:i_row + n_rows, cols:cols + n_cols].shape)
    print('p shape',p.shape)     
    
    if(composite_image[i_row:i_row + n_rows, cols:cols + n_cols].shape==p.shape):
        composite_image[i_row:i_row + n_rows, cols:cols + n_cols] = p
        i_row += n_rows
    else:
        break
    
    fig, ax = plt.subplots()
    ax.imshow(composite_image)
    plt.show()
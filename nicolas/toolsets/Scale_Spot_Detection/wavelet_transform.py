#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 14 15:02:49 2022

@author: nnafati
"""

import pywt
import numpy as np
import cv2

def image_normalization(src_img):
    """
Processus de normalisation pour éviter la surexposition
    cv2.Requis lors de l'affichage d'images converties en ondelettes avec imshow (uniquement pour les images avec de grandes valeurs)
    """
    norm_img = (src_img - np.min(src_img)) / (np.max(src_img) - np.min(src_img))
    return norm_img

def merge_images(cA, cH_V_D):
    """numpy.4 tableaux(en haut à gauche,(En haut à droite, en bas à gauche, en bas à droite))Relier"""
    cH, cV, cD = cH_V_D
    cH = image_normalization(cH) #Même si vous le supprimez, c'est ok
    cV = image_normalization(cV) #Même si vous le supprimez, c'est ok
    cD = image_normalization(cD) #Même si vous le supprimez, c'est ok
    cA = cA[0:cH.shape[0], 0:cV.shape[1]] #Si l'image originale n'est pas une puissance de 2, il peut y avoir des fractions, donc ajustez la taille. Faites correspondre le plus petit.
    return np.vstack((np.hstack((cA,cH)), np.hstack((cV, cD)))) #Joindre des pixels en haut à gauche, en haut à droite, en bas à gauche, en bas à droite

def coeffs_visualization(cof):
    norm_cof0 = cof[0]
    norm_cof0 = image_normalization(norm_cof0) #Même si vous le supprimez, c'est ok
    merge = norm_cof0
    for i in range(1, len(cof)):
        merge = merge_images(merge, cof[i])  #Faites correspondre les quatre images
    cv2.imshow('', merge)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

def wavelet_transform_for_image(src_image, level, M_WAVELET="db1", mode="sym"):
    data = src_image.astype(np.float64)
    coeffs = pywt.wavedec2(data, M_WAVELET, level=level, mode=mode)
    return coeffs

if __name__ == "__main__":

    # filename = 'lena.jpg'
    filename = '/home/nnafati/Desktop/Data/images_tiff/spots.tif'
    LEVEL = 3

    # 'haar', 'db', 'sym' etc...
    # URL: http://pywavelets.readthedocs.io/en/latest/ref/wavelets.html
    MOTHER_WAVELET = "db1"

    im = cv2.imread(filename)

    print('LEVEL :', LEVEL)
    print('MOTHER_WAVELET', MOTHER_WAVELET)
    print('original image size: ', im.shape)

    """
Convertir pour chaque canal BGR
    cv2.imread est B,G,Notez que les images sont crachées dans l'ordre de R
    """
    B = 0
    G = 1
    R = 2
    coeffs_B = wavelet_transform_for_image(im[:, :, B], LEVEL, M_WAVELET=MOTHER_WAVELET)
    coeffs_G = wavelet_transform_for_image(im[:, :, G], LEVEL, M_WAVELET=MOTHER_WAVELET)
    coeffs_R = wavelet_transform_for_image(im[:, :, R], LEVEL, M_WAVELET=MOTHER_WAVELET)

    coeffs_visualization(coeffs_B)
    # coeffs_visualization(coeffs_G)
    # coeffs_visualization(coeffs_R)
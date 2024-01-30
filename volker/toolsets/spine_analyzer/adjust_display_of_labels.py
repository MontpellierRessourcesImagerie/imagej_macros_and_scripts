###############################################################################################
##
## adjust_display_of_labels.py
##
## Adjust the display of the labels in the label channel of a segmentation to 
## maximum label.
##
## (c) 2024 INSERM
##
## written by Volker Baecker at the MRI-Center for Image Analysis (MRI-CIA - https://www.mri.cnrs.fr/en/data-analysis.html)
##
## adjust_display_of_labels.py is free software under the MIT license.
## 
## MIT License
##
## Copyright (c) 2024 INSERM
##
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included in all
## copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.
## 
################################################################################################

from ij import IJ
from fr.cnrs.mri.cialib.segmentation import InstanceSegmentation


def main():
    image = IJ.getImage()
    segmentation = InstanceSegmentation(image)
    segmentation.adjustDisplayOfLabels()
    

main()
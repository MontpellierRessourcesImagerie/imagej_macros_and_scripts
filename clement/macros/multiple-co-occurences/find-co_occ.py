"""
This macro expects a folder containing masks in the TIFF format.
It will produce all possible combinations and process the intersections to count co-occurrences.
The co-occurences are not exclusive.
For example, if a co-occurence is detected in c1-c2, it is also counted in c1-c2-c3 if the previously found one matches with c3.
A simple subtraction can restore the exclusivity.
"""

_TABLE_NAME = "# co-occurences"
_INPUT_FOLDER = "/home/benedetti/Documents/projects/coralie-co-occurance/transfer_8066882_files_8c192037/output/"

from ij import IJ
from ij.plugin import ImageCalculator
from ij.measure import ResultsTable

from inra.ijpb.label.conncomp import FloodFillRegionComponentsLabeling3D
from inra.ijpb.label import LabelImages

import os


def generate_combinations(elements):
    result = []
    def combine(current, remaining):
        if current:
            result.append(tuple(current))
        for i in range(len(remaining)):
            combine(current + [remaining[i]], remaining[i+1:])
    combine([], elements)
    result.sort(key=len)
    return result


def open_img(n):
    full_path = os.path.join(_INPUT_FOLDER, n)
    return IJ.openImage(full_path)
    
    
def intersection(n_im1, n_im2):
    im1 = open_img(n_im1)
    im2 = open_img(n_im2)
    im3 = ImageCalculator.run(im1, im2, "and stack create")
    im1.close()
    im2.close()
    n1 = os.path.splitext(n_im1)[0]
    n2 = os.path.splitext(n_im2)[0]
    n3 = n1 + "-" + n2 + ".tif"
    export_path = os.path.join(_INPUT_FOLDER, n3)
    IJ.save(im3, export_path)
    im3.close()
    return n3
    

def make_intersections(combination, pool):
    if len(combination) == 1:
        return open_img(combination[0])
    basis = combination[0]
    for img in combination[1:]:
        basis = intersection(basis, img)
    return basis
    
    
def check_names(names):
	for n in names:
		if "-" in n:
			return False
	return True


def n_components(n_img):
    img = open_img(n_img)
    ffrcl = FloodFillRegionComponentsLabeling3D(26, 16)
    labeled_stack = ffrcl.computeLabels(img.getStack(), 255)
    labels_list = [l for l in LabelImages.findAllLabels(labeled_stack) if l > 0]
    img.close()
    del(labeled_stack)
    return len(labels_list)

        
def measure(combinations):
    rt = ResultsTable.getResultsTable(_TABLE_NAME) or ResultsTable()
    line = rt.size()
    rt.addRow()
    rt.setValue("source", line, os.path.basename(_INPUT_FOLDER).replace("-masks", ""))
    for c in combinations:
        name = "-".join([os.path.splitext(f)[0] for f in c])
        target_name = name + ".tif"
        rt.setValue(name, line, n_components(target_name))
    rt.show(_TABLE_NAME)


def launcher():
    IJ.run("Close All")
    file_names = sorted(os.listdir(_INPUT_FOLDER))
    if not check_names(file_names):
    	IJ.log("File names should not contain '-'")
    	return False
    combinations = generate_combinations(file_names)
    for c in combinations:
        make_intersections(c, file_names)
    measure(combinations)


def main():
    global _INPUT_FOLDER
    save_input_folder = _INPUT_FOLDER
    all_dirs = os.listdir(save_input_folder)
    for d in all_dirs:
        if d.startswith("_"):
    	    continue
        full_path = os.path.join(save_input_folder, d)
    	if not os.path.isdir(full_path):
    		continue
    	IJ.log("Processing: " + d)
    	_INPUT_FOLDER = full_path
    	launcher()


main()
IJ.log("DONE.")
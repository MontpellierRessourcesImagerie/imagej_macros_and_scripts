_MIP_DIRECTORY = "/home/benedetti/Documents/projects/coralie-co-occurance/transfer_8066882_files_8c192037/mip/"

import os

from ij.measure import ResultsTable
from ij import IJ

def get_global_max(img):
	n = img.getNSlices()
	maxi = img.getProcessor().getMax()
	for i in range(1, n+1):
		img.setSlice(i)
		m = img.getProcessor().getMax()
		if m > maxi:
			maxi = m
	return int(maxi)

def add_to_table(vals):
	print(vals)
	rt = ResultsTable.getResultsTable("# co-occurences") or ResultsTable()
	for i in range(rt.size()):
		src = rt.getStringValue("source", i)
		if src in vals:
			rt.setValue("# nuclei", i, vals[src])
	rt.show("# co-occurences")
			

def main():
	content = os.listdir(_MIP_DIRECTORY)
	content = [c for c in content if c.startswith("labeled-") and c.endswith(".tif")]
	vals = {}
	for c in content:
		full_path = os.path.join(_MIP_DIRECTORY, c)
		img = IJ.openImage(full_path)
		n_nuclei = get_global_max(img)
		tag = c.replace("labeled-", "").replace(".tif", "")
		vals[tag] = n_nuclei
		img.close()
	add_to_table(vals)
		
		
main()
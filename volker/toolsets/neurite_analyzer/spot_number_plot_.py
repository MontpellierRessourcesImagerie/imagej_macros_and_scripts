from ij.plugin.filter import MaximumFinder
from ij import IJ
from ij.measure import ResultsTable

ip = IJ.getImage()
imp = ip.getProcessor()
finder = MaximumFinder()
table = ResultsTable.getResultsTable()

minima = finder.getMaxima(imp, 0, True, True)
intensities = [0] * (minima.npoints)

z = list(zip(minima.xpoints, minima.ypoints))

for c in range(0, minima.npoints):
    intensities[c] = ip.getPixel(z[c][0], z[c][1])[0]
    
intensities.sort()

print("sorted")


total = len(intensities)

i = 0
for t in range(0, 65536):
    while i<total and intensities[i] <= t:
        i = i + 1
    table.addRow()
    table.addValue("t", t)
    table.addValue("count", total-i)
    
table.show("Results")

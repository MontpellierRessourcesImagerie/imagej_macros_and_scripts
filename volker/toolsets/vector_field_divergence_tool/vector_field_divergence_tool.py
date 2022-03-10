from ij.measure import ResultsTable
from ij.gui import Plot
from ij.util import Tools
from ij import IJ
from ij.gui import Roi
import math 

def main():
    image = IJ.getImage();
    roi = image.getRoi()
    if not roi:
        center = image.getWidth() / 2, image.getHeight() / 2
    else:
        center = roi.getXBase(), roi.getYBase();
    tableName = "Tracks"
    table = ResultsTable.getResultsTable(tableName)
    vectors = getVectorsFromTable(table, center)
    divergence = calculateDivergencePerTime(vectors)
    stats = Tools.getStatistics(divergence)
    rt = ResultsTable.getResultsTable ("Divergence")
    if not rt:
        rt = ResultsTable()
    row = rt.getCounter()
    rt.setValue("label", row, tableName)
    rt.setValue("x", row, center[0])
    rt.setValue("y", row, center[1])
    rt.setValue("mean", row, stats.mean)
    rt.setValue("stdDev", row, stats.stdDev)
    rt.setValue("min", row, stats.min)
    rt.setValue("median", row, stats.median)
    rt.setValue("max", row, stats.max)
    rt.show("Divergence")

def plot(data, center):
    T = list(range(0, len(data)))
    plot = Plot("divergence in (" + str(center[0]) + ", "+ str(center[1])+")", "time[1]", "divergence", T, data)
    plot.show()
    
def calculateDivergencePerTime(vectors):
    divergences = []
    for row in vectors:
        newRow = []
        for vector in row:
            newRow.append(proj(vector[1], vector[0]))
        divergences.append(sum(newRow)/len(newRow))
    return divergences

def proj(a, b):
    f = dot(a, b) / dot(b, b)
    projAonB = [bi*f for bi in b]
    sign = -1
    if math.copysign(1, b[0]) == math.copysign(1, projAonB[0]):
        sign = 1
    scalarProj = sign * math.sqrt(projAonB[0]**2 + projAonB[1]**2)
    return scalarProj
    
def dot(a, b):
    return sum(x*y for x, y in zip(a, b))
    
def getVectorsFromTable(table, center):
    vectors = []
    headings = list(table.getHeadings())
    tColumn, pIDColumn, xColumn, yColumn = table.getColumn(headings.index('T')),  \
                                           table.getColumn(headings.index('ID')), \
                                           table.getColumn(headings.index('X')), \
                                           table.getColumn(headings.index('Y'))
    T = {}
    for t, pID, x, y in zip(tColumn, pIDColumn, xColumn, yColumn):
        T[t] = {pID : (x, y)}
    for t in range(0, len(T.keys())-2):
        row = []
        for pid in T[t].keys():
            x1 = T[t][pid][0] - center[0]
            y1 = T[t][pid][1] - center[1]
            x2 = T[t+1][pid][0] - center[0]
            y2 = T[t+1][pid][1] - center[1]
            dx = x2 - x1
            dy = y2 - y1
            row.append(((x1, y1), (dx, dy)))
        vectors.append(row)       
    return vectors
    
main()
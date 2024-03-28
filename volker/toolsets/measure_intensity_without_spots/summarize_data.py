import math
from ij.measure import ResultsTable
from itertools import groupby
import operator


def main():
    table = ResultsTable.getActiveTable()    
    images = table.getColumnAsStrings("Image")
    baseImages = [image.split(" Field")[0] for image in images]
    wells = table.getColumnAsStrings("Well")
    fields = table.getColumn("Field")
    means = table.getColumn("Mean")
    stdDevs = table.getColumn("StdDev")
    folders = table.getColumnAsStrings("folder")
    
    data = zip(images, baseImages, wells, fields, means, stdDevs, folders)
    data = sorted(data, key=operator.itemgetter(0))
    
    dataByFieldTable = ResultsTable()
    dataByFieldTable.showRowNumbers(True)
   
    for k, g in groupby(data, operator.itemgetter(0)):
        values = list(g)
        mean = sum(map(lambda x: x[4], values)) / len(values)
        stdDev = math.sqrt(sum(map(lambda x: x[5]*x[5], values)) / len(values))
        dataByFieldTable.addRow()
        dataByFieldTable.addValue("Image", values[0][0])
        dataByFieldTable.addValue("Well", values[0][2])
        dataByFieldTable.addValue("Field", values[0][3])    
        dataByFieldTable.addValue("Mean", mean)    
        dataByFieldTable.addValue("StDev", stdDev) 
        dataByFieldTable.addValue("Folder", values[0][6]) 
    dataByFieldTable.show("Intensity by Field")
    
    dataByWellTable = ResultsTable()
    dataByWellTable.showRowNumbers(True)
    for k, g in groupby(data, operator.itemgetter(1)):
        values = list(g)
        mean = sum(map(lambda x: x[4], values)) / len(values)
        stdDev = math.sqrt(sum(map(lambda x: x[5]*x[5], values)) / len(values))
        dataByWellTable.addRow()
        dataByWellTable.addValue("Image", values[0][1])
        dataByWellTable.addValue("Well", values[0][2])
        dataByWellTable.addValue("Mean", mean)    
        dataByWellTable.addValue("StDev", stdDev) 
        dataByWellTable.addValue("Folder", values[0][6]) 
    dataByWellTable.show("Intensity by Well")
    
    
main()
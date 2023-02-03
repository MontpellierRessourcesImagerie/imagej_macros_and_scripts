from __future__ import division
import math
from org.apache.commons.math3.stat.correlation import PearsonsCorrelation
from  ij.gui import Plot
from ij.measure import ResultsTable

TABLE = "Plot Values"
COLUMN_2 = "Mean"
COLUMN_1 = "Y2"
MAX_LAG = 23
FRAME_INTERVAL = 60.05
TIME_UNIT = "sec"
SHOW_PLOT = True
TITLE = "image"

def main():
    table = ResultsTable.getResultsTable(TABLE)
    series1 = table.getColumn(COLUMN_1)
    series2 = table.getColumn(COLUMN_2)
    maxLag = MAX_LAG
    correlationByLag = xCorrelate(series1, series2, maxLag)
    X = [lag * FRAME_INTERVAL for lag in range(-maxLag, maxLag+1)]
    if SHOW_PLOT:
        plot = Plot("cross-correlation", "lag [sec]", "cc")
        plot.add("separated bar", X, correlationByLag)
        plot.setStyle(0,"black,black,1")    
        plot.show()
    maxCorrelation = max(correlationByLag)
    maxIndex = correlationByLag.index(maxCorrelation)
    maxLag = X[maxIndex]
    minCorrelation = min(correlationByLag)
    minIndex = correlationByLag.index(minCorrelation)
    minLag = X[minIndex]
    report(TITLE, minCorrelation, minLag, maxCorrelation, maxLag)
    
def report(imageTitle, minCorrelation, lagOfMinCorrelation, maxCorrelation, lagOfMaxCorrelation):
    title = "cross-correlation results"
    table = ResultsTable.getResultsTable(title)
    tableIsOpen = False
    if table:
        tableIsOpen = True
    if not tableIsOpen:
        table = ResultsTable()
    table.incrementCounter()
    table.addValue("image", imageTitle)
    table.addValue("min.", minCorrelation)
    table.addValue("lag of min.", lagOfMinCorrelation)
    table.addValue("max.", maxCorrelation)
    table.addValue("lag of max.", lagOfMaxCorrelation)
    
    table.show(title)
    table.updateResults()
    
    
       
def xCorrelate(a, b, maxLag):
        correlator = PearsonsCorrelation()
        lags = range(-maxLag, maxLag+1)
        xCorr = [0] * len(lags)
        index = 0
        for lag in lags:
            if lag < 0:
                data = a[0:lag]
                window = b[-lag:]
            if lag == 0:
                data = a
                window = b
            if lag > 0:
                data = a[lag:]
                window = b[0:-lag]
            value = correlator.correlation(data, window)
            if math.isnan(value):
                value = 0
            xCorr[index] = value
            index = index + 1
        return xCorr

main()

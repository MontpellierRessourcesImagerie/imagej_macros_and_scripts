from __future__ import division
import math
from org.apache.commons.math3.stat.correlation import PearsonsCorrelation
from  ij.gui import Plot
from ij.gui import GenericDialog
from ij.measure import ResultsTable
from ij import IJ


def main():
    correlograph = CrossCorrelograph()
    correlograph.getView().title = IJ.getImage().getTitle();
    if not correlograph.getView().showDialog():
        return
    correlograph.calculateCrossCorrelation()
    if correlograph.getView().shallShowPlot:
        correlograph.getView().showPlot()
    correlograph.getView().report()
    
    
class CrossCorrelographView:


    def __init__(self, model):
        self.model = model
        self.shallShowPlot = True
        self.title = "image"
        self.table = "Plot Values"
        self.dependentSeriesColumn = "Y2"
        self.independentSeriesColumn = "Mean" 
        
        
    def report(self):
        title = "cross-correlation results"
        table = ResultsTable.getResultsTable(title)
        tableIsOpen = False
        if table:
            tableIsOpen = True
        if not tableIsOpen:
            table = ResultsTable()
        minCorrelation, lagOfMinCorrelation = self.model.getMinCorrelationAndLag()
        maxCorrelation, lagOfMaxCorrelation = self.model.getMaxCorrelationAndLag()
        table.incrementCounter()
        table.addValue("image", self.title)
        table.addValue("min.", minCorrelation)
        table.addValue("lag of min.", lagOfMinCorrelation)
        table.addValue("max.", maxCorrelation)
        table.addValue("lag of max.", lagOfMaxCorrelation)
        table.show(title)
        table.updateResults()
    
    
    def showPlot(self):
        X = [lag * self.model.frameInterval for lag in range(-self.model.maxLag, self.model.maxLag+1)]
        plot = Plot("cross-correlation", "lag ["+self.model.timeUnit+"]", "correlation coefficient")
        plot.add("separated bar", X, self.model.crossCorrelationByLag)
        plot.setStyle(0,"black,black,1")    
        plot.show()

    
    def showDialog(self):
        gd = GenericDialog("Cross-Correlograph Options")
        gd.addStringField("Table: ", self.table)
        gd.addStringField("Column of dependent series: ", self.dependentSeriesColumn)
        gd.addStringField("Column of independent series: ", self.independentSeriesColumn)
        gd.addNumericField("Max. lag (in nr. of data points):", self.model.maxLag);
        gd.addStringField("Title: ", self.title)
        gd.addCheckbox("Display plot", self.shallShowPlot)
        gd.showDialog()
        if gd.wasCanceled():
            return False
        self.table = gd.getNextString()
        self.dependentSeriesColumn = gd.getNextString()
        self.independentSeriesColumn = gd.getNextString()
        self.model.maxLag = int(gd.getNextNumber())
        self.title = gd.getNextString()
        self.shallShowPlot = gd.getNextBoolean()
        
        table = ResultsTable.getResultsTable(self.table)
        self.getModel().dependentSeries = table.getColumn(self.dependentSeriesColumn);
        self.getModel().independentSeries = table.getColumn(self.independentSeriesColumn);
        
        return True
        
        
    def getModel(self):
        return self.model



class CrossCorrelograph:


    def __init__(self):
        self.dependentSeries = [] 
        self.independentSeries = []
        self.maxLag = 23
        self.crossCorrelationByLag = []
        self.frameInterval = 60.05
        self.timeUnit = "s"
        self.view = None
       
       
    def getMinCorrelationAndLag(self):
        minCorrelation = min(self.crossCorrelationByLag)
        minIndex = self.crossCorrelationByLag.index(minCorrelation)
        X = [lag * self.frameInterval for lag in range(-self.maxLag, self.maxLag+1)]
        minLag = X[minIndex]
        return minCorrelation, minLag


    def getMaxCorrelationAndLag(self):
        maxCorrelation = max(self.crossCorrelationByLag)
        maxIndex = self.crossCorrelationByLag.index(maxCorrelation)
        X = [lag * self.frameInterval for lag in range(-self.maxLag, self.maxLag+1)]
        maxLag = X[maxIndex]
        return maxCorrelation, maxLag   
    
    
    def getView(self):
        if not self.view:
            self.view = CrossCorrelographView(self)
        return self.view


    def calculateCrossCorrelation(self):
            a = self.dependentSeries
            b = self.independentSeries
            maxLag = self.maxLag
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
            self.crossCorrelationByLag = xCorr


main()

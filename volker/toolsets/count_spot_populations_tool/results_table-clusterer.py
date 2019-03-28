from weka.clusterers import EM
from weka.core import Instance, Instances, DenseInstance, Attribute
from  ij.measure import ResultsTable as RT
from java.util import ArrayList, Random
from math import log, sqrt

def main():
    features = ["Area"]
    numberOfClusters = 2

    features, numberOfClusters = getArguments(features, numberOfClusters)
	
    rt = RT.getResultsTable()
    if (rt.size()<2):
        exit("No data found")

    attributes = featuresToAttributes(features)
    data = readDataFromResultsTable(attributes, rt)

    clusterer = createClusterer(numberOfClusters)
    clusterer.buildClusterer(data)
    (mu1, sig1, mu2, sig2, prior1, prior2) = getClusterInformationFrom(clusterer)
    threshold = intersection(mu2, sig2, mu1, sig1)

    print(clusterer.toString())
    print "intersection at: ", threshold

    if (mu1>mu2):
    	mu1, sig1, mu2, sig2, prior1, prior2 = mu2, sig2, mu1, sig1, prior2, prior1
    	
    writeToTable(mu1, sig1, prior1, mu2, sig2, prior2, threshold)
    
def intersection(mu1, sig1, mu2, sig2):
     if (sig1>sig2):
         mu1, sig1, mu2, sig2 = mu2, sig2, mu1, sig1
     deltaSigmaSq = ((sig1**2) - (sig2**2))
     root = sqrt(((mu1-mu2)**2)+(2*deltaSigmaSq*log(sig1/sig2)))
     numerator = (mu2*(sig1**2)) - sig2*((mu1*sig2)+(sig1*root))
     ans = numerator / deltaSigmaSq
     return ans

def featuresToAttributes(features):
    attributes = []
    nrOfFeatures = len(features)  
    for i in range(0, nrOfFeatures):
         attributes.append(Attribute(features[i]))		
    return attributes

def readDataFromResultsTable(attributes, rt):
    data = Instances("results", ArrayList(attributes), rt.size())
    nrOfFeatures = len(attributes)
    for i in range(0, rt.size()):
        inst = DenseInstance(nrOfFeatures)
        for j in range(0, nrOfFeatures):
            value = rt.getValue(attributes[j].name(), i)
            inst.setValue(attributes[j], value)
	    data.add(inst)
    return data

def getClusterInformationFrom(clusterer):
    mu1 = clusterer.getClusterModelsNumericAtts()[0][0][0]
    sig1 = clusterer.getClusterModelsNumericAtts()[0][0][1]
    mu2 = clusterer.getClusterModelsNumericAtts()[1][0][0]
    sig2 = clusterer.getClusterModelsNumericAtts()[1][0][1]

    priors = clusterer.getClusterPriors()
    prior1 = priors[0]
    prior2 = priors[1]
    return (mu1, sig1, mu2, sig2, prior1, prior2)

def writeToTable(mu1, sig1, prior1, mu2, sig2, prior2, threshold):    

    rt = RT(2)

    rt.setValue("class", 0, 1)
    rt.setValue("mean", 0, mu1)
    rt.setValue("stddev", 0, sig1)
    rt.setValue("prior", 0, prior1)
    rt.setValue("intersection", 0, threshold)
    rt.setValue("count", 0, 0)
    
    rt.setValue("class", 1, 2)
    rt.setValue("mean", 1, mu2)
    rt.setValue("stddev", 1, sig2)
    rt.setValue("prior", 1, prior2)
    rt.setValue("intersection", 1, threshold)
    rt.setValue("count", 1, 0)

    rt.show("clusters")

def createClusterer(numberOfClusters):
    clusterer = EM()
    clusterer.setSeed(Random().nextInt() )
    clusterer.setNumClusters( numberOfClusters )
    return clusterer

def getArguments(features, numberOfClusters):
    if 'getArgument' in globals():
        parameter = getArgument()
        args = parameter.split(",")
        numberOfClusters =  int(args[0].split("=")[1])
        features = args[1].split("=")[1].split()
    return(features, numberOfClusters)

if __name__ in ['__builtin__', '__main__']:
    main()



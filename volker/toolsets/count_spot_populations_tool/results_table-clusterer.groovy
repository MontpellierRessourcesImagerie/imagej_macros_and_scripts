import weka.clusterers.SimpleKMeans
import weka.clusterers.EM
import weka.core.DenseInstance
import weka.core.Instance
import weka.core.Instances
import weka.core.Attribute
import ij.measure.ResultsTable

features = ["Area"]
numberOfClusters = 2


rt = ResultsTable.getResultsTable()
if (rt.size()<2) return "No data found"

attributes = []
nrOfFeatures = features.size()
for(i in 0..nrOfFeatures-1) {
	attributes.add(new Attribute(features[i]))		
}

data = new Instances("results", attributes, rt.size())

for(i in 0..rt.size()-1) {
	Instance inst = new DenseInstance(nrOfFeatures)
	for(j in 0..nrOfFeatures-1) {
		value = rt.getValue(features[j], i)
		inst.setValue(attributes[j], value)
	}
	data.add(inst)
}

clusterer = new EM()
clusterer.setSeed( (new Random()).nextInt() )
clusterer.setNumClusters( numberOfClusters )
clusterer.buildClusterer(data)
// centroids = clusterer.getClusterCentroids()
// println(centroids)
//errors = clusterer.getSquaredError()
//println(errors)
println(clusterer.getMaxIterations())
println(clusterer.toString())
println(clusterer.getNumClusters())
println(clusterer.getClusterModelsNumericAtts()[0][0][0])
println(clusterer.getClusterModelsNumericAtts()[0][0][1])
println(clusterer.getClusterModelsNumericAtts()[1][0][0])
println(clusterer.getClusterModelsNumericAtts()[1][0][1])


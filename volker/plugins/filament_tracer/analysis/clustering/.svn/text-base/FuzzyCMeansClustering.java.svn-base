/* This file is part of MRI Cell Image Analyzer.
 * (c) 2005-2007 Volker Bäcker
 * MRI Cell Image Analyzer has been created at Montpellier RIO Imaging
 * www.mri.cnrs.fr
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 * 
 *
 * fuzzy c-means clustering
 * implementation of
 *
 * Professional Paper
 *
 * Comparison of Fuzzy C-means Algorithm and New Fuzzy Clustering and Fuzzy Merging Algorithm
 * Liyan Zhang
 * Computer Science Department
 * University of Nevada, Reno
 * Reno, NV 89557
 * http://www.cse.unr.edu/~lzhang/javaApp.html#fuzzy
 *
 * by Volker Baecker, Montpellier RIO Imaging, CNRS, 2007
*/

package analysis.clustering;

import ij.ImagePlus;

import java.util.Random;

/**
 * Segment an image using fuzzy c means clustering. This is the abstract superclass. Objects should be created
 * using the newFor method.
 *  
 * @author	Volker Baecker
 **/
abstract public class FuzzyCMeansClustering {
	protected Object input; 
	protected int numberOfClusters;
	protected float[][] weights;
	protected float[][] distances;
	protected float[][] prototypes;
	protected float fuzziness = 2;				// p is fuzziness ? 
	protected int features = 1;
	final protected Random randomNumbers = new Random();
	protected int iterations;
	protected byte[] result;
	protected float quality;
	protected int iterationsRun;
	protected int inputLength;
	protected int[] clusterSize;
	protected float minQuality;
	protected float qualityChangeThreshold;
	protected float maxQualitySoFar;
	protected byte[] bestResult;
	
	abstract protected int getInputLength();
	abstract protected float getInputAt(int feature, int index);
	
	public FuzzyCMeansClustering(Object input, int numberOfClusters, int iterations, float fuzziness, float minQuality, float qualityChangeThreshold) {
		this.input = input;
		this.numberOfClusters = numberOfClusters;
		inputLength = this.getInputLength();
		this.weights = new float[numberOfClusters][inputLength];
		this.distances = new float[numberOfClusters][inputLength];
		this.prototypes = new float[features][numberOfClusters];
		this.iterations = iterations;
		this.fuzziness = fuzziness;
		this.result = new byte[inputLength];
		this.clusterSize = new int[numberOfClusters];
		this.minQuality = minQuality;
		this.qualityChangeThreshold = qualityChangeThreshold;
		this.bestResult = new byte[result.length];
		this.initializeWeights(); 
	}
	
	static public FuzzyCMeansClustering newFor(ImagePlus inputImage, int numberOfClusters, int iterations, float fuzziness, float minQuality, float qualityChangeThreshold) {
		FuzzyCMeansClustering fcm = null;
		if (inputImage.getBitDepth()==8) {
			byte[][] data = new byte[1][inputImage.getWidth() * inputImage.getHeight()];
			data[0] = (byte[])(inputImage.getProcessor().getPixels());
			fcm = new FuzzyCMeansClusteringByte(data, numberOfClusters, iterations, fuzziness, minQuality, qualityChangeThreshold);
		}
		if (inputImage.getBitDepth()==16) {
			short[][] data = new short[1][inputImage.getWidth() * inputImage.getHeight()];
			data[0] = (short[])(inputImage.getProcessor().getPixels());
			fcm = new FuzzyCMeansClusteringShort(data, numberOfClusters, iterations, fuzziness, minQuality, qualityChangeThreshold);
		}
		if (inputImage.getBitDepth()==24) {
			int[][] data = new int[1][inputImage.getWidth() * inputImage.getHeight()];
			data[0] = (int[])(inputImage.getProcessor().getPixels());
			fcm = new FuzzyCMeansClusteringInt(data, numberOfClusters, iterations, fuzziness, minQuality, qualityChangeThreshold);
		}
		if (inputImage.getBitDepth()==32) {
			float[][] data = new float[1][inputImage.getWidth() * inputImage.getHeight()];
			data[0] = (float[])(inputImage.getProcessor().getPixels());
			fcm = new FuzzyCMeansClusteringFloat(data, numberOfClusters, iterations, fuzziness, minQuality, qualityChangeThreshold);
		}
		return fcm;
	}
	
	protected void initializeWeights() {
		// step 1 - initialize weights of prototype 
		for (int cluster=0; cluster<numberOfClusters; cluster++) {
			for (int weight=0; weight<this.getInputLength(); weight++) {
				weights[cluster][weight] = randomNumbers.nextFloat();
			}
		}
		// step 2 - standardize the initial weights over the clusters
		for (int weight=0; weight<inputLength; weight++) {
			float sum = 0;
			for (int cluster=0; cluster<numberOfClusters; cluster++) {
				sum += weights[cluster][weight];
			}
			for (int cluster=0; cluster<numberOfClusters; cluster++) {
				weights[cluster][weight] = weights[cluster][weight]  / sum;
			}
		}
	}
	
	public void run() {
		int iteration = 0;
		float lastQuality = 0;
		maxQualitySoFar = 0;
		do {
			if (iteration>0) lastQuality = quality;
			// step 3 - standardize cluster weights over all weights
			for (int cluster=0; cluster<numberOfClusters; cluster++) {
				float min = 999999.0f;
				float max = 0.0f;
				for (int weight=0; weight<inputLength; weight++) {
					if (weights[cluster][weight]>max) max=weights[cluster][weight];
					if (weights[cluster][weight]<min) min=weights[cluster][weight];
				}
				float sum = 0.0f;
				for(int weight=0; weight<inputLength; weight++) {
					sum += (weights[cluster][weight] - min) / (max - min); 
				}
				for(int weight=0; weight<inputLength; weight++) {
					weights[cluster][weight] =  weights[cluster][weight] / sum;
				}
			}
			
			// step 4 - compute new prototype center
			for (int cluster=0; cluster<numberOfClusters; cluster++) {
				for (int feature=0; feature<features; feature++) {
					float sum = 0.0f;
					for (int weight=0; weight<inputLength; weight++) {
						sum += weights[cluster][weight] * getInputAt(feature, weight);
					}
					prototypes[feature][cluster] = sum;
				}
			}
			
//			 step 7 - asign feature vectors according to max weight
			for (int cluster=0; cluster<numberOfClusters; cluster++) clusterSize[cluster] = 0;
			for (int weight=0; weight<inputLength; weight++) {
				float maxWeight = 0.0f;
				byte kmax = -1;
				for (byte cluster=0; cluster<numberOfClusters; cluster++) {
					if (maxWeight<weights[cluster][weight])  {
						maxWeight = weights[cluster][weight];
						kmax = cluster;
					}
				}
				for (int cluster=0; cluster<numberOfClusters; cluster++) {
					if (kmax==cluster) clusterSize[kmax]++;
				}
				result[weight] = kmax;
			}
			
			this.quality = modifiedXieBeniValidity();
			if (this.quality>maxQualitySoFar) {
				maxQualitySoFar=quality;
				System.arraycopy(result, 0, bestResult, 0, result.length);
			}
			
			// step 5 - compute new weights
			for (int weight=0; weight<inputLength; weight++) {
				float sum = 0.0f;
				for (int cluster=0; cluster<numberOfClusters; cluster++) {
					distances[cluster][weight] = 0.0f;
					for (int feature = 0; feature<features; feature++) {
						distances[cluster][weight] = distances[cluster][weight] + ((getInputAt(feature, weight) - prototypes[feature][cluster]) * (getInputAt(feature, weight) - prototypes[feature][cluster]));
					}
					sum = sum + (float)Math.pow((1d / (1d + (double)distances[cluster][weight])), (1d / (fuzziness-1d)));
				}
				for (int cluster=0; cluster<numberOfClusters; cluster++) {
					weights[cluster][weight] = ((float)Math.pow((1d / (1d + (double)distances[cluster][weight])), (1d / (fuzziness-1d)))) / sum;
				}
			}
			
			// step 6
			iteration++;
			if (iteration>=iterations) break; 
		} while (iteration < 2 || Math.abs(quality-lastQuality)>qualityChangeThreshold || quality==0 || lastQuality==0 || quality<minQuality);
		
		iterationsRun = iteration;
	}
	
	public float[] squareOfVariancePerCluster() {
		float[] variancePerCluster = new float[numberOfClusters]; 
		for (int cluster=0; cluster<numberOfClusters; cluster++) {
			float sum = 0;
			if (clusterSize[cluster]>0) {
				for (int weight=0; weight<inputLength; weight++) {
					for (int feature=0; feature<features; feature++) {
						if (result[weight] == cluster) {
							sum += weights[cluster][weight] * (getInputAt(feature, weight) - prototypes[feature][cluster]) * ((getInputAt(feature, weight)) - prototypes[feature][cluster]);
						}
					}
				}
			}
			variancePerCluster[cluster] = sum; 
		}
		return variancePerCluster;
	}
	
	public float modifiedXieBeniValidity() {
		int numberOfClustersNotEmpty = 0;
		for (int i=0; i<numberOfClusters; i++) {
			if (clusterSize[i]>0) numberOfClustersNotEmpty++;
		}
		if (numberOfClustersNotEmpty<2) return 0;
		float minSquareDistance = 99999999;
		for (int k=0; k<numberOfClusters; k++) {
			if (clusterSize[k]==0) continue;
			for (int l=0; l<numberOfClusters; l++) {
				if (clusterSize[l]==0) continue;
				if (k==l) continue;
				float squareDistance = 0;
				for (int feature=0; feature<features; feature++) {
					squareDistance += ((float)(prototypes[feature][k]) - prototypes[feature][l]) * ((float)(prototypes[feature][k]) - prototypes[feature][l]);
				}
				if (squareDistance<minSquareDistance) minSquareDistance = squareDistance;
			}
		}
		float sumOfSquaresOfVariances = 0;
		float[] squaresOfVariances = this.squareOfVariancePerCluster();
		for (int i=0; i<squaresOfVariances.length; i++) {
			sumOfSquaresOfVariances += squaresOfVariances[i];
		}
		float result = minSquareDistance / sumOfSquaresOfVariances;
		return result;
	}
	
	
	public byte[] getResult() {
		return bestResult;
	}

	public float getQuality() {
		return quality;
	}

	public float getMaxQuality() {
		return maxQualitySoFar;
	}
	
	public int getIterationsRun() {
		return iterationsRun;
	}
	
	public float getSmallestIntensityFromMaxIntensityCluster() {
		int maxPrototypeIndex = 0;
		float max = -1;
		for (int i=0; i<prototypes.length; i++) {
			if (prototypes[0][i]>max) {
				max = prototypes[0][i];
				maxPrototypeIndex = i;
			}
		}
		float min = 999999;
		for (int i=0; i<result.length; i++) {
			if (result[i]!=maxPrototypeIndex) continue;
			if (getInputAt(0, i)<min) min = getInputAt(0, i);
		}
		return min;
	}
 }

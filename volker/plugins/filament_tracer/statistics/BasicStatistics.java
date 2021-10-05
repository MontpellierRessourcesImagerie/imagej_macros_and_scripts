package statistics;

import ij.ImagePlus;

public abstract class BasicStatistics {
	protected Object data;
	protected double median = -1;
	protected double medianStdDev = -1;
	protected double mean = -1;
	protected double meanStdDev = -1;
	protected int length;
	
	abstract protected void sort(Object sortedData);

	abstract protected Object copyData();
	
	abstract public double valueAt(int index);
	
	abstract public double valueAt(int index, Object data);
	
	public BasicStatistics(Object data){
		this.data = data;
	}

	static public BasicStatistics newFor(ImagePlus inputImage) {
		BasicStatistics bs = null;
		if (inputImage.getBitDepth()==8) {
			byte[] data = (byte[])(inputImage.getProcessor().getPixels());
			bs = new BasicStatisticsByte(data);
		}
		if (inputImage.getBitDepth()==16) {
			short[] data = (short[])(inputImage.getProcessor().getPixels());
			bs = new BasicStatisticsShort(data);
		}
		if (inputImage.getBitDepth()==24) {
			int[] data = (int[])(inputImage.getProcessor().getPixels());
			bs = new BasicStatisticsInt(data);
		}
		if (inputImage.getBitDepth()==32) {
			float[] data = (float[])(inputImage.getProcessor().getPixels());
			bs = new BasicStatisticsFloat(data);
		}
		return bs;
	}

	public double getMedianStdDev() {
		if (medianStdDev==-1) medianStdDev = this.getStdDev(this.getMedian());
		return medianStdDev;
	}
	
	public double getMedian() {
		if (median==-1) this.calculcateMedian();
		return median;
	}

	protected void calculcateMedian() {
		Object sortedData = this.copyData();
		System.arraycopy(data, 0, sortedData, 0, length);
		this.sort(sortedData);
		if (length%2==1) {
			int index = length / 2;
			median = this.valueAt(index, sortedData);
		} else {
			int index1 = (length / 2) - 1;
			int index2 = index1 + 1;
			double value1 = this.valueAt(index1, sortedData);
			double value2 = this.valueAt(index2, sortedData);
			median = (value1 + value2) / 2;
		}
	}

	public double getMeanStdDev() {
		if (meanStdDev==-1) meanStdDev = this.getStdDev(this.getMean());
		return meanStdDev;
	}

	public double getMean() {
		if (mean==-1) this.calculcateMean();
		return mean;
	}

	protected void calculcateMean() {
		mean = 0;
		for (int i=0; i<length; i++) {
			mean += valueAt(i);
		}
		mean /= length;
	}

	protected double getStdDev(double center) {
		float sum = 0;
		for (int i=0; i<length; i++) {
			double value = this.valueAt(i);
			sum += (center - value) * (center - value);
		}
		return (float)(Math.sqrt(sum / length));
	}
	
}

package tracing;

import ij.ImagePlus;
import ij.process.ByteProcessor;
import java.awt.Point;
import java.util.HashSet;
import java.util.Iterator;

import analysis.signalToNoise.MedianThresholdSignalToNoiseEstimator;
import analysis.signalToNoise.SignalToNoiseRatioCalculator;
import statistics.BasicStatistics;

abstract public class SeedPointsFinder {
	protected int width;
	protected int height;
	protected Object data;
	protected int hStepSize;
	protected int vStepSize;
	protected HashSet<Point> localMaxima;
	private HashSet<Point> filteredMaxima;
	protected ImagePlus image;
	public float canThreshold = -1;
	
	// options
	protected int hLines;
	protected int vLines;
	protected float thresholdScalingFactor = 0.16f;
	protected int maxFilamentWidth = 6;
	protected int snrRegionRadius = 6;
	
	public SeedPointsFinder(Object data, int hLines, int vLines, int width, int height) {
		this.hLines = hLines;
		this.vLines = vLines;
		this.width = width;
		this.height = height;
		this.data = data;
		this.hStepSize = width / vLines;
		this.vStepSize = height / hLines;
		this.localMaxima = new HashSet<Point>();
		this.filteredMaxima = new HashSet<Point>();
	}
	
	static public SeedPointsFinder newFor(ImagePlus inputImage, int hLines, int vLines) {
		SeedPointsFinder spf = null;
		int width = inputImage.getWidth();
		int height = inputImage.getHeight();
		if (inputImage.getBitDepth()==8) {
			byte[] data = (byte[])(inputImage.getProcessor().getPixels());
			spf = new SeedPointsFinderByte(data, hLines, vLines, width, height);
		}
		if (inputImage.getBitDepth()==16) {
			short[] data = (short[])(inputImage.getProcessor().getPixels());
			spf = new SeedPointsFinderShort(data, hLines, vLines, width, height);
		}
		if (inputImage.getBitDepth()==24) {
			int[] data = (int[])(inputImage.getProcessor().getPixels());
			spf = new SeedPointsFinderInt(data, hLines, vLines, width, height);
		}
		if (inputImage.getBitDepth()==32) {
			float[] data = (float[])(inputImage.getProcessor().getPixels());
			spf = new SeedPointsFinderFloat(data, hLines, vLines, width, height);
		}
		spf.setImage(inputImage);
		return spf;
	}
	
	abstract public float getHPixel(int line, int index);
	
	abstract public float getVPixel(int line, int index);
	
	abstract public float getPixel(int x, int y);

	public int getHStepSize() {
		return hStepSize;
	}
	
	public int getVStepSize() {
		return vStepSize;
	}
	
	public void run() {
		
		for (int line=0; line<hLines; line++) {
			for (int index=0; index<width; index++) {
				float valueBefore, valueAfter;
				valueBefore = (index==0) ? getFilteredHValueAt(line, width-1) : getFilteredHValueAt(line, index-1);
				valueAfter = (index==width-1) ? getFilteredHValueAt(line, 0) : getFilteredHValueAt(line, index+1);
				float value = getFilteredHValueAt(line, index);
				if (value>valueBefore && value>valueAfter) {
					Point point = new Point(index, line*this.getVStepSize());
					localMaxima.add(point);
				}
			}
		}
		
		for (int line=0; line<vLines; line++) {
			for (int index=0; index<height; index++) {
				float valueBefore, valueAfter;
				valueBefore = (index==0) ? getFilteredVValueAt(line, height-1) : getFilteredVValueAt(line, index-1);
				valueAfter = (index==height-1) ? getFilteredVValueAt(line, 0) : getFilteredVValueAt(line, index+1);
				float value = getFilteredVValueAt(line, index);
				if (value>valueBefore && value>valueAfter) {
					Point point = new Point(line*this.getHStepSize(), index);
					localMaxima.add(point);
				}
			}
		}
		calculateCanThreshold();
	}

	public void filterSeedPoints() {
		BasicStatistics stats = BasicStatistics.newFor(this.getImage());
		double threshold = stats.getMedian() + stats.getMedianStdDev();
		Iterator<Point> it = localMaxima.iterator();
		while(it.hasNext()) {
			Point currentPoint = it.next();
			float intensity = getPixel(currentPoint.x, currentPoint.y);
			if (intensity>threshold) filteredMaxima.add(currentPoint);
		}
		this.localMaxima = filteredMaxima;
		filteredMaxima = new HashSet<Point>();
		this.calculateCanThreshold();
		this.setMaxFilamentWidth(FilamentTracer.getOptions().getMaxFilamentWidth());
		FilamentTracer tracer = new FilamentTracer(image);
		it = localMaxima.iterator();
		while(it.hasNext()) {
			Point currentPoint = it.next();
			tracer.calculateMaxTemplateResponsesFor(currentPoint.x, currentPoint.y);
			int direction = tracer.getBestNextDirection();
			float maxResponse = Math.max(tracer.rightEdgeMaxTemplateResponses[direction], tracer.leftEdgeMaxTemplateResponses[direction]);
			float perpendicularResponse = Math.max(tracer.rightEdgeMaxTemplateResponses[(direction+4)%16], tracer.leftEdgeMaxTemplateResponses[(direction+4)%16]);
			if (maxResponse>=canThreshold && perpendicularResponse<maxResponse) filteredMaxima.add(currentPoint);
		}
		this.localMaxima = filteredMaxima;
		filteredMaxima = new HashSet<Point>();
		SignalToNoiseRatioCalculator calc =  SignalToNoiseRatioCalculator.newFor(this.getImage());
		double snrThreshold =  calc.calculateSNR(threshold);
		if (snrThreshold>Float.NEGATIVE_INFINITY&&snrThreshold<Float.POSITIVE_INFINITY) {
		it = localMaxima.iterator();
		MedianThresholdSignalToNoiseEstimator est = MedianThresholdSignalToNoiseEstimator.newFor(image, snrRegionRadius, snrRegionRadius);
		while(it.hasNext()) {
			Point currentPoint = it.next();
			ImagePlus currentArea = est.getImageAround(currentPoint.x, currentPoint.y);
			stats = BasicStatistics.newFor(currentArea);
			double localThreshold = stats.getMedian() + stats.getMedianStdDev();
			double snr = calc.calculateSNRForRegion(currentPoint.x, currentPoint.y, snrRegionRadius, localThreshold);
			if (snr>snrThreshold) filteredMaxima.add(currentPoint);
		}
		this.localMaxima = filteredMaxima;
		filteredMaxima = new HashSet<Point>();
		}
	}
	
	public ImagePlus getMaximaImage() {
		ImagePlus result = new ImagePlus();
		ByteProcessor ip = new ByteProcessor(width, height);
		result.setProcessor("maxima", ip);
		Iterator<Point> it = localMaxima.iterator();
		while(it.hasNext()) {
			Point aPoint = it.next();
			ip.set(aPoint.x, aPoint.y, 255);
		}
		return result;
	}
	
	private float getFilteredHValueAt(int line, int index) {
		int indexBefore, indexAfter;
		indexBefore =  (index==0) ? width-1 : index-1;
		indexAfter =  (index==width-1) ? 0 : index+1;
		
		float value = 0.25f * this.getHPixel(line, indexBefore) + 
					  0.5f * this.getHPixel(line, index) +
					  0.25f * this.getHPixel(line, indexAfter);
		return value;
	}
	
	private float getFilteredVValueAt(int line, int index) {
		int indexBefore, indexAfter;
		indexBefore =  (index==0) ? height-1 : index-1;
		indexAfter =  (index==height-1) ? 0 : index+1;
		
		float value = 0.25f * this.getVPixel(line, indexBefore) + 
					  0.5f * this.getVPixel(line, index) +
					  0.25f * this.getVPixel(line, indexAfter);
		return value;
	}

	public HashSet<Point> getLocalMaxima() {
		return localMaxima;
	}

	public ImagePlus getImage() {
		return image;
	}

	public void setImage(ImagePlus image) {
		this.image = image;
	}
	
	public void calculateCanThreshold() {
		int backgroundIntensity = 0;
		int backgroundCount = 0;
		int foregroundIntensity = 0;
		int foregroundCount = 0;
		for (int line=0; line<hLines; line++) {
			for (int index=0; index<width; index++) {
				float value = getHPixel(line, index);
				Point point = new Point(index, line*this.getVStepSize());
				if (localMaxima.contains(point)) {
					foregroundIntensity += value; 
					foregroundCount++;
				} else {
					backgroundIntensity += value; 
					backgroundCount++;
				}
			}
		}
		for (int line=0; line<vLines; line++) {
			for (int index=0; index<height; index++) {
				float value = getVPixel(line, index);
				Point point = new Point(line*this.getHStepSize(), index);
				if (localMaxima.contains(point)) {
					foregroundIntensity += value; 
					foregroundCount++;
				} else {
					backgroundIntensity += value; 
					backgroundCount++;
				}
			}
		}
		if (backgroundCount==0) backgroundCount = 1;		// test
		if (foregroundCount==0) foregroundCount = 1;		// test
		float backgroundAverage = backgroundIntensity / backgroundCount;
		float foregroundAverage = foregroundIntensity / foregroundCount;
		canThreshold = 36 * (1 + thresholdScalingFactor * Math.abs(foregroundAverage-backgroundAverage) );
		System.out.println("can threshold: " + canThreshold);
	}
	
	public void calculateCanThresholdByMaxima() {
		int backgroundIntensity = 0;
		int backgroundCount = 0;
		int foregroundIntensity = 0;
		int foregroundCount = 0;
		Iterator<Point> it = localMaxima.iterator();
		while(it.hasNext()) {
			Point point = it.next();
			for (int x=0; x<width; x++) {
				float value = getPixel(x, point.y);
				if (localMaxima.contains(point)) {
					foregroundIntensity += value; 
					foregroundCount++;
				} else {
					backgroundIntensity += value; 
					backgroundCount++;
				}
			}
			for (int y=0; y<height; y++) {
				float value = getPixel(point.x, y);
				if (localMaxima.contains(point)) {
					foregroundIntensity += value; 
					foregroundCount++;
				} else {
					backgroundIntensity += value; 
					backgroundCount++;
				}
			}
		}
		if (backgroundCount==0) backgroundCount = 1;		
		if (foregroundCount==0) foregroundCount = 1;		
		float backgroundAverage = backgroundIntensity / backgroundCount;
		float foregroundAverage = foregroundIntensity / foregroundCount;
		canThreshold = 36 * (1 + thresholdScalingFactor * Math.abs(foregroundAverage-backgroundAverage) );
		System.out.println("can threshold: " + canThreshold);
	}

	public float getThresholdScalingFactor() {
		return thresholdScalingFactor;
	}

	public void setThresholdScalingFactor(float thresholdScalingFactor) {
		this.thresholdScalingFactor = thresholdScalingFactor;
	}

	public float getCanThreshold() {
		return canThreshold;
	}

	public int getMaxFilamentWidth() {
		return maxFilamentWidth;
	}

	public void setMaxFilamentWidth(int maxFilamentWidth) {
		this.maxFilamentWidth = maxFilamentWidth;
	}

	public int getSnrRegionRadius() {
		return snrRegionRadius;
	}

	public void setSnrRegionRadius(int snrRegionRadius) {
		this.snrRegionRadius = snrRegionRadius;
	}

	public void setLocalMaxima(HashSet<Point> localMaxima) {
		this.localMaxima = localMaxima;
	}
}

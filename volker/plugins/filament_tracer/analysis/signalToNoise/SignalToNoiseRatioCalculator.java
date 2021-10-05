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
 */
package analysis.signalToNoise;

import statistics.BasicStatistics;
import statistics.BasicStatisticsFloat;
import ij.ImagePlus;

/**
 *  Given a threshold calculate the signal to noise ratio of the image or of
 *  a region. Values above the threshold are counted as foreground and values
 *  upto the threshold value are counted as background.
 *  
 * @author	Volker Baecker
 **/
abstract public class SignalToNoiseRatioCalculator {
	protected ImagePlus image;
	protected int length;
	protected Object data;
	protected int width;
	protected int height;
	
	public SignalToNoiseRatioCalculator(ImagePlus image) {
		this.image = image;
		length = image.getWidth()*image.getHeight();
		data=image.getProcessor().getPixels();
		width = image.getWidth();
		height = image.getHeight();
	}
	
	static public SignalToNoiseRatioCalculator newFor(ImagePlus image) {
		SignalToNoiseRatioCalculator snc = null;
		
		if (image.getBitDepth()==8) {
			snc = new SignalToNoiseRatioCalculatorByte(image);
		}
		if (image.getBitDepth()==16) {
			snc = new SignalToNoiseRatioCalculatorShort(image);
		}
		if (image.getBitDepth()==24) {
			snc = new SignalToNoiseRatioCalculatorInt(image);
		}
		if (image.getBitDepth()==32) {
			snc = new SignalToNoiseRatioCalculatorFloat(image);
		}
		return snc;
	}
	
	public double calculateSNR(double threshold) {
		int foregroundLength = 0;
		int backgroundLength = 0;
		for (int i=0; i<length; i++) {
			if (valueAt(i)>threshold)  foregroundLength++; else backgroundLength++;
		}
		float[] foreground = new float[foregroundLength];
		float[] background = new float[backgroundLength];
		int foregroundCounter = 0;
		int backgroundCounter = 0;
		for (int i=0; i<length; i++) {
			float value = valueAt(i); 
			if (value>threshold) {
				foreground[foregroundCounter] = value;
				foregroundCounter++;
			}  else {
				background[backgroundCounter] = value;
				backgroundCounter++;
			}
		}
		BasicStatistics stats = new BasicStatisticsFloat(foreground);
		double foregroundMean = stats.getMean();
		stats = new BasicStatisticsFloat(background);
		double backgroundMean = stats.getMean();
		double backgroundStdDev = stats.getMeanStdDev();
		double result = (foregroundMean - backgroundMean) / backgroundStdDev;
		return result;
	}

	public double calculateSNRForRegion(int x0, int y0, int radius, double threshold) {
		int foregroundLength = 0;
		int backgroundLength = 0;
		int xStart = ((x0-radius)<0) ? 0 : x0-radius;
		int yStart = ((y0-radius)<0) ? 0 : y0-radius;
		int xEnd = ((x0+radius)>=width) ? width-1 : x0+radius;
		int yEnd = ((y0+radius)>=height) ? height-1 : y0+radius;
		for (int x = xStart; x <= xEnd; x++) {
				for (int y = yStart; y <= yEnd; y++) {
					if (valueAt(x,y) > threshold)
						foregroundLength++;
					else
						backgroundLength++;
			}
		}
		float[] foreground = new float[foregroundLength];
		float[] background = new float[backgroundLength];
		int foregroundCounter = 0;
		int backgroundCounter = 0;
		for (int x = xStart; x <= xEnd; x++) {
			for (int y = yStart; y <= yEnd; y++) {
				float value = valueAt(x, y);
				if (value > threshold) {
					foreground[foregroundCounter] = value;
					foregroundCounter++;
				} else {
					background[backgroundCounter] = value;
					backgroundCounter++;
				}

			}
		}
		BasicStatistics stats = new BasicStatisticsFloat(foreground);
		double foregroundMean = stats.getMean();
		stats = new BasicStatisticsFloat(background);
		double backgroundMean = stats.getMean();
		double backgroundStdDev = stats.getMeanStdDev();
		double result = (foregroundMean - backgroundMean) / backgroundStdDev;
		return result;
	}
	
	abstract protected float valueAt(int i);
	abstract protected float valueAt(int x, int y);
}

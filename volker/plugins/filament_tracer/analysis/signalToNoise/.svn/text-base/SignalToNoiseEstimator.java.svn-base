/* This file is part of MRI Cell Image Analyzer.
 * (c) 2005-2007 Volker B�cker
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

import analysis.ThresholdFinderUtil;
import statistics.BasicStatisticsDouble;
import ij.ImagePlus;
import ij.process.FloatProcessor;
import ij.process.ImageProcessor;

/**
 * Estimate the signal to noise ratio for each pixel in the image,
 * based on a region of a given size by applying an otsu-threshold 
 * to the region and counting pixels with an intensity above the 
 * threshold as foreground and other pixels as background.
 * 
 * @author	Volker Baecker
 */
abstract public class SignalToNoiseEstimator {
	protected int neighborhoodRadiusX;
	protected int neighborhoodRadiusY;
	protected ImagePlus image;
	protected Object pixels;
	
	protected double[] localSNR;
	protected double medianSNR;
	protected int width;
	protected int height;
	protected int neighborhoodWidth;
	protected int neighborhoodHeight;

	
	public SignalToNoiseEstimator(ImagePlus image, int radiusX, int radiusY) {
		this.image = image;
		this.pixels = image.getProcessor().getPixels();
		this.neighborhoodRadiusX = radiusX;
		this.neighborhoodRadiusY = radiusY;
		this.neighborhoodWidth = 2*neighborhoodRadiusX+1;
		this.neighborhoodHeight = 2*neighborhoodRadiusY+1;
		this.width = image.getWidth();
		this.height = image.getHeight();
		localSNR = new double[width*height];
	}
	
	static public SignalToNoiseEstimator newFor(ImagePlus image, int radiusX, int radiusY) {
		SignalToNoiseEstimator sne = null;
		if (image.getBitDepth()==8) {
			sne = new SignalToNoiseEstimatorByte(image, radiusX, radiusY);
		}
		if (image.getBitDepth()==16) {
			sne = new SignalToNoiseEstimatorShort(image, radiusX, radiusY);
		}
		return sne;
	}
	
	abstract public ImageProcessor getProcessor(int width, int height);
	
	public void run() {
		int index=0;
		for (int y=0; y<height; y++) {
			for (int x=0; x<width; x++) {
				ImagePlus currentArea = this.getImageAround(x,y);
				double threshold  = ThresholdFinderUtil.getOtsuThresholdFor(currentArea.getProcessor());
				localSNR[index] = calculateLocalSNR(currentArea, threshold);
				index++;
			}
		}
		BasicStatisticsDouble stats = new BasicStatisticsDouble(localSNR);
		medianSNR = stats.getMedian();
	}

	abstract protected double calculateLocalSNR(ImagePlus image, double threshold);

	protected ImagePlus getImageAround(int x, int y) {
		ImagePlus result = new ImagePlus("snr", this.getProcessor(neighborhoodWidth, neighborhoodHeight));
		Object data = this.getNewArray(neighborhoodWidth*neighborhoodHeight);
		int x1 = x-neighborhoodRadiusX;
		int y1 = y-neighborhoodRadiusY;
		int x2 = x+neighborhoodRadiusX;
		int y2 = y+neighborhoodRadiusY;
		this.getDataAtBorderForRectangle(data, x1, y1, x2, y2);
		result.getProcessor().setPixels(data);
		return result;
	}

	abstract protected void getDataAtBorderForRectangle(Object data, int x1, int y1, int x2, int y2);
	
	abstract protected Object getNewArray(int length);

	public double[] getLocalSNR() {
		return localSNR;
	}

	public double getMedianSNR() {
		return medianSNR;
	}
	
	public ImagePlus getLocalSNRImage() {
		ImagePlus result = new ImagePlus("local snr", new FloatProcessor( width, height)); 
		float[] floatLocalSNR = new float[localSNR.length];
		for (int i=0; i<localSNR.length; i++) 
			floatLocalSNR[i] = (float)localSNR[i];
		result.getProcessor().setPixels(floatLocalSNR);
		result.updateImage();
		return result;
	}
}

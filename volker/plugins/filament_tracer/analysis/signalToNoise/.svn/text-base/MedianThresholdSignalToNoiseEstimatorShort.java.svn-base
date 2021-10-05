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
 */
package analysis.signalToNoise;

import statistics.BasicStatisticsShort;
import ij.ImagePlus;
import ij.process.ImageProcessor;
import ij.process.ShortProcessor;

/**
 * Handles 16 bit images. This class should not be instantiated directly. Use the method newFor
 * of its superclass instead. 
 * 
 * @author	Volker Baecker
 */
public class MedianThresholdSignalToNoiseEstimatorShort extends
		MedianThresholdSignalToNoiseEstimator {

	public MedianThresholdSignalToNoiseEstimatorShort(ImagePlus image, int radiusX, int radiusY) {
		super(image, radiusX, radiusY);
	}
	
	public ImageProcessor getProcessor(int width, int height) {
		return new ShortProcessor(width, height);
	}
	
	protected Object getNewArray(int length) {
		return new short[length];
	}

	protected void getDataAtBorderForRectangle(Object data, int x1, int y1, int x2, int y2) {
		for(int i=0; i<neighborhoodWidth; i++) {
			for(int j=0; j<neighborhoodHeight; j++) {
				int xCoord = x1 + i;
				if (xCoord<0) xCoord = width + xCoord;
				if (xCoord>=width) xCoord = xCoord % width;
				int yCoord = y1 + j;
				if (yCoord<0) yCoord = height + yCoord;
				if (yCoord>=height) yCoord = yCoord % height;
				((short[]) data)[j*neighborhoodWidth+i] = ((short[])pixels)[yCoord*width+xCoord];
			}
		}
	}

	protected double calculateLocalSNR(ImagePlus image, int threshold) {
		int foregroundLength = 0;
		int backgroundLength = 0;
		short[] data = (short[])image.getProcessor().getPixels();
		for (int i=0; i<data.length; i++) {
			if ((data[i]&0xffff)>threshold)  foregroundLength++; else backgroundLength++;
		}
		short[] foreground = new short[foregroundLength];
		short[] background = new short[backgroundLength];
		int foregroundCounter = 0;
		int backgroundCounter = 0;
		for (int i=0; i<data.length; i++) {
			if ((data[i]&0xffff)>threshold) {
				foreground[foregroundCounter] = data[i];
				foregroundCounter++;
			}  else {
				background[backgroundCounter] = data[i];
				backgroundCounter++;
			}
		}
		BasicStatisticsShort stats = new BasicStatisticsShort(foreground);
		double foregroundMean = stats.getMean();
		stats = new BasicStatisticsShort(background);
		double backgroundMean = stats.getMean();
		double backgroundStdDev = stats.getMeanStdDev();
		double result = (foregroundMean - backgroundMean) / backgroundStdDev;
		return result;
	}

}

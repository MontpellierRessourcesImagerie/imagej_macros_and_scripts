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

import ij.ImagePlus;

/**
 *  Handles 24 bit (RGB) images. This class should not be instantiated directly. Use the method newFor
 *  of its superclass instead. 
 *  
 * @author	Volker Baecker
 **/
public class SignalToNoiseRatioCalculatorInt extends
		SignalToNoiseRatioCalculator {

	public SignalToNoiseRatioCalculatorInt(ImagePlus image) {
		super(image);
	}
	
	protected float valueAt(int i) {
		int c = (((int[])(this.data))[i]);
		int[] iArray = new int[3];
		iArray[0] = (c&0xff0000)>>16;
		iArray[1] = (c&0xff00)>>8;
		iArray[2] = c&0xff;
		return iArray[0] + iArray[1] + iArray[2];
	}

	protected float valueAt(int x, int y) {
		int pos = y*width+x;
		int c = (((int[])(this.data))[pos]);
		int[] iArray = new int[3];
		iArray[0] = (c&0xff0000)>>16;
		iArray[1] = (c&0xff00)>>8;
		iArray[2] = c&0xff;
		return iArray[0] + iArray[1] + iArray[2];
	}

}

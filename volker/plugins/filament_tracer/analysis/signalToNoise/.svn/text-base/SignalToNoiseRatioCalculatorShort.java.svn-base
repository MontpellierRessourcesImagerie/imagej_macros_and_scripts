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
 *  Handles 16 bit images. This class should not be instantiated directly. Use the method newFor
 *  of its superclass instead. 
 *  
 * @author	Volker Baecker
 **/
public class SignalToNoiseRatioCalculatorShort extends SignalToNoiseRatioCalculator {

	public SignalToNoiseRatioCalculatorShort(ImagePlus image) {
		super(image);
	}

	protected float valueAt(int i) {
		return (((short[])(this.data))[i])&0xffff;
	}

	protected float valueAt(int x, int y) {
		int pos = y*width+x;
		return (((short[])(this.data))[pos])&0xffff;
	}

}

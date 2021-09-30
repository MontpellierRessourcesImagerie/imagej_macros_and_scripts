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
package analysis.clustering;

/**
 * Segment an image using fuzzy c means clustering. This is the class that handles 
 * RGB color images.
 *  
 * @author	Volker Baecker
 **/
public class FuzzyCMeansClusteringInt extends FuzzyCMeansClustering {

	public FuzzyCMeansClusteringInt(int[][] input, int numberOfClusters, int iterations, float fuzziness, float minQuality, float qualityChangeThreshold) {
		super(input, numberOfClusters, iterations, fuzziness, minQuality, qualityChangeThreshold);
	}

	protected int getInputLength() {
		return ((int[][])(this.input))[0].length;
	}

	protected float getInputAt(int feature, int index) {
		int c = ((int[][])(this.input))[feature][index];
		int[] iArray = new int[3];
		iArray[0] = (c&0xff0000)>>16;
		iArray[1] = (c&0xff00)>>8;
		iArray[2] = c&0xff;
		return iArray[0] + iArray[1] + iArray[2];
	}
}

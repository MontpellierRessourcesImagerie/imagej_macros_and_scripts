/* This code comes from the GLCM_Texture plugin from Julio E. Cabrera (http://rsb.info.nih.gov/ij/plugins/texture.html)
 * The refactoring has been done the 23.08.2007 by Volker Baecker.
 * =====================================================
 * Name:           GLCM_Texture
 * Project:         Gray Level Correlation Matrix Texture Analyzer
 * Version:         0.4
 *
 * Author:           Julio E. Cabrera
 * Date:             06/10/05
 * Comment:       Calculates texture features based in Gray Level Correlation Matrices
 *	   Changes since 0.1 version: The normalization constant (R in Haralick's paper, pixelcounter here)
 *	   now takes in account the fact that for each pair of pixel you take in account there are two entries to the 
 *	   grey level co-ocurrence matrix
 *	   Changes were made also in the Correlation parameter. Now this parameter is calculated according to Walker's paper
 *
 * This file is part of MRI Cell Image Analyzer.
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
 * 
 */

package analysis;

import java.awt.Rectangle;
import ij.process.ImageProcessor;

/**
 *  Calculates texture features based on the Gray Level Correlation Matrices.
 * 
 * @author Julio E. Cabrera (the original plugin), Volker Baecker (the refactorings)
 */
public class GLCMTextureAnalyzer {
	private boolean calculateASM = true;
	private boolean calculateContrast = true;
	private boolean calculateCorrelation = true;
	private boolean calculateIDM = true;
	private boolean calculateEntropy = true;
	private ImageProcessor imageProcessor;
	private Rectangle rectangle;
	public double angularSecondMoment;
	public double contrast;
	public double correlation;
	public double inverseDifferenceMoment;
	public double entropy;
	private double sumOfGLCMElements;
	private final double [] [] glcm= new double [257][257];
	private int step = 1;
	private int angle;
	
	public GLCMTextureAnalyzer(ImageProcessor anImageProcessor) {
		imageProcessor = anImageProcessor;
		rectangle = imageProcessor.getRoi();
		angle = 0;
	}

	public void run() {
		int a;
		int b;
		double pixelCounter=0;
		int deltaX = step, deltaY = 0;
		//====================================================================================================
		// This part computes the Gray Level Correlation Matrix based in the step selected by the user
		if (is90Degrees())  {deltaX =     0; deltaY = -step;}
		if (is180Degrees()) {deltaX = -step; deltaY = 0;}
		if (is270Degrees()) {deltaX = 0; deltaY = step;}
		for (int y=rectangle.y; y<(rectangle.y+rectangle.height); y++) 	{
			for (int x=rectangle.x; x<(rectangle.x+rectangle.width); x++)	 {
				a = imageProcessor.getPixel(x, y);
				b = imageProcessor.getPixel(x+deltaX, y+deltaY);					
				glcm [a][b] +=1;
				glcm [b][a] +=1;
				pixelCounter +=2;
			}
		}
		//=====================================================================================================
		// This part divides each member of the glcm matrix by the number of pixels. The number of pixels was stored in the pixelCounter variable
		// The number of pixels is used as a normalizing constant
		double px=0, py=0, stdevx=0, stdevy =0;
		double aMinusPx, bMinusPy, current;
		for (a=0;  a<257; a++)  {
			for (b=0; b<257;b++) {
				glcm[a][b]=(glcm[a][b])/(pixelCounter);
				current = glcm[a][b];
				px=px+a*current;  
                py=py+b*current;
                aMinusPx = a-px;
                bMinusPy = b-py;
                stdevx=stdevx+(aMinusPx)*(aMinusPx)*current;
				stdevy=stdevy+(bMinusPy)*(bMinusPy)*current;
			}
		}

		angularSecondMoment = contrast = correlation = inverseDifferenceMoment = entropy = sumOfGLCMElements = 0;
		for (a=0;  a<257; a++)  {
			for (b=0; b<257;b++) {
				current = glcm[a][b];
				int aMinusB = a-b;
				int aMinusBTimesAMinusB = aMinusB * aMinusB;
//				=====================================================================================================
//				 This part calculates the angular second moment; the value is stored in asm
				if (calculateASM) angularSecondMoment=angularSecondMoment+(current*current);
//				=====================================================================================================
//				 This part calculates the contrast; the value is stored in contrast
				if (calculateContrast) contrast=contrast+ aMinusBTimesAMinusB *(current);
//				=====================================================================================================
//				 This part calculates the correlation; the value is stored in correlation
//				 px []  and py [] are arrays to calculate the correlation
//				 meanx and meany are variables  to calculate the correlation
//				 stdevx and stdevy are variables to calculate the correlation
				if (calculateCorrelation) {
					px=px+a*current;  
	                py=py+b*current;
	                aMinusPx = a-px;
	                bMinusPy = b-py;
					correlation=correlation+( (aMinusPx)*(bMinusPy)*current/(stdevx*stdevy)) ;
				}
//				===============================================================================================
//				 This part calculates the inverse difference moment
				if (calculateIDM==true){
					inverseDifferenceMoment=inverseDifferenceMoment+(current/(1+aMinusBTimesAMinusB))  ;
				}
//				===============================================================================================
//				 This part calculates the entropy
				if (calculateEntropy==true){
					if (current!=0) entropy=entropy-(current*(Math.log(current)));
				}
				sumOfGLCMElements= sumOfGLCMElements + current;
			}
		}
		for (a=0;  a<257; a++)  {
			for (b=0; b<257;b++) {
				
			}
		}
	}
	
	public boolean is0Degrees() {
		return this.angle == 0;
	}
	
	public boolean is90Degrees() {
		return this.angle == 90;
	}
	
	public boolean is180Degrees() {
		return this.angle == 180;
	}
	
	public boolean is270Degrees() {
		return this.angle == 270;
	}

	public void be0Degrees() {
		this.angle = 0;
	}
	
	public void be90Degrees() {
		this.angle = 90;
	}
	
	public void be180Degrees() {
		this.angle = 180;
	}
	
	public void be270Degrees() {
		this.angle = 270;
	}

	public boolean isCalculateASM() {
		return calculateASM;
	}

	public void setCalculateASM(boolean calculateASM) {
		this.calculateASM = calculateASM;
	}

	public boolean isCalculateContrast() {
		return calculateContrast;
	}

	public void setCalculateContrast(boolean calculateContrast) {
		this.calculateContrast = calculateContrast;
	}

	public boolean isCalculateCorrelation() {
		return calculateCorrelation;
	}

	public void setCalculateCorrelation(boolean calculateCorrelation) {
		this.calculateCorrelation = calculateCorrelation;
	}

	public boolean isCalculateEntropy() {
		return calculateEntropy;
	}

	public void setCalculateEntropy(boolean calculateEntropy) {
		this.calculateEntropy = calculateEntropy;
	}

	public boolean isCalculateIDM() {
		return calculateIDM;
	}

	public void setCalculateIDM(boolean calculateIDM) {
		this.calculateIDM = calculateIDM;
	}

	public int getStep() {
		return step;
	}

	public void setStep(int step) {
		this.step = step;
	}

	public Rectangle getRectangle() {
		return rectangle;
	}

	public void setRectangle(Rectangle roi) {
		this.rectangle = roi;
	}
}

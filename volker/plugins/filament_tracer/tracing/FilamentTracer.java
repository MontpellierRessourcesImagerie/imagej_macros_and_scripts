package tracing;

import java.awt.Point;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Vector;

import statistics.BasicStatistics;
import statistics.BasicStatisticsFloat;
import ij.IJ;
import ij.ImagePlus;
import ij.WindowManager;
import ij.gui.Roi;
import ij.plugin.Duplicator;
import ij.plugin.frame.RoiManager;

public class FilamentTracer {
	private static TreeTracerOptions options;
	public int[] rightEdgeMaxTemplateResponses;		
	public int[] leftEdgeMaxTemplateResponses;	

	public int[] rightEdgeMaxTemplateResponseDistances;		
	public int[] leftEdgeMaxTemplateResponseDistances;

	protected ImagePlus image;
	
	// these are the directions of the scanline (90� to the filament direction)
	final public float[] xInc = { 0,  -0.5f,   -1,  -1   , -1,    -1, -1, -0.5f,  0,  0.5f, 1,  1,    1,  1,     1, 0.5f};
	final public float[] yInc = { 1,      1,    1,   0.5f,  0, -0.5f, -1,    -1, -1, -1,   -1, -0.5f, 0,  0.5f,  1, 1   };
	
	private int lastDirection;

	protected int maxLength;

	protected int width;

	protected int height;

	protected HashSet<Point> seedPoints;

	private byte[][] pointsAlreadyFound = null;

	// options

	protected SeedPointsFinder finder;
	
	public FilamentTracer(ImagePlus image) {
		this.image = image;
		rightEdgeMaxTemplateResponses = new int[16];
		rightEdgeMaxTemplateResponseDistances = new int[16];
		leftEdgeMaxTemplateResponses = new int[16];
		leftEdgeMaxTemplateResponseDistances = new int[16];
		width = image.getWidth();
		height = image.getHeight();
		maxLength = width + height;
	}

	public Vector<Tracing> traceBranches(Tracing mainTracing) {
		if (finder==null) finder = SeedPointsFinder.newFor(image, (int)Math.round(height*0.25), (int)Math.round(width*0.25));
		seedPoints = new HashSet<Point>();
		Iterator<Point> it = mainTracing.center.iterator();
		while (it.hasNext()) {
			Point currentPoint = it.next();
			int xStart = Math.max(0, currentPoint.x-20);
			int xEnd = Math.min(width-1, currentPoint.x+20);
			float[] scanLine = new float[41];
			int index = 0;
			for (int x=xStart; x<=xEnd; x++) {
				scanLine[index] = finder.getPixel(x, currentPoint.y);
				index++;
			}
			Vector<Integer> localMaxima = getLocalMaximaAboveMean(scanLine);
			int leftLimit = 21 - 4;
			int rightLimit = 21 + 4;
			for (int i=0; i<localMaxima.size(); i++) {
				int pointIndex = localMaxima.elementAt(i).intValue();
				if (pointIndex<leftLimit ||  pointIndex>rightLimit) {
					Point p = new Point(xStart+pointIndex, currentPoint.y);
					seedPoints.add(p);
				}
			}
		}
		// to do: stop tracing when center hit
		finder.setLocalMaxima(seedPoints);
		finder.filterSeedPoints();
		it = seedPoints.iterator();
		Vector<Tracing> traces = new Vector<Tracing>();
		pointsAlreadyFound  = new byte[image.getWidth()][image.getHeight()];
		while(it.hasNext()) {
			Point seed = it.next();
			boolean found = false;
			for (int i=seed.x-1; i<=seed.x+1;i++) {
				for (int j=seed.y-1; j<=seed.y+1;j++) {
					int px=Math.max(0, i);
					px=Math.min(width-1, px);
					int py=Math.max(0, j);
					py=Math.min(height-1, py);
					if (pointsAlreadyFound[px][py]==1) found = true;
				}	
			} 
			if (found) continue;
			Tracing aTrace = this.traceFrom(seed.x, seed.y);
			Roi aRoi = aTrace.getCenterPolygonRoi();
			aRoi.setImage(image);
			if (aRoi.getLength()>=getOptions().getMinTracingLength()) traces.add(aTrace);
		}
		pointsAlreadyFound = null;
		return traces;
	}
	
	private Vector<Integer> getLocalMaximaAboveMean(float[] scanLine) {
		Vector<Integer> localMaxima = new Vector<Integer>();
	//	float lastValue = 0;
	//	float nextValue = 0;
		float value = 0;
		BasicStatistics stats = new BasicStatisticsFloat(scanLine);
		double mean = stats.getMean() + stats.getMeanStdDev();
		for (int i=0; i<scanLine.length; i++) {
			value = scanLine[i];
			//if (i>0) lastValue=scanLine[i-1]; else lastValue = value;
			//if (i<scanLine.length-1) nextValue=scanLine[i+1];
			if (value>mean /*&& lastValue<value && nextValue<value*/) localMaxima.add(new Integer(i));
		}
		return localMaxima;
	}

	public Vector<Tracing> trace() {	
		this.calculateSeedPoints();	
		Vector<Tracing> traces = new Vector<Tracing>();
		Iterator<Point> it = seedPoints.iterator();
		pointsAlreadyFound  = new byte[image.getWidth()][image.getHeight()];
		while(it.hasNext()) {
			Point point = it.next();
			boolean found = false;
			for (int i=point.x-1; i<=point.x+1;i++) {
				for (int j=point.y-1; j<=point.y+1;j++) {
					int px=Math.max(0, i);
					px=Math.min(width-1, px);
					int py=Math.max(0, j);
					py=Math.min(height-1, py);
					if (pointsAlreadyFound[px][py]==1) found =true;
				}	
			} 
			if (found) continue;
			Tracing aTrace = traceFrom(point.x, point.y);
			Roi aRoi = aTrace.getCenterPolygonRoi();
			aRoi.setImage(image);
			if (aRoi.getLength()>=getOptions().getMinTracingLength()) traces.add(aTrace);
		}
		pointsAlreadyFound = null;
		return traces;
	}
	
	public void calculateSeedPoints() {
		if (finder==null) finder = SeedPointsFinder.newFor(image, (int)Math.round(height*0.25), (int)Math.round(width*0.25));
		finder.run();
		finder.filterSeedPoints();
		this.seedPoints=finder.getLocalMaxima();
	}
	
	public Tracing traceFrom(int x, int y) {
		if (seedPoints==null) this.calculateSeedPoints();	
		// test
		  finder.setLocalMaxima(seedPoints);
		  if (finder.canThreshold==-1) finder.calculateCanThresholdByMaxima();
		// end test
		Tracing trace1 = new Tracing();
//		Tracing trace2 = new Tracing();
		calculateMaxTemplateResponsesFor(x,y);
		int direction = this.getBestStartDirection();
//		int aDirection = this.getSecondBestStartDirection(direction);
//		int angle = Math.abs(direction-aDirection);
//		int direction2 = (direction + 8) % 16;
//		if (angle>6 && angle<10) {
//			direction2 = aDirection;
//		}
		traceFrom(x, y, direction, trace1);
//		traceFrom(x, y, direction2, trace2);
//		return trace1.join(trace1);
		return trace1;
	}
	

	public Tracing traceFrom(int x, int y, int startDirection, Tracing trace) {
		int index = 1;
		int xn = x;
		int yn = y;
		lastDirection = startDirection;
		int sum = 0;
		float maxIntensityDropFraction = getOptions().getMaxIntensityDropFraction();
		while (!isFinished(xn,yn, index)) {
			int value = image.getPixel(xn, yn)[0];
			sum += value;
			float mean = sum / index;
			calculateMaxTemplateResponsesFor(xn,yn);
			int direction = this.getBestNextDirection();
			lastDirection = direction;
			float maxResponse = Math.max(rightEdgeMaxTemplateResponses[direction], leftEdgeMaxTemplateResponses[direction]);
			if (maxResponse<finder.canThreshold) break;
			if (mean - value > maxIntensityDropFraction*mean) {
				break;
			}
			int filamentDirection = direction - 4;
			if (filamentDirection<0) filamentDirection = 16 + filamentDirection;
			int leftDistance = leftEdgeMaxTemplateResponseDistances[direction];
			int rightDistance = rightEdgeMaxTemplateResponseDistances[direction];
			int leftEdgeX = (int)(xn-(leftDistance*xInc[direction]));
			int leftEdgeY = (int)(yn-(leftDistance*yInc[direction]));
			int rightEdgeX = (int)(xn+(rightDistance*xInc[direction]));
			int rightEdgeY = (int)(yn+(rightDistance*yInc[direction]));
			int centerX = (int) (
							Math.min(leftEdgeX, rightEdgeX) + ( 
									Math.floor((
											Math.max(leftEdgeX, rightEdgeX) - 
											Math.min(leftEdgeX, rightEdgeX)) /
											2.0)
							 )
							);
			int centerY = (int) (
					Math.min(leftEdgeY, rightEdgeY) + ( 
									Math.floor((
											Math.max(leftEdgeY, rightEdgeY) - 
											Math.min(leftEdgeY, rightEdgeY)) /
											2.0)
					 )
					);
			double length = Math.sqrt(((xInc[filamentDirection]*xInc[filamentDirection]) +
						   (yInc[filamentDirection]*yInc[filamentDirection])));
			xn=(int)Math.round((centerX+(getOptions().getStepSize()*(xInc[filamentDirection]/length))));
			yn=(int)Math.round((centerY+(getOptions().getStepSize()*(yInc[filamentDirection])/length)));
			trace.add(new Point(leftEdgeX, leftEdgeY), new Point(centerX, centerY), new Point(rightEdgeX, rightEdgeY));
			if (pointsAlreadyFound!=null) {
				pointsAlreadyFound[centerX][centerY] = 1;
			}
			index++;
		}
		
		return trace;
	}
	
	private boolean isFinished(int xn, int yn, int step) {
		if (step>maxLength) return true;
		if (xn<=0 || xn>=width-1 || yn<=0 || yn>=height-1) return true;
		return false;
	}

	protected int getBestNextDirection() {
		int maxResponse = -999999999;
		int direction = -1;
		for (int i = -1; i < 2; i++) {
			int index = lastDirection + i;
			if (index < 0)
				index = 15;
			if (index > 15)
				index = 0;
			int rightResponse = rightEdgeMaxTemplateResponses[index];
			int leftResponse = leftEdgeMaxTemplateResponses[index];
			if (rightResponse > maxResponse) {
				maxResponse = rightResponse;
				direction = index;
			}
			if (leftResponse > maxResponse) {
				maxResponse = leftResponse;
				direction = index;
			}
		}
		return direction;
	}
	
	public int getBestStartDirection() {
		int maxResponse = -999999;
		int direction = -1;
		for (int i=0; i<16; i++)  {
			int rightResponse = rightEdgeMaxTemplateResponses[i];
			int leftResponse = leftEdgeMaxTemplateResponses[i];
			if (rightResponse>maxResponse) {
				maxResponse = rightResponse;
				direction = i;
			}
			if (leftResponse>maxResponse) {
				maxResponse = leftResponse;
				direction = i;
			}
		}
		return direction;
	}
		
	protected int getSecondBestStartDirection(int bestDirection) {
		int maxResponse = -999999;
		int direction = -1;
		for (int i=0; i<16; i++)  {
			if (i==bestDirection) continue;
			int rightResponse = rightEdgeMaxTemplateResponses[i];
			int leftResponse = leftEdgeMaxTemplateResponses[i];
			if (rightResponse>maxResponse) {
				maxResponse = rightResponse;
				direction = i;
			}
			if (leftResponse>maxResponse) {
				maxResponse = leftResponse;
				direction = i;
			}
		}
		return direction;
	}

	public void calculateMaxTemplateResponsesFor(int x, int y) {
		for (int i=0; i<16; i++) {
			rightEdgeMaxTemplateResponses[i] = -999999;
			leftEdgeMaxTemplateResponses[i] = -999999;
			rightEdgeMaxTemplateResponseDistances[i] = -1;
			leftEdgeMaxTemplateResponseDistances[i] = -1;
		}
		
		// right edge templates
		
		for (int distance=0; distance<getOptions().getMaxFilamentWidth()/2; distance++) {

			// direction 0 - 0�

			int startX = x + (int)(distance * xInc[0]);
			int startY = y + (int)(distance * yInc[0]);

			int value = 
			
			image.getPixel(startX+0, startY-2)[0] + 
			image.getPixel(startX+1, startY-2)[0] +
			image.getPixel(startX+2, startY-2)[0] +
			image.getPixel(startX+3, startY-2)[0] +
			image.getPixel(startX+4, startY-2)[0] +
			image.getPixel(startX+5, startY-2)[0] +

			2*image.getPixel(startX+0, startY-1)[0] + 
			2*image.getPixel(startX+1, startY-1)[0] +
			2*image.getPixel(startX+2, startY-1)[0] +
			2*image.getPixel(startX+3, startY-1)[0] +
			2*image.getPixel(startX+4, startY-1)[0] +
			2*image.getPixel(startX+5, startY-1)[0] +

			-2*image.getPixel(startX+0, startY+1)[0] + 
			-2*image.getPixel(startX+1, startY+1)[0] +
			-2*image.getPixel(startX+2, startY+1)[0] +
			-2*image.getPixel(startX+3, startY+1)[0] +
			-2*image.getPixel(startX+4, startY+1)[0] +
			-2*image.getPixel(startX+5, startY+1)[0] +

			-1*image.getPixel(startX+0, startY+2)[0] + 
			-1*image.getPixel(startX+1, startY+2)[0] +
			-1*image.getPixel(startX+2, startY+2)[0] +
			-1*image.getPixel(startX+3, startY+2)[0] +
			-1*image.getPixel(startX+4, startY+2)[0] +
			-1*image.getPixel(startX+5, startY+2)[0];
			
			if (value>rightEdgeMaxTemplateResponses[0])	{
				rightEdgeMaxTemplateResponses[0] = value;
				rightEdgeMaxTemplateResponseDistances[0] = distance;
			}	

			//		 direction 1 - -22.5�

			startX = x + (int)(distance * xInc[1]);
			startY = y + (int)(distance * yInc[1]);

			value = 
				
			  image.getPixel(startX+1, startY-2)[0] + 

			 2*image.getPixel(startX+0, startY-1)[0] +
			 2*image.getPixel(startX+1, startY-1)[0] +
			 1*image.getPixel(startX+2, startY-1)[0] +
			 1*image.getPixel(startX+3, startY-1)[0] +
			 1*image.getPixel(startX+4, startY-1)[0] +

			 2*image.getPixel(startX+2, startY)[0] +
			 2*image.getPixel(startX+3, startY)[0] +
			 1*image.getPixel(startX+4, startY)[0] +
			 1*image.getPixel(startX+5, startY)[0] +

			-2*image.getPixel(startX+0, startY+1)[0] +
			-2*image.getPixel(startX+1, startY+1)[0] +
			2*image.getPixel(startX+4, startY+1)[0] +
			2*image.getPixel(startX+5, startY+1)[0] +

			-1*image.getPixel(startX-1, startY+2)[0] +
			-1*image.getPixel(startX+0, startY+2)[0] +
			-2*image.getPixel(startX+1, startY+2)[0] +
			-2*image.getPixel(startX+2, startY+2)[0] +
			-2*image.getPixel(startX+3, startY+2)[0] +

			-1*image.getPixel(startX+1, startY+3)[0] +
			-1*image.getPixel(startX+2, startY+3)[0] +
			-1*image.getPixel(startX+3, startY+3)[0] +
			-2*image.getPixel(startX+4, startY+3)[0] +

			-1*image.getPixel(startX+4, startY+4)[0];

			if (value>rightEdgeMaxTemplateResponses[1])	{
				rightEdgeMaxTemplateResponses[1] = value;
				rightEdgeMaxTemplateResponseDistances[1] = distance;
			}
			
//			 direction 2 - -45�

			startX = x + (int)(distance * xInc[2]);
			startY = y + (int)(distance * yInc[2]);
			
			value = 2*image.getPixel(startX+0, startY-1)[0] +
					  image.getPixel(startX+1, startY-1)[0] +
				   
				   -2*image.getPixel(startX-1, startY)[0] +
				    2*image.getPixel(startX+1, startY)[0] +
				      image.getPixel(startX+2, startY)[0] +
				      
				   -1*image.getPixel(startX-1, startY+1)[0] +
				   -2*image.getPixel(startX,   startY+1)[0] +
				    2*image.getPixel(startX+2, startY+1)[0] +
				      image.getPixel(startX+3, startY+1)[0] +
				      
				   -1*image.getPixel(startX,   startY+2)[0] +
				   -2*image.getPixel(startX+1, startY+2)[0] +
					2*image.getPixel(startX+3, startY+2)[0] +
					  image.getPixel(startX+4, startY+2)[0] +  
				   
				   -1*image.getPixel(startX+1, startY+3)[0] +
				   -2*image.getPixel(startX+2, startY+3)[0] +
					2*image.getPixel(startX+4, startY+3)[0] +
					  image.getPixel(startX+5, startY+3)[0] +
					  
				   -1*image.getPixel(startX+2, startY+4)[0] +
				   -2*image.getPixel(startX+3, startY+4)[0] +
					2*image.getPixel(startX+5, startY+4)[0] +
					  image.getPixel(startX+6, startY+4)[0] +
					  
				   -1*image.getPixel(startX+3, startY+5)[0] +
				   -2*image.getPixel(startX+4, startY+5)[0] +
				   
				   -1*image.getPixel(startX+4, startY+6)[0];
			
			if (value>rightEdgeMaxTemplateResponses[2])	{
				rightEdgeMaxTemplateResponses[2] = value;
				rightEdgeMaxTemplateResponseDistances[2] = distance;
			}
			
//			 direction 3 - -67.5�
			
			startX = x + (int)(distance * xInc[3]);
			startY = y + (int)(distance * yInc[3]);
			
			value = image.getPixel(startX+2, startY-1)[0] +
			
			    -2*image.getPixel(startX-1, startY)[0] +
			     2*image.getPixel(startX+1, startY)[0] +
			       image.getPixel(startX+2, startY)[0] +
			        
			    -1*image.getPixel(startX-2, startY+1)[0] +
			    -2*image.getPixel(startX-1, startY+1)[0] +
			     2*image.getPixel(startX+1, startY+1)[0] +
			     2*image.getPixel(startX+2, startY+1)[0] +
			       image.getPixel(startX+3, startY+1)[0] +
			     
			    -1*image.getPixel(startX-1, startY+2)[0] +
				-2*image.getPixel(startX  , startY+2)[0] +
				 2*image.getPixel(startX+2, startY+2)[0] +
				 1*image.getPixel(startX+3, startY+2)[0] +
				 
				 -1*image.getPixel(startX-1, startY+3)[0] +
			     -2*image.getPixel(startX  , startY+3)[0] +
				  2*image.getPixel(startX+2, startY+3)[0] +
				    image.getPixel(startX+3, startY+3)[0] +
				  
				  -1*image.getPixel(startX-1, startY+4)[0] +
				  -1*image.getPixel(startX  , startY+4)[0] +
				  -2*image.getPixel(startX+1, startY+4)[0] +
				   2*image.getPixel(startX+3, startY+4)[0] +
				     image.getPixel(startX+4, startY+4)[0] +
				     
				  -1*image.getPixel(startX  , startY+5)[0] +
				  -2*image.getPixel(startX+1, startY+5)[0];
			
			if (value>rightEdgeMaxTemplateResponses[3])	{
				rightEdgeMaxTemplateResponses[3] = value;
				rightEdgeMaxTemplateResponseDistances[3] = distance;
			}
			
//			 direction 4 - -90�
			
			startX = x + (int)(distance * xInc[4]);
			startY = y + (int)(distance * yInc[4]);
			
			value = -1*image.getPixel(startX-2, startY)[0] +
					-2*image.getPixel(startX-1, startY)[0] +
					 2*image.getPixel(startX+1, startY)[0] +
					   image.getPixel(startX+2, startY)[0] +
					 
					 -1*image.getPixel(startX-2, startY+1)[0] +
					 -2*image.getPixel(startX-1, startY+1)[0] +
					  2*image.getPixel(startX+1, startY+1)[0] +
					    image.getPixel(startX+2, startY+1)[0] +

				     -1*image.getPixel(startX-2, startY+2)[0] +
					 -2*image.getPixel(startX-1, startY+2)[0] +
					  2*image.getPixel(startX+1, startY+2)[0] +
					    image.getPixel(startX+2, startY+2)[0] +
					  
					 -1*image.getPixel(startX-2, startY+3)[0] +
					 -2*image.getPixel(startX-1, startY+3)[0] +
					  2*image.getPixel(startX+1, startY+3)[0] +
					    image.getPixel(startX+2, startY+3)[0] +
					  
					 -1*image.getPixel(startX-2, startY+4)[0] +
					 -2*image.getPixel(startX-1, startY+4)[0] +
					  2*image.getPixel(startX+1, startY+4)[0] +
					    image.getPixel(startX+2, startY+4)[0] +
					  
					 -1*image.getPixel(startX-2, startY+5)[0] +
					 -2*image.getPixel(startX-1, startY+5)[0] +
					  2*image.getPixel(startX+1, startY+5)[0] +
					    image.getPixel(startX+2, startY+5)[0];
			
			if (value>rightEdgeMaxTemplateResponses[4])	{
				rightEdgeMaxTemplateResponses[4] = value;
				rightEdgeMaxTemplateResponseDistances[4] = distance;
			}
			
//			 direction 5 - -112.5�
			
			startX = x + (int)(distance * xInc[5]);
			startY = y + (int)(distance * yInc[5]);
			
			value = -1*image.getPixel(startX-2, startY-1)[0] +
				    
			        -1*image.getPixel(startX-2, startY)[0] +
			        -2*image.getPixel(startX-1, startY)[0] +
			         2*image.getPixel(startX+1, startY)[0] +
			         
			        -1*image.getPixel(startX-3, startY+1)[0] +
			        -2*image.getPixel(startX-2, startY+1)[0] +
			        -2*image.getPixel(startX-1, startY+1)[0] +
			         2*image.getPixel(startX+1, startY+1)[0] +
			         1*image.getPixel(startX+2, startY+1)[0] +
			         
			        -1*image.getPixel(startX-3, startY+2)[0] +
			        -2*image.getPixel(startX-2, startY+2)[0] +
			         2*image.getPixel(startX  , startY+2)[0] +
			         1*image.getPixel(startX+1, startY+2)[0] +
			        
			        -1*image.getPixel(startX-3, startY+3)[0] +
				    -2*image.getPixel(startX-2, startY+3)[0] +
				     2*image.getPixel(startX  , startY+3)[0] +
				     1*image.getPixel(startX+1, startY+3)[0] +
				     
				    -1*image.getPixel(startX-4, startY+4)[0] +
				    -2*image.getPixel(startX-3, startY+4)[0] +
				     2*image.getPixel(startX-1, startY+4)[0] +
				       image.getPixel(startX  , startY+4)[0] +
				       image.getPixel(startX+1, startY+4)[0] +
				       
				     2*image.getPixel(startX-1, startY+5)[0] +
				     1*image.getPixel(startX  , startY+5)[0];
			
			if (value>rightEdgeMaxTemplateResponses[5])	{
				rightEdgeMaxTemplateResponses[5] = value;
				rightEdgeMaxTemplateResponseDistances[5] = distance;
			}
			
//			 direction 6 - -135�
			
			startX = x + (int)(distance * xInc[6]);
			startY = y + (int)(distance * yInc[6]);
			
			value = -1*image.getPixel(startX-1, startY-1)[0] +
				    -2*image.getPixel(startX  , startY-1)[0] +
				    
				    -1*image.getPixel(startX-2, startY  )[0] +
				    -2*image.getPixel(startX-1, startY  )[0] +
				     2*image.getPixel(startX+1, startY  )[0] +
				     
				    -1*image.getPixel(startX-3, startY+1)[0] +
				    -2*image.getPixel(startX-2, startY+1)[0] +
				     2*image.getPixel(startX  , startY+1)[0] +
				       image.getPixel(startX+1, startY+1)[0] +
				     
				    -1*image.getPixel(startX-4, startY+2)[0] +
				    -2*image.getPixel(startX-3, startY+2)[0] +
				     2*image.getPixel(startX-1, startY+2)[0] +
				       image.getPixel(startX  , startY+2)[0] +
				     
				    -1*image.getPixel(startX-5, startY+3)[0] +
				    -2*image.getPixel(startX-4, startY+3)[0] +
				     2*image.getPixel(startX-2, startY+3)[0] +
				       image.getPixel(startX-1, startY+3)[0] +
				     
				    -1*image.getPixel(startX-6, startY+4)[0] +
  				    -2*image.getPixel(startX-5, startY+4)[0] +
					 2*image.getPixel(startX-3, startY+4)[0] +
					   image.getPixel(startX-2, startY+4)[0] +
					 
					 2*image.getPixel(startX-4, startY+5)[0] +
				       image.getPixel(startX-3, startY+5)[0] +
				       
				       image.getPixel(startX-4, startY+6)[0];

			if (value>rightEdgeMaxTemplateResponses[6])	{
				rightEdgeMaxTemplateResponses[6] = value;
				rightEdgeMaxTemplateResponseDistances[6] = distance;
			}
			
//			direction 7 - -157.5�
			
			startX = x + (int)(distance * xInc[7]);
			startY = y + (int)(distance * yInc[7]);
			
			value = -1*image.getPixel(startX-1, startY-2)[0] +
			
					-1*image.getPixel(startX-4, startY-1)[0] +
					-1*image.getPixel(startX-3, startY-1)[0] +
					-1*image.getPixel(startX-2, startY-1)[0] +
					-2*image.getPixel(startX-1, startY-1)[0] +
					-2*image.getPixel(startX  , startY-1)[0] +
					
					-1*image.getPixel(startX-5, startY  )[0] +
					-1*image.getPixel(startX-4, startY  )[0] +
					-2*image.getPixel(startX-3, startY  )[0] +
					-2*image.getPixel(startX-2, startY  )[0] +
					
					-2*image.getPixel(startX-5, startY+1)[0] +
					-2*image.getPixel(startX-4, startY+1)[0] +
					 2*image.getPixel(startX-1, startY+1)[0] +
					 2*image.getPixel(startX  , startY+1)[0] +
					 
					 2*image.getPixel(startX-3, startY+2)[0] +
				     2*image.getPixel(startX-2, startY+2)[0] +
					 2*image.getPixel(startX-1, startY+2)[0] +
					   image.getPixel(startX  , startY+2)[0] +
					   image.getPixel(startX+1, startY+2)[0] +
					   
					 2*image.getPixel(startX-4, startY+3)[0] +
					   image.getPixel(startX-3, startY+3)[0] +
					   image.getPixel(startX-2, startY+3)[0] +
					   image.getPixel(startX-1, startY+3)[0] +
					   
					   image.getPixel(startX-4, startY+4)[0];
			
			if (value>rightEdgeMaxTemplateResponses[7])	{
				rightEdgeMaxTemplateResponses[7] = value;
				rightEdgeMaxTemplateResponseDistances[7] = distance;
			}
			
//			direction 8 - -180�
			
			startX = x + (int)(distance * xInc[8]);
			startY = y + (int)(distance * yInc[8]);
			
			value = -1*image.getPixel(startX-5, startY-2)[0] +
			        -1*image.getPixel(startX-4, startY-2)[0] +
			        -1*image.getPixel(startX-3, startY-2)[0] +
			        -1*image.getPixel(startX-2, startY-2)[0] +
			        -1*image.getPixel(startX-1, startY-2)[0] +
			        -1*image.getPixel(startX  , startY-2)[0] +
			        
			        -2*image.getPixel(startX-5, startY-1)[0] +
			        -2*image.getPixel(startX-4, startY-1)[0] +
			        -2*image.getPixel(startX-3, startY-1)[0] +
			        -2*image.getPixel(startX-2, startY-1)[0] +
			        -2*image.getPixel(startX-1, startY-1)[0] +
			        -2*image.getPixel(startX  , startY-1)[0] +
			        
			         2*image.getPixel(startX-5, startY+1)[0] +
			         2*image.getPixel(startX-4, startY+1)[0] +
			         2*image.getPixel(startX-3, startY+1)[0] +
			         2*image.getPixel(startX-2, startY+1)[0] +
			         2*image.getPixel(startX-1, startY+1)[0] +
			         2*image.getPixel(startX  , startY+1)[0] +
			         
			           image.getPixel(startX-5, startY+2)[0] +
			           image.getPixel(startX-4, startY+2)[0] +
			           image.getPixel(startX-3, startY+2)[0] +
			           image.getPixel(startX-2, startY+2)[0] +
			           image.getPixel(startX-1, startY+2)[0] +
			           image.getPixel(startX  , startY+2)[0];
			
			if (value>rightEdgeMaxTemplateResponses[8])	{
				rightEdgeMaxTemplateResponses[8] = value;
				rightEdgeMaxTemplateResponseDistances[8] = distance;
			}
			
//			direction 9 - 157.5�
			
			startX = x + (int)(distance * xInc[9]);
			startY = y + (int)(distance * yInc[9]);
			
			value = -1*image.getPixel(startX-4, startY-4)[0] +
			
					-2*image.getPixel(startX-4, startY-3)[0] +
					-1*image.getPixel(startX-3, startY-3)[0] +
					-1*image.getPixel(startX-2, startY-3)[0] +
					-1*image.getPixel(startX-1, startY-3)[0] +
					
					-2*image.getPixel(startX-3, startY-2)[0] +
					-2*image.getPixel(startX-2, startY-2)[0] +
					-2*image.getPixel(startX-1, startY-2)[0] +
					-1*image.getPixel(startX  , startY-2)[0] +
					-1*image.getPixel(startX+1, startY-2)[0] +
					
					 2*image.getPixel(startX-5, startY-1)[0] +
					 2*image.getPixel(startX-4, startY-1)[0] +
					-2*image.getPixel(startX-1, startY-1)[0] +
					-2*image.getPixel(startX  , startY-1)[0] +
					
					   image.getPixel(startX-5, startY)[0] +
					   image.getPixel(startX-4, startY)[0] +
					 2*image.getPixel(startX-3, startY)[0] +
					 2*image.getPixel(startX-2, startY)[0] +
					 
					   image.getPixel(startX-4, startY+1)[0] +
					   image.getPixel(startX-3, startY+1)[0] +
					   image.getPixel(startX-2, startY+1)[0] +
					 2*image.getPixel(startX-1, startY+1)[0] +
					 2*image.getPixel(startX  , startY+1)[0] +
					 
					   image.getPixel(startX-1, startY+2)[0];
			
			if (value>rightEdgeMaxTemplateResponses[9])	{
				rightEdgeMaxTemplateResponses[9] = value;
				rightEdgeMaxTemplateResponseDistances[9] = distance;
			}
			
//			direction 10 - 135�
			
			startX = x + (int)(distance * xInc[10]);
			startY = y + (int)(distance * yInc[10]);
			
			value = -1*image.getPixel(startX-4, startY-6)[0] +
			
					-2*image.getPixel(startX-4, startY-5)[0] +
					-1*image.getPixel(startX-3, startY-5)[0] +
					
					   image.getPixel(startX-6, startY-4)[0] +
					 2*image.getPixel(startX-5, startY-4)[0] +
					-2*image.getPixel(startX-3, startY-4)[0] +
					-1*image.getPixel(startX-2, startY-4)[0] +
					
					   image.getPixel(startX-5, startY-3)[0] +
					 2*image.getPixel(startX-4, startY-3)[0] +
					-2*image.getPixel(startX-2, startY-3)[0] +
					-1*image.getPixel(startX-1, startY-3)[0] +
					
					   image.getPixel(startX-4, startY-2)[0] +
					 2*image.getPixel(startX-3, startY-2)[0] +
					-2*image.getPixel(startX-1, startY-2)[0] +
					-1*image.getPixel(startX  , startY-2)[0] +
					
					   image.getPixel(startX-3, startY-1)[0] +
					 2*image.getPixel(startX-2, startY-1)[0] +
					-2*image.getPixel(startX  , startY-1)[0] +
					-1*image.getPixel(startX-1, startY-1)[0] +
					
					   image.getPixel(startX-2, startY  )[0] +
					 2*image.getPixel(startX-1, startY  )[0] +
					-2*image.getPixel(startX+1, startY  )[0] +
					
					   image.getPixel(startX-1, startY+1)[0] +
					 2*image.getPixel(startX  , startY+1)[0];
			
			if (value>rightEdgeMaxTemplateResponses[10])	{
				rightEdgeMaxTemplateResponses[10] = value;
				rightEdgeMaxTemplateResponseDistances[10] = distance;
			}
			
//			 direction 11 -  112.5�
			
			startX = x + (int)(distance * xInc[11]);
			startY = y + (int)(distance * yInc[11]);
			
			value = -2*image.getPixel(startX-1, startY-5)[0] +
			        -1*image.getPixel(startX  , startY-5)[0] +
			        
			           image.getPixel(startX-4, startY-4)[0] +
			         2*image.getPixel(startX-3, startY-4)[0] +
			        -2*image.getPixel(startX-1, startY-4)[0] +
			        -1*image.getPixel(startX  , startY-4)[0] +
			        -1*image.getPixel(startX+1, startY-4)[0] +
			        
			           image.getPixel(startX-3, startY-3)[0] +
			         2*image.getPixel(startX-2, startY-3)[0] +
			        -2*image.getPixel(startX  , startY-3)[0] +
			        -1*image.getPixel(startX+1, startY-3)[0] +
			        
			           image.getPixel(startX-3, startY-2)[0] +
			         2*image.getPixel(startX-2, startY-2)[0] +
			        -2*image.getPixel(startX  , startY-2)[0] +
			        -1*image.getPixel(startX+1, startY-2)[0] +
			        
			           image.getPixel(startX-3, startY-1)[0] +
			         2*image.getPixel(startX-2, startY-1)[0] +
			         2*image.getPixel(startX-1, startY-1)[0] +
			        -2*image.getPixel(startX+1, startY-1)[0] +
			        -1*image.getPixel(startX+2, startY-1)[0] +
			        
			           image.getPixel(startX-2, startY  )[0] +
			         2*image.getPixel(startX-1, startY  )[0] +
			        -2*image.getPixel(startX+1, startY  )[0] +
			        
			           image.getPixel(startX-2, startY+1)[0];
			
			if (value>rightEdgeMaxTemplateResponses[11])	{
				rightEdgeMaxTemplateResponses[11] = value;
				rightEdgeMaxTemplateResponseDistances[11] = distance;
			}
			        
//			 direction 12 -  90�
			
			startX = x + (int)(distance * xInc[12]);
			startY = y + (int)(distance * yInc[12]);
			
			value =   image.getPixel(startX-2, startY-5)[0] +
			        2*image.getPixel(startX-1, startY-5)[0] +
			       -2*image.getPixel(startX+1, startY-5)[0] +
			       -1*image.getPixel(startX+2, startY-5)[0] +
			
			          image.getPixel(startX-2, startY-4)[0] +
			        2*image.getPixel(startX-1, startY-4)[0] +
			       -2*image.getPixel(startX+1, startY-4)[0] +
			       -1*image.getPixel(startX+2, startY-4)[0] +

  		          	  image.getPixel(startX-2, startY-3)[0] +
				    2*image.getPixel(startX-1, startY-3)[0] +
				   -2*image.getPixel(startX+1, startY-3)[0] +
				   -1*image.getPixel(startX+2, startY-3)[0] +
				   
 	          	      image.getPixel(startX-2, startY-2)[0] +
				    2*image.getPixel(startX-1, startY-2)[0] +
				   -2*image.getPixel(startX+1, startY-2)[0] +
				   -1*image.getPixel(startX+2, startY-2)[0] +
				   
				      image.getPixel(startX-2, startY-1)[0] +
				    2*image.getPixel(startX-1, startY-1)[0] +
				   -2*image.getPixel(startX+1, startY-1)[0] +
				   -1*image.getPixel(startX+2, startY-1)[0] +
				   
				      image.getPixel(startX-2, startY  )[0] +
				    2*image.getPixel(startX-1, startY  )[0] +
				   -2*image.getPixel(startX+1, startY  )[0] +
				   -1*image.getPixel(startX+2, startY  )[0];
			
			if (value>rightEdgeMaxTemplateResponses[12])	{
				rightEdgeMaxTemplateResponses[12] = value;
				rightEdgeMaxTemplateResponseDistances[12] = distance;
			}
			
//			 direction 13 - 67.5�
			
			startX = x + (int)(distance * xInc[13]);
			startY = y + (int)(distance * yInc[13]);
			
			value =   image.getPixel(startX  , startY-5)[0] +
					2*image.getPixel(startX+1, startY-5)[0] +
					
					  image.getPixel(startX-1, startY-4)[0] +
					  image.getPixel(startX  , startY-4)[0] +
					2*image.getPixel(startX+1, startY-4)[0] +
				   -2*image.getPixel(startX+3, startY-4)[0] +
				   -1*image.getPixel(startX+4, startY-4)[0] +
				   
				      image.getPixel(startX-1, startY-3)[0] +
					2*image.getPixel(startX  , startY-3)[0] +
				   -2*image.getPixel(startX+2, startY-3)[0] +
				   -1*image.getPixel(startX+3, startY-3)[0] +
				   
				      image.getPixel(startX-1, startY-2)[0] +
					2*image.getPixel(startX  , startY-2)[0] +
				   -2*image.getPixel(startX+2, startY-2)[0] +
				   -1*image.getPixel(startX+3, startY-2)[0] +
				   
				   	  image.getPixel(startX-2, startY-1)[0] +
					2*image.getPixel(startX-1, startY-1)[0] +
				   -2*image.getPixel(startX+1, startY-1)[0] +
				   -2*image.getPixel(startX+2, startY-1)[0] +
				   -1*image.getPixel(startX+3, startY-1)[0] +
				   
				    2*image.getPixel(startX-1, startY  )[0] +
				   -2*image.getPixel(startX+1, startY  )[0] +
				   -1*image.getPixel(startX+2, startY  )[0] +
				   
				   -1*image.getPixel(startX+2, startY+1)[0];
				  
			if (value>rightEdgeMaxTemplateResponses[13])	{
				rightEdgeMaxTemplateResponses[13] = value;
				rightEdgeMaxTemplateResponseDistances[13] = distance;
			}
			
//			direction 14 - 45�
			
			startX = x + (int)(distance * xInc[14]);
			startY = y + (int)(distance * yInc[14]);
			
			value =   image.getPixel(startX+4, startY-6)[0] +
			
					  image.getPixel(startX+3, startY-5)[0] +
					2*image.getPixel(startX+4, startY-5)[0] +
					
					  image.getPixel(startX+2, startY-4)[0] +
					2*image.getPixel(startX+3, startY-4)[0] +
				   -2*image.getPixel(startX+5, startY-4)[0] +
				   -1*image.getPixel(startX+6, startY-4)[0] +
				   
				   	  image.getPixel(startX+1, startY-3)[0] +
					2*image.getPixel(startX+2, startY-3)[0] +
				   -2*image.getPixel(startX+4, startY-3)[0] +
				   -1*image.getPixel(startX+5, startY-3)[0] +
				   
					  image.getPixel(startX  , startY-2)[0] +
					2*image.getPixel(startX+1, startY-2)[0] +
				   -2*image.getPixel(startX+3, startY-2)[0] +
				   -1*image.getPixel(startX+4, startY-2)[0] +
				   
				      image.getPixel(startX-1, startY-1)[0] +
					2*image.getPixel(startX  , startY-1)[0] +
				   -2*image.getPixel(startX+2, startY-1)[0] +
				   -1*image.getPixel(startX+3, startY-1)[0] +
				   
				    2*image.getPixel(startX-1, startY  )[0] +
				   -2*image.getPixel(startX+1, startY  )[0] +
				   -1*image.getPixel(startX+2, startY  )[0] +
				   
				   -2*image.getPixel(startX  , startY+1)[0] +
				   -1*image.getPixel(startX+1, startY+1)[0];
			
			if (value>rightEdgeMaxTemplateResponses[14])	{
				rightEdgeMaxTemplateResponses[14] = value;
				rightEdgeMaxTemplateResponseDistances[14] = distance;
			}
			
//			direction 15 - 22.5�
			
			startX = x + (int)(distance * xInc[15]);
			startY = y + (int)(distance * yInc[15]);
			
			value =   image.getPixel(startX+4, startY-4)[0] +
			
					  image.getPixel(startX+1, startY-3)[0] +
					  image.getPixel(startX+2, startY-3)[0] +
					  image.getPixel(startX+3, startY-3)[0] +
					2*image.getPixel(startX+4, startY-3)[0] +
					
					  image.getPixel(startX-1, startY-2)[0] +
					  image.getPixel(startX  , startY-2)[0] +
					2*image.getPixel(startX+1, startY-2)[0] +
					2*image.getPixel(startX+2, startY-2)[0] +
					2*image.getPixel(startX+3, startY-2)[0] +
					
					2*image.getPixel(startX  , startY-1)[0] +
					2*image.getPixel(startX+1, startY-1)[0] +
				   -2*image.getPixel(startX+4, startY-1)[0] +
				   -2*image.getPixel(startX+5, startY-1)[0] +
				   
				   -2*image.getPixel(startX+2, startY  )[0] +
				   -2*image.getPixel(startX+3, startY  )[0] +
				   -1*image.getPixel(startX+4, startY  )[0] +
				   -1*image.getPixel(startX+5, startY  )[0] +
				   
				   -2*image.getPixel(startX  , startY+1)[0] +
				   -2*image.getPixel(startX+1, startY+1)[0] +
				   -1*image.getPixel(startX+2, startY+1)[0] +
				   -1*image.getPixel(startX+3, startY+1)[0] +
				   -1*image.getPixel(startX+4, startY+1)[0] +
				   
				   -1*image.getPixel(startX+1, startY+2)[0];
			
			if (value>rightEdgeMaxTemplateResponses[15])	{
				rightEdgeMaxTemplateResponses[15] = value;
				rightEdgeMaxTemplateResponseDistances[15] = distance;
			}
		}
		
// left edge templates
		
		for (int distance=0; distance<getOptions().getMaxFilamentWidth()/2; distance++) {

			// direction 0 - 0�

			int startX = x + (int)(distance * (-1*xInc[0]));
			int startY = y + (int)(distance * (-1*yInc[0]));
			
			int value = 
			-1*image.getPixel(startX+0, startY-2)[0] + 
			-1*image.getPixel(startX+1, startY-2)[0] +
			-1*image.getPixel(startX+2, startY-2)[0] +
			-1*image.getPixel(startX+3, startY-2)[0] +
			-1*image.getPixel(startX+4, startY-2)[0] +
			-1*image.getPixel(startX+5, startY-2)[0] +

			-2*image.getPixel(startX+0, startY-1)[0] + 
			-2*image.getPixel(startX+1, startY-1)[0] +
			-2*image.getPixel(startX+2, startY-1)[0] +
			-2*image.getPixel(startX+3, startY-1)[0] +
			-2*image.getPixel(startX+4, startY-1)[0] +
			-2*image.getPixel(startX+5, startY-1)[0] +

			 2*image.getPixel(startX+0, startY+1)[0] + 
			 2*image.getPixel(startX+1, startY+1)[0] +
			 2*image.getPixel(startX+2, startY+1)[0] +
			 2*image.getPixel(startX+3, startY+1)[0] +
			 2*image.getPixel(startX+4, startY+1)[0] +
			 2*image.getPixel(startX+5, startY+1)[0] +

			 1*image.getPixel(startX+0, startY+2)[0] + 
			 1*image.getPixel(startX+1, startY+2)[0] +
			 1*image.getPixel(startX+2, startY+2)[0] +
			 1*image.getPixel(startX+3, startY+2)[0] +
			 1*image.getPixel(startX+4, startY+2)[0] +
			 1*image.getPixel(startX+5, startY+2)[0];
			
			if (value>leftEdgeMaxTemplateResponses[0])	{
				leftEdgeMaxTemplateResponses[0] = value;
				leftEdgeMaxTemplateResponseDistances[0] = distance;
			}	

			//		 direction 1 - -22.5�

			startX = x + (int)(distance * (-1*xInc[1]));
			startY = y + (int)(distance * (-1*yInc[1]));

			value = -1*image.getPixel(startX+1, startY-2)[0] + 

			 -2*image.getPixel(startX+0, startY-1)[0] +
			 -2*image.getPixel(startX+1, startY-1)[0] +
			 -1*image.getPixel(startX+2, startY-1)[0] +
			 -1*image.getPixel(startX+3, startY-1)[0] +
			 -1*image.getPixel(startX+4, startY-1)[0] +

			 -2*image.getPixel(startX+2, startY)[0] +
			 -2*image.getPixel(startX+3, startY)[0] +
			 -1*image.getPixel(startX+4, startY)[0] +
			 -1*image.getPixel(startX+5, startY)[0] +

			2*image.getPixel(startX+0, startY+1)[0] +
			2*image.getPixel(startX+1, startY+1)[0] +
			-2*image.getPixel(startX+4, startY+1)[0] +
			-2*image.getPixel(startX+5, startY+1)[0] +

			1*image.getPixel(startX-1, startY+2)[0] +
			1*image.getPixel(startX+0, startY+2)[0] +
			2*image.getPixel(startX+1, startY+2)[0] +
			2*image.getPixel(startX+2, startY+2)[0] +
			2*image.getPixel(startX+3, startY+2)[0] +

			1*image.getPixel(startX+1, startY+3)[0] +
			1*image.getPixel(startX+2, startY+3)[0] +
			1*image.getPixel(startX+3, startY+3)[0] +
			2*image.getPixel(startX+4, startY+3)[0] +

			1*image.getPixel(startX+4, startY+4)[0];

			if (value>leftEdgeMaxTemplateResponses[1])	{
				leftEdgeMaxTemplateResponses[1] = value;
				leftEdgeMaxTemplateResponseDistances[1] = distance;
			}
			
//			 direction 2 - -45�

			startX = x + (int)(distance * (-1*xInc[2]));
			startY = y + (int)(distance * (-1*yInc[2]));
			
			value = -2*image.getPixel(startX+0, startY-1)[0] +
					-1*image.getPixel(startX+1, startY-1)[0] +
				   
				    2*image.getPixel(startX-1, startY)[0] +
				    -2*image.getPixel(startX+1, startY)[0] +
				    -1*image.getPixel(startX+2, startY)[0] +
				      
				    1*image.getPixel(startX-1, startY+1)[0] +
				    2*image.getPixel(startX,   startY+1)[0] +
				   -2*image.getPixel(startX+2, startY+1)[0] +
				   -1*image.getPixel(startX+3, startY+1)[0] +
				      
				    1*image.getPixel(startX,   startY+2)[0] +
				    2*image.getPixel(startX+1, startY+2)[0] +
					-2*image.getPixel(startX+3, startY+2)[0] +
					-1*image.getPixel(startX+4, startY+2)[0] +  
				   
				    1*image.getPixel(startX+1, startY+3)[0] +
				    2*image.getPixel(startX+2, startY+3)[0] +
					-2*image.getPixel(startX+4, startY+3)[0] +
					-1*image.getPixel(startX+5, startY+3)[0] +
					  
				    1*image.getPixel(startX+2, startY+4)[0] +
				    2*image.getPixel(startX+3, startY+4)[0] +
				   -2*image.getPixel(startX+5, startY+4)[0] +
					-1*image.getPixel(startX+6, startY+4)[0] +
					  
				   1*image.getPixel(startX+3, startY+5)[0] +
				   2*image.getPixel(startX+4, startY+5)[0] +
				   
				   1*image.getPixel(startX+4, startY+6)[0];
			
			if (value>leftEdgeMaxTemplateResponses[2])	{
				leftEdgeMaxTemplateResponses[2] = value;
				leftEdgeMaxTemplateResponseDistances[2] = distance;
			}
			
//			 direction 3 - -67.5�
			
			startX = x + (int)(distance * (-1*xInc[3]));
			startY = y + (int)(distance * (-1*yInc[3]));
			
			value = -1*image.getPixel(startX+2, startY-1)[0] +
			
			     2*image.getPixel(startX-1, startY)[0] +
			     -2*image.getPixel(startX+1, startY)[0] +
			      -1* image.getPixel(startX+2, startY)[0] +
			        
			     1*image.getPixel(startX-2, startY+1)[0] +
			     2*image.getPixel(startX-1, startY+1)[0] +
			     -2*image.getPixel(startX+1, startY+1)[0] +
			     -2*image.getPixel(startX+2, startY+1)[0] +
			      -1* image.getPixel(startX+3, startY+1)[0] +
			     
			     1*image.getPixel(startX-1, startY+2)[0] +
				 2*image.getPixel(startX  , startY+2)[0] +
				 -2*image.getPixel(startX+2, startY+2)[0] +
				 -1*image.getPixel(startX+3, startY+2)[0] +
				 
				 1*image.getPixel(startX-1, startY+3)[0] +
			     2*image.getPixel(startX  , startY+3)[0] +
				  -2*image.getPixel(startX+2, startY+3)[0] +
				   -1* image.getPixel(startX+3, startY+3)[0] +
				  
				  1*image.getPixel(startX-1, startY+4)[0] +
				  1*image.getPixel(startX  , startY+4)[0] +
				  2*image.getPixel(startX+1, startY+4)[0] +
				  -2*image.getPixel(startX+3, startY+4)[0] +
				   -1*image.getPixel(startX+4, startY+4)[0] +
				     
				  1*image.getPixel(startX  , startY+5)[0] +
				  2*image.getPixel(startX+1, startY+5)[0];
			
			if (value>leftEdgeMaxTemplateResponses[3])	{
				leftEdgeMaxTemplateResponses[3] = value;
				leftEdgeMaxTemplateResponseDistances[3] = distance;
			}
			
//			 direction 4 - -90�
			
			startX = x + (int)(distance * (-1*xInc[4]));
			startY = y + (int)(distance * (-1*yInc[4]));
			
			value = 1*image.getPixel(startX-2, startY)[0] +
					2*image.getPixel(startX-1, startY)[0] +
					-2*image.getPixel(startX+1, startY)[0] +
					 -1*image.getPixel(startX+2, startY)[0] +
					 
					 1*image.getPixel(startX-2, startY+1)[0] +
					 2*image.getPixel(startX-1, startY+1)[0] +
					 -2*image.getPixel(startX+1, startY+1)[0] +
					  -1*image.getPixel(startX+2, startY+1)[0] +

				     1*image.getPixel(startX-2, startY+2)[0] +
					 2*image.getPixel(startX-1, startY+2)[0] +
					 -2*image.getPixel(startX+1, startY+2)[0] +
					  -1*image.getPixel(startX+2, startY+2)[0] +
					  
					 1*image.getPixel(startX-2, startY+3)[0] +
					 2*image.getPixel(startX-1, startY+3)[0] +
					 -2*image.getPixel(startX+1, startY+3)[0] +
					  -1*image.getPixel(startX+2, startY+3)[0] +
					  
					 1*image.getPixel(startX-2, startY+4)[0] +
					 2*image.getPixel(startX-1, startY+4)[0] +
					 -2*image.getPixel(startX+1, startY+4)[0] +
					  -1*image.getPixel(startX+2, startY+4)[0] +
					  
					 1*image.getPixel(startX-2, startY+5)[0] +
					 2*image.getPixel(startX-1, startY+5)[0] +
					 -2*image.getPixel(startX+1, startY+5)[0] +
					  -1*image.getPixel(startX+2, startY+5)[0];
			
			if (value>leftEdgeMaxTemplateResponses[4])	{
				leftEdgeMaxTemplateResponses[4] = value;
				leftEdgeMaxTemplateResponseDistances[4] = distance;
			}
			
//			 direction 5 - -112.5�
			
			startX = x + (int)(distance * (-1*xInc[5]));
			startY = y + (int)(distance * (-1*yInc[5]));
			
			value =  1*image.getPixel(startX-2, startY-1)[0] +
				    
			         1*image.getPixel(startX-2, startY)[0] +
			         2*image.getPixel(startX-1, startY)[0] +
			         -2*image.getPixel(startX+1, startY)[0] +
			         
			        1*image.getPixel(startX-3, startY+1)[0] +
			        2*image.getPixel(startX-2, startY+1)[0] +
			        2*image.getPixel(startX-1, startY+1)[0] +
			        -2*image.getPixel(startX+1, startY+1)[0] +
			        -1*image.getPixel(startX+2, startY+1)[0] +
			         
			        1*image.getPixel(startX-3, startY+2)[0] +
			        2*image.getPixel(startX-2, startY+2)[0] +
			        -2*image.getPixel(startX  , startY+2)[0] +
			        -1*image.getPixel(startX+1, startY+2)[0] +
			        
			        1*image.getPixel(startX-3, startY+3)[0] +
				    2*image.getPixel(startX-2, startY+3)[0] +
				    -2*image.getPixel(startX  , startY+3)[0] +
				    -1*image.getPixel(startX+1, startY+3)[0] +
				     
				    1*image.getPixel(startX-4, startY+4)[0] +
				    2*image.getPixel(startX-3, startY+4)[0] +
				    -2*image.getPixel(startX-1, startY+4)[0] +
				     -1*image.getPixel(startX  , startY+4)[0] +
				     -1*image.getPixel(startX+1, startY+4)[0] +
				       
				     -2*image.getPixel(startX-1, startY+5)[0] +
				     -1*image.getPixel(startX  , startY+5)[0];
			
			if (value>leftEdgeMaxTemplateResponses[5])	{
				leftEdgeMaxTemplateResponses[5] = value;
				leftEdgeMaxTemplateResponseDistances[5] = distance;
			}
			
//			 direction 6 - -135�
			
			startX = x + (int)(distance * (-1*xInc[6]));
			startY = y + (int)(distance * (-1*yInc[6]));
			
			value =  1*image.getPixel(startX-1, startY-1)[0] +
				     2*image.getPixel(startX  , startY-1)[0] +
				    
				     1*image.getPixel(startX-2, startY  )[0] +
				     2*image.getPixel(startX-1, startY  )[0] +
				     -2*image.getPixel(startX+1, startY  )[0] +
				     
				    1*image.getPixel(startX-3, startY+1)[0] +
				    2*image.getPixel(startX-2, startY+1)[0] +
				    -2*image.getPixel(startX  , startY+1)[0] +
				     -1*image.getPixel(startX+1, startY+1)[0] +
				     
				    1*image.getPixel(startX-4, startY+2)[0] +
				    2*image.getPixel(startX-3, startY+2)[0] +
				    -2*image.getPixel(startX-1, startY+2)[0] +
				     -1*image.getPixel(startX  , startY+2)[0] +
				     
				    1*image.getPixel(startX-5, startY+3)[0] +
				    2*image.getPixel(startX-4, startY+3)[0] +
				    -2*image.getPixel(startX-2, startY+3)[0] +
				     -1*image.getPixel(startX-1, startY+3)[0] +
				     
				    1*image.getPixel(startX-6, startY+4)[0] +
  				    2*image.getPixel(startX-5, startY+4)[0] +
					-2*image.getPixel(startX-3, startY+4)[0] +
					 -1*image.getPixel(startX-2, startY+4)[0] +
					 
					 -2*image.getPixel(startX-4, startY+5)[0] +
				      -1* image.getPixel(startX-3, startY+5)[0] +
				       
				       -1*image.getPixel(startX-4, startY+6)[0];

			if (value>leftEdgeMaxTemplateResponses[6])	{
				leftEdgeMaxTemplateResponses[6] = value;
				leftEdgeMaxTemplateResponseDistances[6] = distance;
			}
			
//			direction 7 - -157.5�
			
			startX = x + (int)(distance * (-1*xInc[7]));
			startY = y + (int)(distance * (-1*yInc[7]));
			
			value =  1*image.getPixel(startX-1, startY-2)[0] +
			
					 1*image.getPixel(startX-4, startY-1)[0] +
					 1*image.getPixel(startX-3, startY-1)[0] +
					 1*image.getPixel(startX-2, startY-1)[0] +
					 2*image.getPixel(startX-1, startY-1)[0] +
					 2*image.getPixel(startX  , startY-1)[0] +
					
					 1*image.getPixel(startX-5, startY  )[0] +
					 1*image.getPixel(startX-4, startY  )[0] +
					 2*image.getPixel(startX-3, startY  )[0] +
					 2*image.getPixel(startX-2, startY  )[0] +
					
					 2*image.getPixel(startX-5, startY+1)[0] +
					 2*image.getPixel(startX-4, startY+1)[0] +
					 -2*image.getPixel(startX-1, startY+1)[0] +
					 -2*image.getPixel(startX  , startY+1)[0] +
					 
					 -2*image.getPixel(startX-3, startY+2)[0] +
				     -2*image.getPixel(startX-2, startY+2)[0] +
					 -2*image.getPixel(startX-1, startY+2)[0] +
					  -1*image.getPixel(startX  , startY+2)[0] +
					   -1*image.getPixel(startX+1, startY+2)[0] +
					   
					 -2*image.getPixel(startX-4, startY+3)[0] +
					 -1*image.getPixel(startX-3, startY+3)[0] +
					  -1*image.getPixel(startX-2, startY+3)[0] +
					   -1*image.getPixel(startX-1, startY+3)[0] +
					   
					   -1*image.getPixel(startX-4, startY+4)[0];
			
			if (value>leftEdgeMaxTemplateResponses[7])	{
				leftEdgeMaxTemplateResponses[7] = value;
				leftEdgeMaxTemplateResponseDistances[7] = distance;
			}
			
//			direction 8 - -180�
			
			startX = x + (int)(distance * (-1*xInc[8]));
			startY = y + (int)(distance * (-1*yInc[8]));
			
			value = 1*image.getPixel(startX-5, startY-2)[0] +
			        1*image.getPixel(startX-4, startY-2)[0] +
			        1*image.getPixel(startX-3, startY-2)[0] +
			        1*image.getPixel(startX-2, startY-2)[0] +
			        1*image.getPixel(startX-1, startY-2)[0] +
			        1*image.getPixel(startX  , startY-2)[0] +
			        
			        2*image.getPixel(startX-5, startY-1)[0] +
			        2*image.getPixel(startX-4, startY-1)[0] +
			        2*image.getPixel(startX-3, startY-1)[0] +
			        2*image.getPixel(startX-2, startY-1)[0] +
			        2*image.getPixel(startX-1, startY-1)[0] +
			        2*image.getPixel(startX  , startY-1)[0] +
			        
			         -2*image.getPixel(startX-5, startY+1)[0] +
			         -2*image.getPixel(startX-4, startY+1)[0] +
			         -2*image.getPixel(startX-3, startY+1)[0] +
			         -2*image.getPixel(startX-2, startY+1)[0] +
			         -2*image.getPixel(startX-1, startY+1)[0] +
			         -2*image.getPixel(startX  , startY+1)[0] +
			         
			          -1*image.getPixel(startX-5, startY+2)[0] +
			          -1*image.getPixel(startX-4, startY+2)[0] +
			          -1*image.getPixel(startX-3, startY+2)[0] +
			          -1*image.getPixel(startX-2, startY+2)[0] +
			          -1*image.getPixel(startX-1, startY+2)[0] +
			          -1*image.getPixel(startX  , startY+2)[0];
			
			if (value>leftEdgeMaxTemplateResponses[8])	{
				leftEdgeMaxTemplateResponses[8] = value;
				leftEdgeMaxTemplateResponseDistances[8] = distance;
			}
			
//			direction 9 - 157.5�
			
			startX = x + (int)(distance * (-1*xInc[9]));
			startY = y + (int)(distance * (-1*yInc[9]));
			
			value =  1*image.getPixel(startX-4, startY-4)[0] +
			
					 2*image.getPixel(startX-4, startY-3)[0] +
					 1*image.getPixel(startX-3, startY-3)[0] +
					 1*image.getPixel(startX-2, startY-3)[0] +
					 1*image.getPixel(startX-1, startY-3)[0] +
					
					 2*image.getPixel(startX-3, startY-2)[0] +
					 2*image.getPixel(startX-2, startY-2)[0] +
					 2*image.getPixel(startX-1, startY-2)[0] +
					 1*image.getPixel(startX  , startY-2)[0] +
					 1*image.getPixel(startX+1, startY-2)[0] +
					
					 -2*image.getPixel(startX-5, startY-1)[0] +
					 -2*image.getPixel(startX-4, startY-1)[0] +
					2*image.getPixel(startX-1, startY-1)[0] +
					2*image.getPixel(startX  , startY-1)[0] +
					
					  -1*image.getPixel(startX-5, startY)[0] +
					  -1*image.getPixel(startX-4, startY)[0] +
					 -2*image.getPixel(startX-3, startY)[0] +
					 -2*image.getPixel(startX-2, startY)[0] +
					 
					  -1*image.getPixel(startX-4, startY+1)[0] +
					  -1*image.getPixel(startX-3, startY+1)[0] +
					  -1*image.getPixel(startX-2, startY+1)[0] +
					 -2*image.getPixel(startX-1, startY+1)[0] +
					 -2*image.getPixel(startX  , startY+1)[0] +
					 
					   -1*image.getPixel(startX-1, startY+2)[0];
			
			if (value>leftEdgeMaxTemplateResponses[9])	{
				leftEdgeMaxTemplateResponses[9] = value;
				leftEdgeMaxTemplateResponseDistances[9] = distance;
			}
			
//			direction 10 - 135�
			
			startX = x + (int)(distance * (-1*xInc[10]));
			startY = y + (int)(distance * (-1*yInc[10]));
			
			value =  1*image.getPixel(startX-4, startY-6)[0] +
			
					 2*image.getPixel(startX-4, startY-5)[0] +
					 1*image.getPixel(startX-3, startY-5)[0] +
					
					 -1*image.getPixel(startX-6, startY-4)[0] +
					 -2*image.getPixel(startX-5, startY-4)[0] +
					 2*image.getPixel(startX-3, startY-4)[0] +
					 1*image.getPixel(startX-2, startY-4)[0] +
					
					 -1*image.getPixel(startX-5, startY-3)[0] +
					 -2*image.getPixel(startX-4, startY-3)[0] +
					 2*image.getPixel(startX-2, startY-3)[0] +
					 1*image.getPixel(startX-1, startY-3)[0] +
					
					 -1*image.getPixel(startX-4, startY-2)[0] +
					 -2*image.getPixel(startX-3, startY-2)[0] +
					 2*image.getPixel(startX-1, startY-2)[0] +
					 1*image.getPixel(startX  , startY-2)[0] +
					
					  -1*image.getPixel(startX-3, startY-1)[0] +
					 -2*image.getPixel(startX-2, startY-1)[0] +
					 2*image.getPixel(startX  , startY-1)[0] +
					 1*image.getPixel(startX-1, startY-1)[0] +
					
					 -1*image.getPixel(startX-2, startY  )[0] +
					 -2*image.getPixel(startX-1, startY  )[0] +
					 2*image.getPixel(startX+1, startY  )[0] +
					
					  -1*image.getPixel(startX-1, startY+1)[0] +
					 -2*image.getPixel(startX  , startY+1)[0];
			
			if (value>leftEdgeMaxTemplateResponses[10])	{
				leftEdgeMaxTemplateResponses[10] = value;
				leftEdgeMaxTemplateResponseDistances[10] = distance;
			}
			
//			 direction 11 -  112.5�
			
			startX = x + (int)(distance * (-1*xInc[11]));
			startY = y + (int)(distance * (-1*yInc[11]));
			
			value =  2*image.getPixel(startX-1, startY-5)[0] +
			         1*image.getPixel(startX  , startY-5)[0] +
			        
			         -1*image.getPixel(startX-4, startY-4)[0] +
			         -2*image.getPixel(startX-3, startY-4)[0] +
			         2*image.getPixel(startX-1, startY-4)[0] +
			         1*image.getPixel(startX  , startY-4)[0] +
			         1*image.getPixel(startX+1, startY-4)[0] +
			        
			         -1*image.getPixel(startX-3, startY-3)[0] +
			         -2*image.getPixel(startX-2, startY-3)[0] +
			         2*image.getPixel(startX  , startY-3)[0] +
			         1*image.getPixel(startX+1, startY-3)[0] +
			        
			         -1*image.getPixel(startX-3, startY-2)[0] +
			         -2*image.getPixel(startX-2, startY-2)[0] +
			         2*image.getPixel(startX  , startY-2)[0] +
			         1*image.getPixel(startX+1, startY-2)[0] +
			        
			          -1*image.getPixel(startX-3, startY-1)[0] +
			         -2*image.getPixel(startX-2, startY-1)[0] +
			         -2*image.getPixel(startX-1, startY-1)[0] +
			         2*image.getPixel(startX+1, startY-1)[0] +
			         1*image.getPixel(startX+2, startY-1)[0] +
			        
			         -1*image.getPixel(startX-2, startY  )[0] +
			         -2*image.getPixel(startX-1, startY  )[0] +
			         2*image.getPixel(startX+1, startY  )[0] +
			        
			         -1*image.getPixel(startX-2, startY+1)[0];
			
			if (value>leftEdgeMaxTemplateResponses[11])	{
				leftEdgeMaxTemplateResponses[11] = value;
				leftEdgeMaxTemplateResponseDistances[11] = distance;
			}
			        
//			 direction 12 -  90�
			
			startX = x + (int)(distance * (-1*xInc[12]));
			startY = y + (int)(distance * (-1*yInc[12]));
			
			value =   -1*image.getPixel(startX-2, startY-5)[0] +
			        -2*image.getPixel(startX-1, startY-5)[0] +
			        2*image.getPixel(startX+1, startY-5)[0] +
			        1*image.getPixel(startX+2, startY-5)[0] +
			
			        -1*image.getPixel(startX-2, startY-4)[0] +
			        -2*image.getPixel(startX-1, startY-4)[0] +
			        2*image.getPixel(startX+1, startY-4)[0] +
			        1*image.getPixel(startX+2, startY-4)[0] +

  		          	-1*image.getPixel(startX-2, startY-3)[0] +
				    -2*image.getPixel(startX-1, startY-3)[0] +
				    2*image.getPixel(startX+1, startY-3)[0] +
				    1*image.getPixel(startX+2, startY-3)[0] +
				   
 	          	    -1*image.getPixel(startX-2, startY-2)[0] +
				    -2*image.getPixel(startX-1, startY-2)[0] +
				    2*image.getPixel(startX+1, startY-2)[0] +
				    1*image.getPixel(startX+2, startY-2)[0] +
				   
				    -1*image.getPixel(startX-2, startY-1)[0] +
				    -2*image.getPixel(startX-1, startY-1)[0] +
				     2*image.getPixel(startX+1, startY-1)[0] +
				     1*image.getPixel(startX+2, startY-1)[0] +
				   
				     -1*image.getPixel(startX-2, startY  )[0] +
				    -2*image.getPixel(startX-1, startY  )[0] +
				    2*image.getPixel(startX+1, startY  )[0] +
				    1*image.getPixel(startX+2, startY  )[0];
			
			if (value>leftEdgeMaxTemplateResponses[12])	{
				leftEdgeMaxTemplateResponses[12] = value;
				leftEdgeMaxTemplateResponseDistances[12] = distance;
			}
			
//			 direction 13 - 67.5�
			
			startX = x + (int)(distance * (-1*xInc[13]));
			startY = y + (int)(distance * (-1*yInc[13]));
			
			value =   -1*image.getPixel(startX  , startY-5)[0] +
					-2*image.getPixel(startX+1, startY-5)[0] +
					
					 -1*image.getPixel(startX-1, startY-4)[0] +
					 -1*image.getPixel(startX  , startY-4)[0] +
					-2*image.getPixel(startX+1, startY-4)[0] +
				    2*image.getPixel(startX+3, startY-4)[0] +
				    1*image.getPixel(startX+4, startY-4)[0] +
				   
				     -1* image.getPixel(startX-1, startY-3)[0] +
					 -2* image.getPixel(startX  , startY-3)[0] +
				    2*image.getPixel(startX+2, startY-3)[0] +
				    1*image.getPixel(startX+3, startY-3)[0] +
				   
				     -1* image.getPixel(startX-1, startY-2)[0] +
					 -2* image.getPixel(startX  , startY-2)[0] +
				   2*image.getPixel(startX+2, startY-2)[0] +
				   1*image.getPixel(startX+3, startY-2)[0] +
				   
				   -1*image.getPixel(startX-2, startY-1)[0] +
					-2*image.getPixel(startX-1, startY-1)[0] +
				   2*image.getPixel(startX+1, startY-1)[0] +
				   2*image.getPixel(startX+2, startY-1)[0] +
				   1*image.getPixel(startX+3, startY-1)[0] +
				   
				   -2*image.getPixel(startX-1, startY  )[0] +
				   2*image.getPixel(startX+1, startY  )[0] +
				   1*image.getPixel(startX+2, startY  )[0] +
				   
				   1*image.getPixel(startX+2, startY+1)[0];
				  
			if (value>leftEdgeMaxTemplateResponses[13])	{
				leftEdgeMaxTemplateResponses[13] = value;
				leftEdgeMaxTemplateResponseDistances[13] = distance;
			}
			
//			direction 14 - 45�
			
			startX = x + (int)(distance * (-1*xInc[14]));
			startY = y + (int)(distance * (-1*yInc[14]));
			
			value =   -1*image.getPixel(startX+4, startY-6)[0] +
			
					  -1*image.getPixel(startX+3, startY-5)[0] +
					-2*image.getPixel(startX+4, startY-5)[0] +
					
					 -1* image.getPixel(startX+2, startY-4)[0] +
					-2*image.getPixel(startX+3, startY-4)[0] +
				    2*image.getPixel(startX+5, startY-4)[0] +
				    1*image.getPixel(startX+6, startY-4)[0] +
				   
				   	-1*image.getPixel(startX+1, startY-3)[0] +
					-2*image.getPixel(startX+2, startY-3)[0] +
				   2*image.getPixel(startX+4, startY-3)[0] +
				   1*image.getPixel(startX+5, startY-3)[0] +
				   
					-1*image.getPixel(startX  , startY-2)[0] +
					-2*image.getPixel(startX+1, startY-2)[0] +
				    2*image.getPixel(startX+3, startY-2)[0] +
				    1*image.getPixel(startX+4, startY-2)[0] +
				   
				    -1*image.getPixel(startX-1, startY-1)[0] +
					-2*image.getPixel(startX  , startY-1)[0] +
				    2*image.getPixel(startX+2, startY-1)[0] +
				    1*image.getPixel(startX+3, startY-1)[0] +
				   
				    -2*image.getPixel(startX-1, startY  )[0] +
				   2*image.getPixel(startX+1, startY  )[0] +
				   1*image.getPixel(startX+2, startY  )[0] +
				   
				   2*image.getPixel(startX  , startY+1)[0] +
				   1*image.getPixel(startX+1, startY+1)[0];
			
			if (value>leftEdgeMaxTemplateResponses[14])	{
				leftEdgeMaxTemplateResponses[14] = value;
				leftEdgeMaxTemplateResponseDistances[14] = distance;
			}
			
//			direction 15 - 22.5�
			
			startX = x + (int)(distance * (-1*xInc[15]));
			startY = y + (int)(distance * (-1*yInc[15]));
			
			value =   -1*image.getPixel(startX+4, startY-4)[0] +
			
					  -1*image.getPixel(startX+1, startY-3)[0] +
					  -1*image.getPixel(startX+2, startY-3)[0] +
					  -1*image.getPixel(startX+3, startY-3)[0] +
					-2*image.getPixel(startX+4, startY-3)[0] +
					
					 -1*image.getPixel(startX-1, startY-2)[0] +
					 -1*image.getPixel(startX  , startY-2)[0] +
					-2*image.getPixel(startX+1, startY-2)[0] +
					-2*image.getPixel(startX+2, startY-2)[0] +
					-2*image.getPixel(startX+3, startY-2)[0] +
					
					-2*image.getPixel(startX  , startY-1)[0] +
					-2*image.getPixel(startX+1, startY-1)[0] +
				    2*image.getPixel(startX+4, startY-1)[0] +
				    2*image.getPixel(startX+5, startY-1)[0] +
				   
				    2*image.getPixel(startX+2, startY  )[0] +
				    2*image.getPixel(startX+3, startY  )[0] +
				    1*image.getPixel(startX+4, startY  )[0] +
				    1*image.getPixel(startX+5, startY  )[0] +
				   
				    2*image.getPixel(startX  , startY+1)[0] +
				    2*image.getPixel(startX+1, startY+1)[0] +
				    1*image.getPixel(startX+2, startY+1)[0] +
				    1*image.getPixel(startX+3, startY+1)[0] +
				    1*image.getPixel(startX+4, startY+1)[0] +
				   
				    1*image.getPixel(startX+1, startY+2)[0];
			
			if (value>leftEdgeMaxTemplateResponses[15])	{
				leftEdgeMaxTemplateResponses[15] = value;
				leftEdgeMaxTemplateResponseDistances[15] = distance;
			}
		}
	}

	public int getStepSize() {
		return getOptions().getStepSize();
	}

	public void setStepSize(int stepSize) {
		getOptions().setStepSize(stepSize);
	}

	public SeedPointsFinder getFinder() {
		return finder;
	}

	public void setFinder(SeedPointsFinder finder) {
		this.finder = finder;
	}

	public double getMinTracingLength() {
		return getOptions().getMinTracingLength();
	}

	public void setMinTracingLength(float minTracingLength) {
		getOptions().setMinTracingLength(minTracingLength);
	}
	
	
	public static String one() {
		System.out.println("one");
		return "ok";
	}
	
	public static String traceFrom(String x, String y, String maxFilamentWidth, String minTracingLength, String stepSize) {
		getOptions().setMaxFilamentWidth(Integer.parseInt(maxFilamentWidth));
		getOptions().setMinTracingLength(Float.parseFloat(minTracingLength));
		getOptions().setStepSize(Integer.parseInt(stepSize));
		int xStart = Integer.valueOf(x);
		int yStart = Integer.valueOf(y);
		ImagePlus image = IJ.getImage();
		Duplicator duplicator = new Duplicator();
		ImagePlus img2 = duplicator.run(image);
		img2.show();
		WindowManager.setCurrentWindow(img2.getWindow());
		FilamentTracer tracer = new FilamentTracer(img2);
		Tracing tracing = tracer.traceFrom(xStart, yStart);
		RoiManager.getInstance().setVisible(true);
		RoiManager.getInstance().addRoi(tracing.getCenterPolygonRoi());
		RoiManager.getInstance().addRoi(tracing.getLeftEdgePolygonRoi());
		RoiManager.getInstance().addRoi(tracing.getRightEdgePolygonRoi());
		for (int i=0; i<3; i++) {
			RoiManager.getInstance().select(i);
			IJ.run("Interpolate", "interval=1 smooth adjust");
			RoiManager.getInstance().runCommand(img2, "Update");
		}
		img2.getWindow().close();
		WindowManager.setCurrentWindow(image.getWindow());
		RoiManager.getInstance().runCommand(image,"Show None");
		RoiManager.getInstance().runCommand(image,"Show All");
		return "";
	}
	
	public static TreeTracerOptions getOptions() {
		if (options == null) options = new TreeTracerOptions();
		return options;
	}
}

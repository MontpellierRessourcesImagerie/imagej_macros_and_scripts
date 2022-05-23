package roi;

import java.awt.Point;
import java.awt.Polygon;
import ij.IJ;
import ij.ImagePlus;
import ij.gui.Line;
import ij.gui.PointRoi;
import ij.gui.PolygonRoi;
import ij.gui.Roi;
import ij.plugin.frame.RoiManager;
import ij.process.ImageProcessor;

public class RoiConverter {
	enum DIRECTION {UP, DOWN, STRAIGHT}; 
	private Roi roi;
	private int indexOfGlobalYMin;
	private int indexOfGlobalYMax;
	private int tmpIndex;
	private int endIndex;
	private int startIndex;
	private boolean done;
	private boolean isMinimum;
	private boolean isMaximum;

	public static String addVerticalLinesToRoiManager() {
		new RoiManager();
		ImagePlus image = IJ.getImage();
		if (image==null) return "";
		Roi oldRoi = IJ.getImage().getRoi();
		if (oldRoi==null) return "";
		ImageProcessor processor = image.getProcessor();
		Polygon polygon = oldRoi.getPolygon();
		for (int i=0; i<polygon.npoints; i++) {
			int xStart = polygon.xpoints[i];
			int yStart = polygon.ypoints[i];
			int yEnd = yStart;
			boolean startFound = false;
			float value = 0;
			while(value>0 || !startFound) {
				value = processor.getPixel(xStart, yEnd);
				if (value>0) startFound = true;
				yEnd--;
			}
			yEnd++;
			yEnd++;
			Line line = new Line(xStart, yStart, xStart, yEnd);
			RoiManager.getInstance().addRoi(line);
		}
		return "";
	}
	
	public static void replaceRoiWithFreelineRoi() {
		ImagePlus image = IJ.getImage();
		if (image==null) return;
		Roi oldRoi = IJ.getImage().getRoi();
		if (oldRoi==null) return;
		Roi newRoi = new RoiConverter(oldRoi).getRoiAsFreelineSelection();
		image.setRoi(newRoi);
		image.updateAndDraw();
	}
	
	public static void replaceRoiWithPointSelectionOfExtrema(int radius) {
		ImagePlus image = IJ.getImage();
		if (image==null) return;
		Roi oldRoi = IJ.getImage().getRoi();
		if (oldRoi==null) return;
		Roi newRoi = new RoiConverter(oldRoi).getPointSelectionOfExtrema(radius);
		image.setRoi(newRoi);
		image.updateAndDraw();
	}
	
	public RoiConverter(Roi roi) {
		this.roi = roi;
	}

	/**
	 * Answer the extrema, with the given minimum radius, of the roi as
	 * a point-selection. 
	 * 
	 * @return  a point selection containing the extrema of the roi
	 */
	public Roi getPointSelectionOfExtrema(int radius) {
		Polygon resultPolygon = new Polygon();
		PointRoi pointRoi = null;
		Polygon polygon = this.roi.getPolygon();
		DIRECTION lastDirection = DIRECTION.STRAIGHT;
		DIRECTION currentDirection;
		for (int i=0; i<polygon.npoints-1; i++) {
			currentDirection = DIRECTION.STRAIGHT;
			if (polygon.ypoints[i+1]>polygon.ypoints[i]) currentDirection = DIRECTION.UP;
			if (polygon.ypoints[i+1]<polygon.ypoints[i]) currentDirection = DIRECTION.DOWN;
			isMinimum =  currentDirection==DIRECTION.UP && lastDirection==DIRECTION.DOWN;
			isMaximum = currentDirection==DIRECTION.DOWN && lastDirection==DIRECTION.UP; 
			if (isMinimum || isMaximum) {
						Point newPoint = this.adjustToMiddleOfPlateau(polygon, i);
						if(radius<=0 || this.hasAtLeastMinRadius(newPoint, polygon, i ,radius))
							resultPolygon.addPoint(newPoint.x, newPoint.y);
			}
			if (!(lastDirection!=DIRECTION.STRAIGHT && currentDirection==DIRECTION.STRAIGHT)) lastDirection = currentDirection;	
		}
		pointRoi = new PointRoi(resultPolygon);
		return pointRoi;
	}

	/**
	 * Convert the roi into a free-line roi. In the case of an area roi
	 * the line goes from the minimal y at the minimal x position to the minimal 
	 * y at the maximal x position.
	 */
	public Roi getRoiAsFreelineSelection() {
		Roi resultRoi = null;
		Polygon polygon = roi.getPolygon();	
		Point startAndEndIndex = this.getStartAndEndIndexAsPoint(polygon);
		startIndex = startAndEndIndex.x;
		endIndex = startAndEndIndex.y;
		tmpIndex = -1;
		int[] xPoints = null;
		int[] yPoints = null;

		if (startIndex==endIndex) return new PointRoi(polygon.xpoints[startIndex], polygon.ypoints[startIndex]);
		
		this.checkAndSwapIndices();
		
		if (startIndex<endIndex) {
			xPoints = new int[(endIndex-startIndex)+1];
			yPoints = new int[(endIndex-startIndex)+1];
			for (int i=startIndex; i<=endIndex; i++) {
				xPoints[i-startIndex] = polygon.xpoints[i];
				yPoints[i-startIndex] = polygon.ypoints[i];
			}
		} else { // startIndex > endIndex
				xPoints = new int[(endIndex+1) + (polygon.npoints - startIndex)];
				yPoints = new int[(endIndex+1) + (polygon.npoints - startIndex)];
				for (int i=startIndex; i<polygon.npoints;i++) {
					xPoints[i-startIndex] = polygon.xpoints[i];
					yPoints[i-startIndex] = polygon.ypoints[i];
				}
				for (int i=0; i<=endIndex; i++) {
					xPoints[i+(polygon.npoints-startIndex)] = polygon.xpoints[i];
					yPoints[i+(polygon.npoints-startIndex)] = polygon.ypoints[i];
				}
		}
		resultRoi = new PolygonRoi(xPoints, yPoints, xPoints.length, Roi.FREELINE);
		return resultRoi;
	}

	private boolean hasAtLeastMinRadius(Point extremum, Polygon polygon, int index, int minHeight) {
		if (isMinimum) {
			int startIndex=index;
			while(startIndex>0 && polygon.xpoints[startIndex]>extremum.x - minHeight){
				if (polygon.ypoints[startIndex]<extremum.y) return false;
				startIndex--;
			}
			startIndex=index;
			while(startIndex<polygon.npoints && polygon.xpoints[startIndex]<extremum.x + minHeight){
				if (polygon.ypoints[startIndex]<extremum.y) return false;
				startIndex++;
			}
		}
		if (isMaximum) {
			int startIndex=index;
			while(startIndex>0 && polygon.xpoints[startIndex]>extremum.x - minHeight){
				if (polygon.ypoints[startIndex]>extremum.y) return false;
				startIndex--;
			}
			startIndex=index;
			while(startIndex<polygon.npoints && polygon.xpoints[startIndex]<extremum.x + minHeight){
				if (polygon.ypoints[startIndex]>extremum.y) return false;
				startIndex++;
			}

		}
		return true;
	}

	private Point adjustToMiddleOfPlateau(Polygon polygon, int index) {
		int startIndex=index;
		while(polygon.ypoints[startIndex]==polygon.ypoints[index]) startIndex--;
		startIndex++;
		int endIndex = index;
		while(polygon.ypoints[endIndex]==polygon.ypoints[index]) endIndex++;
		endIndex--;
		int x = (int) (polygon.xpoints[startIndex] + Math.floor((polygon.xpoints[endIndex] - polygon.xpoints[startIndex]) / 2.0f));
		return new Point(x, polygon.ypoints[index]);
	}
	
	private void checkAndSwapIndices() {
		done = false;
		if (startIndex<endIndex && (indexOfGlobalYMin<startIndex || indexOfGlobalYMin>endIndex )) {
			swapStartAndEndIndex();
			done = true;
		} 
		if (!done && startIndex>endIndex && (indexOfGlobalYMin<startIndex && indexOfGlobalYMin>endIndex )) {
			swapStartAndEndIndex();
			done = true;
		}
		if (!done && startIndex<endIndex && (indexOfGlobalYMax>startIndex && indexOfGlobalYMax<endIndex )) {
			swapStartAndEndIndex();
			done = true;
		}
		if (!done && startIndex>endIndex && (indexOfGlobalYMax>startIndex || indexOfGlobalYMax<endIndex )) {
			swapStartAndEndIndex();
			done = true;
		}
	}

	private void swapStartAndEndIndex() {
		tmpIndex = startIndex;
		startIndex = endIndex;
		endIndex = tmpIndex;
	}

	private Point getStartAndEndIndexAsPoint(Polygon polygon) {
		int xMin = Integer.MAX_VALUE;
		int xMax = 0;
		int yMinLeft = Integer.MAX_VALUE;
		int yMinRight = Integer.MAX_VALUE;
		int startIndex=0;
		int endIndex=0;
		indexOfGlobalYMin = -1;
		indexOfGlobalYMax = -1;
		int globalYMin = Integer.MAX_VALUE;
		int globalYMax = 0;
		for (int i=0; i< polygon.npoints; i++) {
			int x = polygon.xpoints[i];
			int y = polygon.ypoints[i];
			if (x<xMin) xMin = x;
			if (x>xMax) xMax = x;
			if (y<globalYMin) {
				globalYMin = y;
				indexOfGlobalYMin = i;
			}
			if (y>globalYMax) {
				globalYMax = y;
				indexOfGlobalYMax = i;
			}
		}
		for (int i=0; i< polygon.npoints; i++) {
			int x = polygon.xpoints[i];
			int y = polygon.ypoints[i];
			if (x==xMin && y<yMinLeft) {
				startIndex = i;
				yMinLeft = y;
			}
			if (x==xMax && y<yMinRight) {
				yMinRight = y;
				endIndex = i;
			}
		}
		return new Point(startIndex, endIndex);
	}
}


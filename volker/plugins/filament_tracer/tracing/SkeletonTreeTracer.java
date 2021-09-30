package tracing;

import java.awt.Point;
import java.util.Vector;

import ij.ImagePlus;

public class SkeletonTreeTracer {
	protected ImagePlus image;
	protected Tree tree;
	byte[] data;
	protected int width;
	protected int height;
	
	protected Vector<Point> endPoints;
	protected Vector<Point> branchingPoints;
	protected Point startingPoint;
	protected Point endPoint;
	
	protected byte[] alreadyTraced;
	
	public SkeletonTreeTracer(ImagePlus image) {
		this.image = image;
		data = (byte[]) image.getProcessor().getPixels();
		this.width = image.getWidth();
		this.height = image.getHeight();
	}
	
	public void run() {
		alreadyTraced = new byte[width*height];
		endPoints = new Vector<Point>();
		branchingPoints = new Vector<Point>();
		endPoint = this.findLowestPoint();
		if (endPoint.x==-1) return;
		classifyPoint(endPoint);
	}
	
	public void classifyPoint(Point point) {
		int count = countNeightbors(point);
		if (count==1) endPoints.add(point);
		if (count>2) branchingPoints.add(point); 
		alreadyTraced[point.y*width+point.x] = 1;
		
		int startX = Math.max(point.x-1, 0);
		int endX = Math.min(point.x+1, width-1);
		int startY = Math.max(point.y-1, 0);
		int endY = Math.min(point.y+1, height-1);
		for (int x=startX; x<=endX; x++) {
			for (int y=startY; y<=endY; y++) {
				if (((data[y*width+x]&0xff)>0) && ((alreadyTraced[y*width+x]&0xff)!=1)) {
					classifyPoint(new Point(x,y));
				}
			}
		}
	}

	protected int countNeightbors(Point point) {
		int startX = Math.max(point.x-1, 0);
		int endX = Math.min(point.x+1, width-1);
		int startY = Math.max(point.y-1, 0);
		int endY = Math.min(point.y+1, height-1);
		int count=0;
		for (int x=startX; x<=endX; x++) {
			for (int y=startY; y<=endY; y++) {
				if (x==point.x && y==point.y) continue;
				if ((data[y*width+x]&0xff)>0) count++;
			}	
		}
		return count;
	}

	protected Point findLowestPoint() {
		Point result = new Point(-1,-1);
		boolean found = false;
		int x=width,y=height;
		for (y=height-1; y>=0; y--) {
			if (found) break;
			for (x=width-1; x>=0; x--) {
				if ((data[y*width+x]&0xff)>0) {
					found = true;
					break;
				}
			}
		}
		if (!found) return result;
		int x2 = x-1;
		while((data[y*width+x2]&0xff)>0) {
			x2--;
		}
		x = x + ((x2-x) / 2);
		result.x = x;
		result.y = y;
		return result;
	}

	public Vector<Point> getEndPoints() {
		return endPoints;
	}

	public void setEndPoints(Vector<Point> endPoints) {
		this.endPoints = endPoints;
	}

	public Vector<Point> getBranchingPoints() {
		return branchingPoints;
	}

	public void setBranchingPoints(Vector<Point> branchingPoints) {
		this.branchingPoints = branchingPoints;
	}
	
}

package tracing;

import ij.IJ;
import ij.ImagePlus;
import ij.gui.PolygonRoi;
import ij.gui.Roi;
import ij.process.ImageStatistics;

import java.awt.Color;
import java.awt.Graphics;
import java.awt.Point;
import java.awt.Polygon;
import java.awt.Rectangle;
import java.awt.geom.Line2D;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Vector;

public class Tracing {
	public ArrayList<Point> center;	
	public ArrayList<Point> leftEdge;
	public ArrayList<Point> rightEdge;
	public Color color;
	
	public Tracing() {
		center = new ArrayList<Point>();
		leftEdge = new ArrayList<Point>();
		rightEdge = new ArrayList<Point>();
		color = Color.GREEN;
	}
	
	public void add(Point left, Point center, Point right) {
		this.center.add(center);
		this.leftEdge.add(left);
		this.rightEdge.add(right);
	}
	
	public void addBeforeFirst(Point left, Point center, Point right) {
		this.center.add(0, center);
		this.leftEdge.add(0, left);
		this.rightEdge.add(0, right);
	}
	
	public int length() {
		return center.size();
	}
	
	public Roi getCenterPolygonRoi() {
		int[] xCoords = new int[center.size()];
		int[] yCoords = new int[center.size()];
		Iterator<Point> it = center.iterator();
		int index = 0;
		while(it.hasNext()) {
			Point p = it.next();
			xCoords[index] = p.x;
			yCoords[index] = p.y;
			index++;
		}
		PolygonRoi roi = new PolygonRoi(xCoords, yCoords, center.size(), Roi.FREELINE);
		roi.setImage(new ImagePlus());
		return roi;
	}
	
	public Roi getLeftEdgePolygonRoi() {
		int[] xCoords = new int[leftEdge.size()];
		int[] yCoords = new int[leftEdge.size()];
		Iterator<Point> it = leftEdge.iterator();
		int index = 0;
		while(it.hasNext()) {
			Point p = it.next();
			xCoords[index] = p.x;
			yCoords[index] = p.y;
			index++;
		}
		PolygonRoi roi = new PolygonRoi(xCoords, yCoords, leftEdge.size(), Roi.FREELINE);
		return roi;
	}
	
	public Roi getRightEdgePolygonRoi() {
		int[] xCoords = new int[rightEdge.size()];
		int[] yCoords = new int[rightEdge.size()];
		Iterator<Point> it = rightEdge.iterator();
		int index = 0;
		while(it.hasNext()) {
			Point p = it.next();
			xCoords[index] = p.x;
			yCoords[index] = p.y;
			index++;
		}
		PolygonRoi roi = new PolygonRoi(xCoords, yCoords, rightEdge.size(), Roi.FREELINE);
		return roi;
	}

	public Roi getContourRoi() {
		int[] xCoords = new int[leftEdge.size()+rightEdge.size()];
		int[] yCoords = new int[leftEdge.size()+rightEdge.size()];
		Iterator<Point> it = leftEdge.iterator();
		int index = 0;
		while(it.hasNext()) {
			Point p = it.next();
			xCoords[index] = p.x;
			yCoords[index] = p.y;
			index++;
		} 
		for (int i=rightEdge.size()-1; i>=0; i--) {
			Point p = rightEdge.get(i);
			xCoords[index] = p.x;
			yCoords[index] = p.y;
			index++;
		}
		PolygonRoi roi = new PolygonRoi(xCoords, yCoords, rightEdge.size()+leftEdge.size(), Roi.FREEROI);
		return roi;
	}
	
	public Tracing join(Tracing trace2) {
		Tracing newTracing = new Tracing();
		newTracing.center = new ArrayList<Point>(this.center);
		newTracing.leftEdge = new ArrayList<Point>(this.leftEdge);
		newTracing.rightEdge = new ArrayList<Point>(this.rightEdge);
		for (int i=0; i<trace2.length(); i++) {
			newTracing.center.add(0, trace2.center.get(i));
			newTracing.leftEdge.add(0, trace2.rightEdge.get(i));
			newTracing.rightEdge.add(0, trace2.leftEdge.get(i));
		}
		return newTracing;
	}

	public Tracing joinAtCloserPoints(Tracing trace2) {
		if (this.contains(trace2)) return this;
		if (trace2.contains(this)) return trace2;
		Tracing newTracing = new Tracing();
		double dist1 = this.last().distance(trace2.first());
		double dist2 = this.last().distance(trace2.last());
		double dist3 = this.first().distance(trace2.first());
		double dist4 = this.first().distance(trace2.last());
		int theCase = 1;
		double bestDistance = dist1;
		if (dist2<bestDistance) {
			bestDistance = dist2;
			theCase = 2;
		}
		if (dist3<bestDistance) {
			bestDistance = dist3;
			theCase = 3;
		}
		if (dist4<bestDistance) {
			bestDistance = dist4;
			theCase = 4;
		}
		if (theCase==1) {
			newTracing.center.addAll(this.center);
			newTracing.leftEdge.addAll(this.leftEdge);
			newTracing.rightEdge.addAll(this.rightEdge);
			newTracing.center.addAll(trace2.center);
			newTracing.leftEdge.addAll(trace2.leftEdge);
			newTracing.rightEdge.addAll(trace2.rightEdge);
		}
		if (theCase==2) {
			for (int i=0; i<trace2.length(); i++) {
				newTracing.center.add(0, trace2.center.get(i));
				newTracing.leftEdge.add(0, trace2.rightEdge.get(i));
				newTracing.rightEdge.add(0, trace2.leftEdge.get(i));
			}
			for (int i=0; i<this.length(); i++) {
				newTracing.center.add(0, this.center.get(i));
				newTracing.leftEdge.add(0, this.rightEdge.get(i));
				newTracing.rightEdge.add(0, this.leftEdge.get(i));
			}
		}
		if (theCase==3) {
			for (int i=0; i<this.length(); i++) {
				newTracing.center.add(0, this.center.get(i));
				newTracing.leftEdge.add(0, this.rightEdge.get(i));
				newTracing.rightEdge.add(0, this.leftEdge.get(i));
			}
			newTracing.center.addAll(trace2.center);
			newTracing.leftEdge.addAll(trace2.leftEdge);
			newTracing.rightEdge.addAll(trace2.rightEdge);
		}
		if (theCase==4) {
			newTracing.center.addAll(trace2.center);
			newTracing.leftEdge.addAll(trace2.leftEdge);
			newTracing.rightEdge.addAll(trace2.rightEdge);
			newTracing.center.addAll(this.center);
			newTracing.leftEdge.addAll(this.leftEdge);
			newTracing.rightEdge.addAll(this.rightEdge);
		}
		return newTracing;
	}
	
	public void draw(Graphics g, ImagePlus image) {
		Roi aRoi = this.getCenterPolygonRoi();
		aRoi.setImage(image);
		Color oldColor = Roi.getColor();
		Roi.setColor(color);
		aRoi.draw(g);
		Roi.setColor(oldColor);
	}
	
	public String toString() {
		if (center.size()==0) return "Tracing[empty]";
		Point p1 = center.get(0);
		Point p2 = center.get(center.size()-1);
		double length = this.getCenterPolygonRoi().getLength();
		String result = "Tracing[x1=" + p1.x + ", y1=" + p1.y + ", x2=" + p2.x + ", y2=" + p2.y + ", l=" + length+"]";
		return result;
	}

	public double getYDistance() {
		return this.getCenterPolygonRoi().getBounds().getHeight();
	}
	
	public void smooth() {
		this.center = smooth(center);
		this.rightEdge = smooth(rightEdge);
		this.leftEdge = smooth(leftEdge);
	}

	public ArrayList<Point> smooth(ArrayList<Point> points) {
		ArrayList<Point> result = new ArrayList<Point>();
		if (points.isEmpty()) return result;
		result.addAll(points);
		int i = 1;
		while (i<result.size()-1) {
			Point firstPoint = result.get(i-1);
			Point secondPoint = result.get(i);
			Point thirdPoint = result.get(i+1);
			Point firstVector = new Point(secondPoint.x - firstPoint.x, secondPoint.y-firstPoint.y);
			Point secondVector = new Point(thirdPoint.x - secondPoint.x, thirdPoint.y-secondPoint.y);
			if (!isSameDirectionCategory(firstVector, secondVector)) {
				result.remove(i);
				i++;
			} else {
				i++;
			}
		}
		return result;
	}

	public ArrayList<Point> bresenhamLineBetween(Point firstPoint, Point secondPoint) {
		int x0 = firstPoint.x, x1 = secondPoint.x;
		int y0 = firstPoint.y, y1 = secondPoint.y;
		ArrayList<Point> line = new ArrayList<Point>();
		int tmp;
		boolean steep = Math.abs(y1-y0) > Math.abs(x1 - x0);
	     if (steep) {
	    	 tmp = x0; x0 = y0; y0 = tmp; 
	    	 tmp = x1; x1 = y1; y1 = tmp;
	     }
	     if (x0 > x1) {
	    	 tmp = x0; x0 = x1; x1 = tmp;
	    	 tmp = y0; y0 = y1; y1 = tmp;
	     }
	     int deltax = x1 - x0;
	     int deltay = Math.abs(y1 - y0);
	     int error = -deltax / 2;
	     int ystep;
	     int y = y0;
	     if (y0 < y1) ystep = 1; 
	     else ystep = -1;
	     for (int x=x0; x<=x1; x++) {
	         if (steep) line.add(new Point(y,x)); else line.add(new Point(x,y));
	         error = error + deltay;
	         if (error > 0) {
	             y = y + ystep;
	             error = error - deltax;
	         }
	     }
	     return line;
	}

	private boolean isSameDirectionCategory(Point firstVector, Point secondVector) {
		boolean result = false;
		float signX1 = Math.signum(firstVector.x);
		float signX2 = Math.signum(secondVector.x);
		float signY1 = Math.signum(firstVector.y);
		float signY2 = Math.signum(secondVector.y);
		result = (signX1==signX2) && (signY1==signY2);
		return result;
	}

	public boolean connectsSamePointsAs(Tracing tracing) {
		Point p1 = center.get(0);
		Point p2 = center.get(center.size()-1);
		Point p3 = tracing.center.get(0);
		Point p4 = tracing.center.get(tracing.center.size()-1);
		if (p1.equals(p3)&&p2.equals(p4) || p1.equals(p4)&&p2.equals(p3)) return true;
		return false;
	}
	
	public boolean almostConnectsSamePointsAs(Tracing tracing, int radius) {
		Point p1 = center.get(0);
		Point p2 = center.get(center.size()-1);
		Point p3 = tracing.center.get(0);
		Point p4 = tracing.center.get(tracing.center.size()-1);
		if (( Math.abs(p1.x-p3.x)<=radius && Math.abs(p1.y-p3.y)<= radius && 
			Math.abs(p2.x-p4.x)<=radius && Math.abs(p2.y-p4.y)<= radius ) ||
			( Math.abs(p1.x-p4.x)<=radius && Math.abs(p1.y-p4.y)<= radius && 
					Math.abs(p2.x-p3.x)<=radius && Math.abs(p2.y-p3.y)<= radius )
			) return true;
		return false;
	}
	
	public int relativePositionOfPoint(Point p) {
		if (this.getContourRoi().contains(p.x, p.y)) return 0;
		Point intersection = new Point();
		closestSegment(p, intersection);
		if (p.x<intersection.x) return -1;
		if (p.x>intersection.x) return 1;
		if (p.y<intersection.y) return -1;
		if (p.y>intersection.y) return 1;
		return 0;
	}

	public Line2D closestSegment(Point p, Point intersection) {
		int x3 = p.x;
		int y3 = p.y;
		int resultIndex = -1;
		double minDistance = 999999999;
		double bestIntersectionX = -1;
		double bestIntersectionY = -1;
		double ix = -1;
		double iy = -1;
		for (int i=1; i<center.size(); i++) {
			double newDistance = 999999999;
			Point p1 = center.get(i-1);
			Point p2 = center.get(i);
			int x1 = p1.x;
			int y1 = p1.y;
			int x2 = p2.x;
			int y2 = p2.y;
			double lineMagnitude = lineMagnitude(x1, y1, x2, y2);
			if (lineMagnitude<0.00000001) continue;
			double u = (((x3 - x1) * (x2 - x1)) + ((y3 - y1) * (y2 - y1)));
			u = u / (lineMagnitude * lineMagnitude);
			if (u<0.00001 || u>1) {						// not in line segment calculate distance to nearest end point
				 double dist1 = lineMagnitude(x3, y3, x1, y1);
			     double dist2 = lineMagnitude(x3, y3, x2, y2);
			     if (dist1 > dist2) {
			    	 newDistance = dist2;
			    	 ix = x2;
			    	 iy = y2;
			     } else {
			    	 newDistance = dist1;
			    	 ix = x1;
			    	 iy = y1;
			     }
			} else {
				ix = x1 + u * (x2 - x1);
				iy = y1 + u * (y2 - y1);
				newDistance = lineMagnitude(x3, y3, ix, iy);
			}
			if (newDistance<minDistance) {
				minDistance = newDistance;
				resultIndex = i;
				bestIntersectionX = ix;
				bestIntersectionY = iy;
			}
		}
		Point p1 = center.get(resultIndex-1);
		Point p2 = center.get(resultIndex);
		Line2D result = new Line2D.Float(p1,p2); 
		intersection.x = (int)Math.round(bestIntersectionX);
		intersection.y = (int)Math.round(bestIntersectionY);
		return result;
	}
	
	public Line2D closestLeftEdgeSegment(Point p, Point intersection) {
		int x3 = p.x;
		int y3 = p.y;
		int resultIndex = -1;
		double minDistance = 999999999;
		double bestIntersectionX = -1;
		double bestIntersectionY = -1;
		double ix = -1;
		double iy = -1;
		for (int i=1; i<leftEdge.size(); i++) {
			double newDistance = 999999999;
			Point p1 = leftEdge.get(i-1);
			Point p2 = leftEdge.get(i);
			int x1 = p1.x;
			int y1 = p1.y;
			int x2 = p2.x;
			int y2 = p2.y;
			double lineMagnitude = lineMagnitude(x1, y1, x2, y2);
			if (lineMagnitude<0.00000001) continue;
			double u = (((x3 - x1) * (x2 - x1)) + ((y3 - y1) * (y2 - y1)));
			u = u / (lineMagnitude * lineMagnitude);
			if (u<0.00001 || u>1) {						// not in line segment calculate distance to nearest end point
				 double dist1 = lineMagnitude(x3, y3, x1, y1);
			     double dist2 = lineMagnitude(x3, y3, x2, y2);
			     if (dist1 > dist2) {
			    	 newDistance = dist2;
			    	 ix = x2;
			    	 iy = y2;
			     } else {
			    	 newDistance = dist1;
			    	 ix = x1;
			    	 iy = y1;
			     }
			} else {
				ix = x1 + u * (x2 - x1);
				iy = y1 + u * (y2 - y1);
				newDistance = lineMagnitude(x3, y3, ix, iy);
			}
			if (newDistance<minDistance) {
				minDistance = newDistance;
				resultIndex = i;
				bestIntersectionX = ix;
				bestIntersectionY = iy;
			}
		}
		Point p1 = leftEdge.get(resultIndex-1);
		Point p2 = leftEdge.get(resultIndex);
		Line2D result = new Line2D.Float(p1,p2); 
		intersection.x = (int)Math.round(bestIntersectionX);
		intersection.y = (int)Math.round(bestIntersectionY);
		return result;
	}
	
	public Line2D closestRightEdgeSegment(Point p, Point intersection) {
		int x3 = p.x;
		int y3 = p.y;
		int resultIndex = -1;
		double minDistance = 999999999;
		double bestIntersectionX = -1;
		double bestIntersectionY = -1;
		double ix = -1;
		double iy = -1;
		for (int i=1; i<rightEdge.size(); i++) {
			double newDistance = 999999999;
			Point p1 = rightEdge.get(i-1);
			Point p2 = rightEdge.get(i);
			int x1 = p1.x;
			int y1 = p1.y;
			int x2 = p2.x;
			int y2 = p2.y;
			double lineMagnitude = lineMagnitude(x1, y1, x2, y2);
			if (lineMagnitude<0.00000001) continue;
			double u = (((x3 - x1) * (x2 - x1)) + ((y3 - y1) * (y2 - y1)));
			u = u / (lineMagnitude * lineMagnitude);
			if (u<0.00001 || u>1) {						// not in line segment calculate distance to nearest end point
				 double dist1 = lineMagnitude(x3, y3, x1, y1);
			     double dist2 = lineMagnitude(x3, y3, x2, y2);
			     if (dist1 > dist2) {
			    	 newDistance = dist2;
			    	 ix = x2;
			    	 iy = y2;
			     } else {
			    	 newDistance = dist1;
			    	 ix = x1;
			    	 iy = y1;
			     }
			} else {
				ix = x1 + u * (x2 - x1);
				iy = y1 + u * (y2 - y1);
				newDistance = lineMagnitude(x3, y3, ix, iy);
			}
			if (newDistance<minDistance) {
				minDistance = newDistance;
				resultIndex = i;
				bestIntersectionX = ix;
				bestIntersectionY = iy;
			}
		}
		Point p1 = rightEdge.get(resultIndex-1);
		Point p2 = rightEdge.get(resultIndex);
		Line2D result = new Line2D.Float(p1,p2); 
		intersection.x = (int)Math.round(bestIntersectionX);
		intersection.y = (int)Math.round(bestIntersectionY);
		return result;
	}
	
	private double lineMagnitude(double x1, double y1, double x2, double y2) {
		double result = Math.sqrt(((x2-x1)*(x2-x1)) + ((y2-y1)*(y2-y1)));
		return result;
	}

	public Point first() {
		return center.get(0);
	}
	
	public Point last() {
		return center.get(center.size()-1);
	}

	public double getSNR(ImagePlus image) {
		Roi oldRoi = image.getRoi();
		image.setRoi(this.getCenterPolygonRoi());
		ImageStatistics stats = image.getStatistics(ImageStatistics.MEDIAN);
		double foregroundMean = stats.median;
		Polygon polygon = image.getRoi().getPolygon();
		polygon.translate(-3, -3);
		Roi newRoi = new PolygonRoi(polygon, image.getRoi().getType());
		image.setRoi(newRoi);
		stats = image.getStatistics(ImageStatistics.MEDIAN+ImageStatistics.STD_DEV);
		double backgroundMean = stats.median;
		double backgroundStdDev = stats.stdDev;
		double result = (foregroundMean - backgroundMean) / backgroundStdDev;
		image.setRoi(oldRoi);
		return result;
	}

	public Vector<Tracing> cutBy(Tracing theOtherTracing) {
		Vector<Point> cuttingPoints = new Vector<Point>();
		for (int i = 1; i<theOtherTracing.center.size(); i++) {
			Point p1Start = theOtherTracing.center.get(i-1);
			Point p1End = theOtherTracing.center.get(i);
			for (int j = 1; j<this.center.size(); j++) {
				Point p2Start = this.center.get(j-1);
				Point p2End = this.center.get(j);
				if (Line2D.linesIntersect(p1Start.x, p1Start.y, p1End.x, p1End.y, p2Start.x, p2Start.y, p2End.x, p2End.y)) {
					Point intersection = this.intersectionPoint(p1Start.x, p1Start.y, p1End.x, p1End.y, p2Start.x, p2Start.y, p2End.x, p2End.y);
					if (intersection.x!=0 && intersection.y!=0) cuttingPoints.add(intersection);
				}
			}
		}
		Vector<Tracing> result = new Vector<Tracing>();
		if (cuttingPoints.isEmpty()) result.add(this); 
		else {
			result.addAll(this.cutAtPoints(cuttingPoints)); 
		}
		return result;
	}

	public Vector<Tracing> cutAtPoints(Vector<Point> cuttingPoints) {
		Vector<Tracing> tracings = new Vector<Tracing>();
		Iterator<Point> it = cuttingPoints.iterator();
		Tracing currentTracing = new Tracing();
		while (it.hasNext()) {
			Point cuttingPoint = it.next();
			for (int j = 1; j<this.center.size(); j++) {
				Point pStart = this.center.get(j-1);
				Point pEnd = this.center.get(j);
				Line2D segment = new Line2D.Float(pStart, pEnd);
				if (segment.relativeCCW(cuttingPoint)==0) {
					currentTracing.add(
							this.leftEdge.get(j-1), 
							 pStart, 
							this.rightEdge.get(j-1));
					if (!pStart.equals(cuttingPoint)) {
						currentTracing.add(
								cuttingPoint, 			// TODO calculate left edge point for cutting point
								 cuttingPoint, 
								 cuttingPoint);			// TODO calculate right edge point for cutting point
					}
					if (currentTracing.center.size()>1) tracings.add(currentTracing);
					currentTracing = new Tracing();
					if (!(pEnd.equals(cuttingPoint))) {
						currentTracing.add(cuttingPoint, cuttingPoint, cuttingPoint);	// TODO calculate cutting point + 1
						currentTracing.add(
								this.leftEdge.get(j), 
								 pEnd, 
								this.rightEdge.get(j));
					}
				} else {
					currentTracing.add(
							this.leftEdge.get(j-1), 
							 pStart, 
							this.rightEdge.get(j-1));
					currentTracing.add(
							this.leftEdge.get(j), 
							 pEnd, 
							this.rightEdge.get(j));
				}
			}
		}
		if (!currentTracing.center.isEmpty() && currentTracing.center.size()>1) {
			tracings.add(currentTracing);
		}
		return tracings;
	}

	public Point intersectionPoint(int x1, int y1, int x2, int y2, int x3, int y3, int x4, int y4) {
		double denominator = (y4-y3)*(x2-x1)-(x4-x3)*(y2-y1);
		double uaNominator = (x4-x3)*(y1-y3)-(y4-y3)*(x1-x3);
		//double ubNominator = (x2-x1)*(y1-y3)-(y2-y1)*(x1-x3);
		double ua = uaNominator / denominator;
		//double ub = ubNominator / denominator;
		Point result = new Point((int)Math.round(x1 + ua*(x2-x1)), (int)Math.round(y1+ua*(y2-y1)));
		return result;
	}


	public void drawCenterlineOn(ImagePlus image) {
		Roi oldRoi = image.getRoi();
		image.setRoi(this.getCenterPolygonRoi());
		IJ.run("Draw");
		image.setRoi(oldRoi);
	}
	
	public Vector<Point> getSegment(int i) {
		Vector<Point> result = new Vector<Point>();
		if (i<0 || i>=center.size()-1) return result;
		int[] xCoords = new int[4];
		int[] yCoords = new int[4];
		xCoords[0] = leftEdge.get(i).x;
		yCoords[0] = leftEdge.get(i).y;
		xCoords[1] = rightEdge.get(i).x;
		yCoords[1] = rightEdge.get(i).y;
		xCoords[2] = rightEdge.get(i+1).x;
		yCoords[2] = rightEdge.get(i+1).y;
		xCoords[3] = leftEdge.get(i+1).x;
		yCoords[3] = leftEdge.get(i+1).y;
		PolygonRoi roi = new PolygonRoi(xCoords, yCoords, 4, Roi.FREEROI);
		Rectangle rect = roi.getBounds();
		Point nextCenter = center.get(i+1);
		for (int x=rect.x; x<rect.x+rect.width; x++) {
			for (int y=rect.y; y<rect.y+rect.height; y++) {
				if (roi.contains(x, y)) {
					Point point = new Point(x,y);
					if (!point.equals(nextCenter)) result.add(point);
				}
			}
		}
		
		return result;
	}
	
	public boolean contains(Tracing aTracing) {
		return center.containsAll(aTracing.center);
	}

	public void correctLeftRightEdge() {
		int x1 = leftEdge.get(0).x;
		int x2 = rightEdge.get(0).x;
		if (x1<x2) {
			ArrayList<Point> tmp = rightEdge;
			rightEdge = leftEdge;
			leftEdge = tmp;
		}
	}
}

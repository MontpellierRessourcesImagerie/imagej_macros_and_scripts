package tracing;

import java.awt.Point;
import java.util.Comparator;

public class PointsDistanceComparator implements Comparator<Point> {

	public int compare(Point p1, Point p2) {
		int result = 0;
		float dist1 = (p1.x * p1.x) + (p1.y * p1.y); 
		float dist2 = (p2.x * p2.x) + (p2.y * p2.y);
		if (dist1<dist2) result = -1;
		if (dist1>dist2) result = 1;
		return result;
	}

}

package tracing;

import java.awt.Point;
import java.util.Comparator;

public class PointsDistanceYComparator implements Comparator<Point> {

	public int compare(Point p1, Point p2) {
		int result = 0;
		if (p1.y<p2.y) result = -1;
		if (p1.y>p2.y) result = 1;
		if (p1.y==p2.y) {
			if (p1.x<p2.x) result = -1;
			if (p1.x>p2.x) result = 1;
		}
		return result;
	}

}

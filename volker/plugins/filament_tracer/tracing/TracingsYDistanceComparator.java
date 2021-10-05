package tracing;

import java.util.Comparator;

public class TracingsYDistanceComparator implements Comparator<Tracing> {

	public int compare(Tracing aTracing, Tracing anOtherTracing) {
		int result = 0;
		double yDistanceOfATracing = (aTracing).getYDistance();
		double yDistanceOfAnOtherTracing = (anOtherTracing).getYDistance();
		if (yDistanceOfATracing<yDistanceOfAnOtherTracing) result = -1;
		if (yDistanceOfATracing>yDistanceOfAnOtherTracing) result = 1;
		return result;
	}

}

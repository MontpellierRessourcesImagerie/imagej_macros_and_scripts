package tracing;

import java.util.Comparator;

public class TracingsLengthComparator implements Comparator<Tracing> {

	public int compare(Tracing aTracing, Tracing anOtherTracing) {
		int result = 0;
		double lengthOfATracing = (aTracing).getCenterPolygonRoi().getLength();
		double lengthOfAnOtherTracing = (anOtherTracing).getCenterPolygonRoi().getLength();
		if (lengthOfATracing<lengthOfAnOtherTracing) result = -1;
		if (lengthOfATracing>lengthOfAnOtherTracing) result = 1;
		return result;
	}

}

package tracing;

import java.util.Comparator;

public class SmallestXComparator implements Comparator<Tracing> {

	public int compare(Tracing tracing1, Tracing tracing2) {
		int startX1 = (tracing1.first().x<tracing1.last().x) ? (tracing1.first().x) : tracing1.last().x;
		int startX2 = (tracing2.first().x<tracing2.last().x) ? (tracing2.first().x) : tracing2.last().x;
		int result = 0;
		if (startX1<startX2) return -1;
		if (startX1>startX2) return 1;
		return result;
	}

}

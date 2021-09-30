package tracing;

import java.awt.Point;

public class Edge {
	protected Point fromNode;
	protected Point toNode;
	protected Tracing trace;
	
	public Edge(Point fromNode, Point toNode, Tracing trace) {
		this.fromNode = fromNode;
		this.toNode = toNode;
		this.trace = trace;
	}

	public double lenght() {
		return trace.getCenterPolygonRoi().getLength();
	}
}

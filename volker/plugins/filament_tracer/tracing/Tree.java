package tracing;

import ij.ImagePlus;

import java.awt.Graphics;
import java.util.Iterator;
import java.util.Vector;

public class Tree {
	Vector<Edge> edges; 
	
	public Tree(Tracing main) {
		edges = new Vector<Edge>();
		edges.add(new Edge(main.first(), main.last(), main));
	}
	
	public void addTracings(Vector<Tracing> tracings) {
		Tracing main = (edges.elementAt(0)).trace;
		for (Tracing current : tracings) {
			if (current == main) continue;
			edges.add(new Edge(current.first(), current.last(), current));
		}
	}
	
	public String toString() {
		Tracing main = edges.elementAt(0).trace;
		double length = this.length();
		String result = "Tree[x1=" + main.first().x + 
		                   ", y1=" + main.first().y + 
		                   ", x2=" + main.last().x + 
		                   ", y2=" + main.last().y + 
		                   ", b=" + (edges.size()-1) + 
		                   ", l=" + length+"]";
		return result;
	}

	protected double length() {
		double length = 0;
		Iterator<Edge> it = edges.iterator();
		while (it.hasNext()) {
			Edge current = it.next();
			length += current.lenght();
		}
		return length;
	}

	public void draw(Graphics g, ImagePlus imp) {
		Iterator<Edge> it = edges.iterator();
		while (it.hasNext()) {
			Edge current = it.next();
			current.trace.draw(g, imp);
		}
	}

}

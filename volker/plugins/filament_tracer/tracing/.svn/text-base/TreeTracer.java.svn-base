package tracing;

import ij.IJ;
import ij.ImagePlus;
import ij.WindowManager;
import ij.gui.ImageWindow;
import ij.gui.PointRoi;
import ij.gui.Roi;
import ij.gui.TracingImageCanvas;

import java.awt.Color;
import java.awt.Point;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Observable;
import java.util.Observer;
import java.util.Vector;
import operations.image.ConvertImageTypeOperation;
import operations.morphology.MorphoContrastEnhanceOperation;
import operations.processing.EnhanceContrastOperation;

public class TreeTracer extends Observable implements Observer {
	protected Vector<Tree> trees;
	protected Vector<Tracing> tracings;
	protected Vector<Point> seeds;
	protected ImagePlus image;
	
	protected TreeTracerView view;
	private TreeTracerOptions options;
	private FindSkeletonPoints findSkeletonPoints;
	
	public TreeTracer() {
		trees = new Vector<Tree>();
		tracings = new Vector<Tracing>();
		seeds = new Vector<Point>();
	}
	
	public void show() {
		this.getView().setVisible(true);
	}

	public TreeTracerView getView() {
		if (view==null) view = new TreeTracerView(this);
		return view;
	}
	
	static public void showNew() {
		(new TreeTracer()).show();
	}

	public void addSeeds() {
		image = IJ.getImage();
		PointRoi pointRoi = (PointRoi) image.getRoi();
		if (pointRoi==null) return;
		int xStart = pointRoi.getBounds().x;
		int yStart = pointRoi.getBounds().y;
		int[] x = pointRoi.getXCoordinates();
		int[] y = pointRoi.getYCoordinates();
		for (int i=0; i<x.length; i++) {
			Point point = new Point(xStart + x[i], yStart + y[i]);
			seeds.add(point);
		}
		this.changed("seeds");
	}

	/**
	 * @param string
	 */
	private void changed(String string) {
		this.setChanged();
		this.notifyObservers(string);
		this.clearChanged();
	}

	public void trace(Point[] selectedSeeds) {
		Vector<Point> startPoints;
		startPoints = (selectedSeeds.length==0) ?  seeds : new Vector<Point>(Arrays.asList(selectedSeeds));
		image = IJ.getImage();
		ImagePlus enhancedImage = getContrastEnhancedImage();
		FilamentTracer tracer = newTracerFor(enhancedImage);
		// test
		HashSet<Point> seeds = new HashSet<Point>();
		seeds.addAll(startPoints);
		tracer.seedPoints = seeds; 
		// test end
		Iterator<Point> it = startPoints.iterator();
		while(it.hasNext()) {
			Point point = it.next();
			tracings.add(tracer.traceFrom(point.x, point.y));
		}
		this.changed("tracings");
	}

	protected ImagePlus getContrastEnhancedImage() {
		if (!getOptions().isEnhanceContrast()) return image;
		MorphoContrastEnhanceOperation op1 = new MorphoContrastEnhanceOperation();
		op1.setInputImage(image);
		op1.setShowResult(false);
		op1.run();
		ConvertImageTypeOperation op2 = new ConvertImageTypeOperation();
		op2.setShowResult(false);
		op2.setKeepSource(false);
		op2.setInputImage(op1.getResult());
		op2.setOutputType("16-bit");
		op2.run();
		ImagePlus result1 = op2.getResult();
		EnhanceContrastOperation op3 = new EnhanceContrastOperation();
		op3.setShowResult(false);
		op3.setKeepSource(false);
		op3.setInputImage(result1);
		op3.run();
		op3.getResult().updateImage();
		return op3.getResult();
	}

	@SuppressWarnings("unchecked")
	public void showTracings(Object[] selectedTracings) {
		if (WindowManager.getIDList()==null) return;
		image = IJ.getImage();
		if (image==null) return;
		TracingImageCanvas canvas = new TracingImageCanvas(image);
		canvas.setTracings(new ArrayList(Arrays.asList(selectedTracings)));
		new ImageWindow(image, canvas);
		image.updateAndDraw();
	}

	@SuppressWarnings("unchecked")
	public void showTrees(Object[] selectedTrees) {
		if (WindowManager.getIDList()==null) return;
		image = IJ.getImage();
		if (image==null) return;
		TracingImageCanvas canvas = new TracingImageCanvas(image);
		canvas.setTrees(new ArrayList(Arrays.asList(selectedTrees)));
		new ImageWindow(image, canvas);
		image.updateAndDraw();
	}
	
	public void removeSeeds(Object[] selectedValues) {
		seeds.removeAll(new Vector<Object>(Arrays.asList(selectedValues)));
		this.changed("seeds");
	}

	public void removeTracings(Object[] selectedValues) {
		tracings.removeAll(new Vector<Object>(Arrays.asList(selectedValues)));
		this.changed("tracings");
	}

	public void showSeeds(Object[] selectedValues) {
		if (WindowManager.getIDList()==null) return;
		image = IJ.getImage();
		if (image==null) return;
		int[] x = new int[selectedValues.length];
		int[] y = new int[selectedValues.length];
		for (int i=0; i<selectedValues.length; i++) {
			x[i] = ((Point)selectedValues[i]).x;
			y[i] = ((Point)selectedValues[i]).y;
		}
		Roi roi = new PointRoi(x,y,x.length);
		image.setRoi(roi);
	}

	public TreeTracerOptions getOptions() {
		if (this.options == null) this.options = new TreeTracerOptions();
		return options;
	}

	public void findSeedPoints() {
		image = IJ.getImage();
		if (image==null) return;
		if (getOptions().getUseSkeletonPoints()) {
			this.findSkeletonPoints(image);
			return;
		}
		ImagePlus enhancedImage = getContrastEnhancedImage();
		SeedPointsFinder finder = newFinderFor(enhancedImage);
		finder.run();
		finder.filterSeedPoints();
		seeds.addAll(finder.getLocalMaxima());
		this.changed("seeds");
	}

	public void findSkeletonPoints(ImagePlus anImage) {
		findSkeletonPoints = new FindSkeletonPoints(anImage);
		findSkeletonPoints.addObserver(this);
		Thread thread = new Thread(findSkeletonPoints);
		thread.start();
	}

	public void traceAll() {
		image = IJ.getImage();
		if (image==null) return;
		ImagePlus enhancedImage = getContrastEnhancedImage();
		FilamentTracer tracer = newTracerFor(enhancedImage);
		Vector<Tracing> tracings = tracer.trace();
		seeds.addAll(tracer.getFinder().getLocalMaxima());
		this.tracings.addAll(tracings);
		this.changed("seeds");
		this.changed("tracings");
	}

	protected FilamentTracer newTracerFor(ImagePlus image) {
		TreeTracerOptions options = getOptions();
		FilamentTracer tracer = new FilamentTracer(image, options.getMaxFilamentWidth());
		tracer.setStepSize(options.getStepSize());
		tracer.setMinTracingLength(options.getMinTracingLength());
		SeedPointsFinder finder = newFinderFor(image);
		tracer.setFinder(finder);
		return tracer;
	}

	private SeedPointsFinder newFinderFor(ImagePlus image) {
		TreeTracerOptions options = getOptions();
		SeedPointsFinder finder = SeedPointsFinder.newFor(image, Math.round(image.getHeight() * options.getHorizontalLinesFraction()), Math.round(image.getWidth()*options.getVerticalLinesFraction()));
		finder.setThresholdScalingFactor(options.getCanThresholdScalingFactor());
		finder.setMaxFilamentWidth(options.getMaxFilamentWidth());
		finder.setSnrRegionRadius(options.getSnrEstimationRegionRadius());
		return finder;
	}
	
	public void traceBranches(Object selectedValue) {
		image = IJ.getImage();
		if (image==null) return;
		if (selectedValue==null) return;
		ImagePlus enhancedImage = getContrastEnhancedImage();
		FilamentTracer tracer = newTracerFor(enhancedImage);
		Vector<Tracing> tracings = tracer.traceBranches((Tracing)selectedValue);
		this.tracings.addAll(tracings);
		seeds.addAll(tracer.getFinder().getLocalMaxima());
		this.changed("seeds");
		this.changed("tracings");
	}

	public void sortTracingsByLength() {
		Collections.sort(tracings, new TracingsLengthComparator());
		this.changed("tracings");
	}

	public void sortTracingsByYDistance() {
		Collections.sort(tracings, new TracingsYDistanceComparator());
		this.changed("tracings");
	}
	
	public void sortTracingsByMeanIntensity() {
		image = IJ.getImage();
		Roi oldRoi = image.getRoi();
		if (image==null) return;
		Collections.sort(tracings, new TracingsMeanIntensityComparator(image));
		image.setRoi(oldRoi);
		this.changed("tracings");
	}

	public void sortTracingsBySNR() {
		image = IJ.getImage();
		Roi oldRoi = image.getRoi();
		if (image==null) return;
		Collections.sort(tracings, new TracingsSNRComparator(image));
		image.setRoi(oldRoi);
		this.changed("tracings");
	}
	
	public void smooth(Object[] selectedValues) {
		for (int i=0; i<selectedValues.length; i++) {
			Tracing currentTracing = (Tracing) selectedValues[i];
			currentTracing.smooth();
		}
		this.changed("tracings");
	}

	public void removeDuplicateTracings() {
		Vector<Tracing> filteredTracings = new Vector<Tracing>(); 
		Vector<Tracing> oldTracings = new Vector<Tracing>();
		for (int i=0; i<tracings.size(); i++) {
			Tracing aTracing = tracings.elementAt(i);
			if (aTracing.center.size()>1) oldTracings.add(aTracing);
		}
		while(!oldTracings.isEmpty()) {
			Vector<Tracing> cluster = new Vector<Tracing>();
			Tracing template = oldTracings.elementAt(0);
			cluster.add(template);
			for (int i=1; i<oldTracings.size();i++) {
				Tracing aTracing = oldTracings.elementAt(i);
				if (template.connectsSamePointsAs(aTracing)) {
					cluster.add(aTracing);
				}
			}
			int index = 0;
			double score = 999999999;
			for (int i=0; i<cluster.size(); i++) {
				double length = cluster.elementAt(i).getCenterPolygonRoi().getLength();
				if (length<score) {
					score = length;
					index = i;
				}
			}
			filteredTracings.add(cluster.elementAt(index));
			oldTracings.removeAll(cluster);
		}
		this.tracings = filteredTracings;
		this.changed("tracings");
	}

	public void removeDuplicateBranches() {
		Vector<Tracing> filteredTracings = new Vector<Tracing>(); 
		Vector<Tracing> oldTracings = new Vector<Tracing>();
		for (int i=0; i<tracings.size(); i++) {
			Tracing aTracing = tracings.elementAt(i);
			if (aTracing.center.size()>1) oldTracings.add(aTracing);
		}
		while(!oldTracings.isEmpty()) {
			Vector<Tracing> cluster = new Vector<Tracing>();
			Tracing template = oldTracings.elementAt(0);
			cluster.add(template);
			for (int i=1; i<oldTracings.size();i++) {
				Tracing aTracing = oldTracings.elementAt(i);
				if (template.almostConnectsSamePointsAs(aTracing, 3)) {
					cluster.add(aTracing);
				}
			}
			int index = 0;
			double score = 0;
			for (int i=0; i<cluster.size(); i++) {
				double length = 100 * cluster.elementAt(i).getYDistance()  
										- cluster.elementAt(i).getCenterPolygonRoi().getLength();
				if (length>score) {
					score = length;
					index = i;
				}
			}
			filteredTracings.add(cluster.elementAt(index));
			oldTracings.removeAll(cluster);
		}
		this.tracings = filteredTracings;
		this.changed("tracings");
	}
	
	public void update(Observable arg0, Object arg1) {
		this.seeds = findSkeletonPoints.seeds;
		findSkeletonPoints.deleteObserver(this);
		if (image!=null) WindowManager.setTempCurrentImage(image);
		this.changed("seeds");
	}

	public void measureTracings(Object[] selectedValues) {
		if (selectedValues==null || selectedValues.length==0) return;
		image = IJ.getImage();
		if (image==null) return;
		for (int i=0; i<selectedValues.length; i++) {
			Tracing aTracing = (Tracing) selectedValues[i];
			image.setRoi(aTracing.getCenterPolygonRoi());
			IJ.run("Measure");
		}
		image.killRoi();
	}

	public void selectTracing(Object selectedValue) {
		Tracing aTracing = (Tracing) selectedValue;
		image.setRoi(aTracing.getCenterPolygonRoi());
	}

	public void sortSeedsByDistance() {
		if (seeds==null || seeds.isEmpty()) return;
		Collections.sort(seeds, new PointsDistanceComparator());
		this.changed("seeds");
	}

	public void sortSeedsByYCoordinate() {
		if (seeds==null || seeds.isEmpty()) return;
		Collections.sort(seeds, new PointsDistanceYComparator());
		this.changed("seeds");
	}

	public void createTree() {
		this.removeDuplicateTracings();
		this.sortTracingsByYDistance();
		Tracing mainTracing = tracings.lastElement();
		mainTracing.correctLeftRightEdge();
		tracings.remove(mainTracing);
		Iterator<Tracing> it = tracings.iterator();
		Vector<Tracing> newTracings = new Vector<Tracing>();
		newTracings.add(mainTracing);
		while(it.hasNext()) {
			Tracing aTracing = it.next();
			Vector<Tracing> resultTracings = splitTracing(aTracing, mainTracing);
			if (resultTracings.size()==0) continue;
			newTracings.addAll(resultTracings);
		}
		this.tracings = newTracings;
		this.removeNotDescendingTracings(mainTracing);
		
		removeDuplicateBranches();

		makeTracingsUnique();
		
		this.removeTracingsBelow(4.0/5, mainTracing);
		this.removeDuplicateTracings();
		
		this.removeIncludedTracings();
		
		this.connectTracings(mainTracing);
		
		this.changed("tracings");
		
		this.createTree(mainTracing);
	}

	protected void createTree(Tracing mainTracing) {
		Tree tree = new Tree(mainTracing);
		tree.addTracings(tracings);
		this.trees.add(tree);
		this.changed("trees");
	}

	protected void removeIncludedTracings() {
		Vector<Tracing> newTracings = new Vector<Tracing>();
		for (int i=0; i<tracings.size(); i++) {
			Tracing aTracing = tracings.elementAt(i);
			boolean isIncluded = false;
			for (int j=0; j<tracings.size(); j++) {
				Tracing otherTracing = tracings.elementAt(j);
				if (aTracing==otherTracing) continue;
				if (otherTracing.contains(aTracing)) isIncluded = true;
			}
			if (!isIncluded) newTracings.add(aTracing);
		}
		this.tracings = newTracings;
	}

	protected void connectTracings(Tracing mainTracing) {
		Vector<Tracing> leftTracings = this.getLeftTracings(mainTracing); 
		Vector<Tracing> rightTracings = this.getRightTracings(mainTracing); 
		Collections.sort(leftTracings, new SmallestXComparator());
		Collections.sort(rightTracings, new BiggestXComparator());
		tracings.clear();
		tracings.addAll(this.connectLeftTracings(leftTracings, mainTracing));
		tracings.addAll(this.connectRightTracings(rightTracings, mainTracing));
		tracings.add(mainTracing);
	}

	protected Vector<Tracing> connectRightTracings(Vector<Tracing> tracings, Tracing mainTracing) {
		Vector<Tracing> newTracings = new Vector<Tracing>();
		Vector<Tracing> unconnectedTracings = new Vector<Tracing>(tracings);
		while(!unconnectedTracings.isEmpty()) {
			Tracing currentTracing = unconnectedTracings.firstElement();
			Tracing neighbor = findNextNeighborToTheLeft(currentTracing, tracings, mainTracing);
			if (neighbor!=mainTracing) {
				Tracing joined = currentTracing.joinAtCloserPoints(neighbor);
				unconnectedTracings.remove(currentTracing);
				unconnectedTracings.remove(neighbor);
				unconnectedTracings.add(joined);
			} else {
				unconnectedTracings.remove(currentTracing);
				prolongRightTracingToTouchBorder(currentTracing, mainTracing);
				newTracings.add(currentTracing);
			}
		}
		return newTracings;
	}


	protected Vector<Tracing> connectLeftTracings(Vector<Tracing> tracings, Tracing mainTracing) {
		Vector<Tracing> newTracings = new Vector<Tracing>();
		Vector<Tracing> unconnectedTracings = new Vector<Tracing>(tracings);
		Vector<Tracing> allTracings = new Vector<Tracing>(tracings);
		while(!unconnectedTracings.isEmpty()) {
			Tracing currentTracing = unconnectedTracings.firstElement();
			Tracing neighbor = findNextNeighborToTheRight(currentTracing, allTracings, mainTracing);
			if (neighbor!=mainTracing) {
				Tracing joined = currentTracing.joinAtCloserPoints(neighbor);
				unconnectedTracings.remove(currentTracing);
				unconnectedTracings.remove(neighbor);
				unconnectedTracings.add(joined);
				Collections.sort(unconnectedTracings, new SmallestXComparator());
				allTracings.remove(currentTracing);
				allTracings.remove(neighbor);
				allTracings.add(joined);
				Collections.sort(allTracings, new SmallestXComparator());
			} else {
				unconnectedTracings.remove(currentTracing);
				prolongLeftTracingToTouchBorder(currentTracing, mainTracing);
				newTracings.add(currentTracing);
			}
		}
		return newTracings;
	}

	protected void prolongLeftTracingToTouchBorder(Tracing currentTracing, Tracing mainTracing) {
		Point intersectionStart = new Point();
		Point intersectionEnd = new Point();
		Tracing rightborder = new Tracing();
		rightborder.center = mainTracing.rightEdge;
		rightborder.closestSegment(currentTracing.first(), intersectionStart);
		rightborder.closestSegment(currentTracing.last(), intersectionEnd);
		double startDistance = intersectionStart.distance(currentTracing.first());
		double endDistance = intersectionEnd.distance(currentTracing.last());
		if (startDistance<endDistance) {
			currentTracing.addBeforeFirst(intersectionStart, intersectionStart, intersectionStart);
		} else {
			currentTracing.add(intersectionEnd, intersectionEnd, intersectionEnd);
		}
	}

	protected void prolongRightTracingToTouchBorder(Tracing currentTracing, Tracing mainTracing) {
		Point intersectionStart = new Point();
		Point intersectionEnd = new Point();
		Tracing leftborder = new Tracing();
		leftborder.center = mainTracing.leftEdge;
		leftborder.closestSegment(currentTracing.first(), intersectionStart);
		leftborder.closestSegment(currentTracing.last(), intersectionEnd);
		double startDistance = intersectionStart.distance(currentTracing.first());
		double endDistance = intersectionEnd.distance(currentTracing.last());
		if (startDistance<endDistance) {
			currentTracing.addBeforeFirst(intersectionStart, intersectionStart, intersectionStart);
		} else {
			currentTracing.add(intersectionEnd, intersectionEnd, intersectionEnd);
		}
	}
	
	protected Tracing findNextNeighborToTheRight(Tracing currentTracing, Vector<Tracing> tracings, Tracing mainTracing) {
		Point currentEndPoint = (currentTracing.first().x<currentTracing.last().x) ? currentTracing.last() : currentTracing.first();
		Tracing currentNeighbor = mainTracing;
		Point intersection = new Point();
		mainTracing.closestLeftEdgeSegment(currentEndPoint, intersection);
		Point currentStartPoint = intersection;
		int currentXDistance = currentStartPoint.x - currentEndPoint.x;
		double distance = currentStartPoint.distance(currentEndPoint);
		if (currentXDistance<0) distance += 9999999;
		double bestDistance = distance;
		Tracing bestTracing = mainTracing;
		Iterator<Tracing> it = tracings.iterator();
		double maxDistance = 30;
		while(it.hasNext()) {
			currentNeighbor = it.next();
			if (currentNeighbor==currentTracing) continue;
			currentStartPoint = (currentNeighbor.first().x<currentNeighbor.last().x) ? currentNeighbor.first() : currentNeighbor.last();
			currentXDistance = currentStartPoint.x - currentEndPoint.x;
			distance = currentStartPoint.distance(currentEndPoint);
			if (currentXDistance<0 || distance>maxDistance) distance += 99999999;
			if (distance<bestDistance) {
				 bestDistance = distance;
				 bestTracing = currentNeighbor;
			}
		}
		return bestTracing;
	}
	
	private Tracing findNextNeighborToTheLeft(Tracing currentTracing, Vector<Tracing> tracings, Tracing mainTracing) {
		Point currentEndPoint = (currentTracing.first().x<currentTracing.last().x) ? currentTracing.first() : currentTracing.last();
		Tracing currentNeighbor = mainTracing;
		Point intersection = new Point();
		mainTracing.closestRightEdgeSegment(currentEndPoint, intersection);
		Point currentStartPoint = intersection;
		int currentXDistance = currentEndPoint.x - currentStartPoint.x; 
		double distance = currentStartPoint.distance(currentEndPoint);
		if (currentXDistance<0) distance += 9999999;
		double bestDistance = distance;
		Tracing bestTracing = mainTracing;
		Iterator<Tracing> it = tracings.iterator();
		double maxDistance = 30;
		while(it.hasNext()) {
			currentNeighbor = it.next();
			if (currentNeighbor==currentTracing) continue;
			currentStartPoint = (currentNeighbor.first().x<currentNeighbor.last().x) ? currentNeighbor.last() : currentNeighbor.first();
			currentXDistance = currentEndPoint.x - currentStartPoint.x; 
			distance = currentStartPoint.distance(currentEndPoint);
			if (currentXDistance<0 || distance>maxDistance) distance += 99999999;
			if (distance<bestDistance) {
				bestDistance = distance;
				bestTracing = currentNeighbor;
			}
		}
		return bestTracing;
	}

	protected Vector<Tracing> getLeftTracings(Tracing mainTracing) {
		Vector<Tracing> newTracings = new Vector<Tracing>();
		Iterator<Tracing> it = tracings.iterator();
		while(it.hasNext()) {
			Tracing aTracing = it.next();
			Point startPoint = aTracing.first();
			if (mainTracing.relativePositionOfPoint(startPoint)==-1) {
				newTracings.add(aTracing);
			}
		}
		return newTracings;
	}
	
	protected Vector<Tracing> getRightTracings(Tracing mainTracing) {
		Vector<Tracing> newTracings = new Vector<Tracing>();
		Iterator<Tracing> it = tracings.iterator();
		while(it.hasNext()) {
			Tracing aTracing = it.next();
			Point startPoint = aTracing.first();
			if (mainTracing.relativePositionOfPoint(startPoint)==1) {
				newTracings.add(aTracing);
			}
		}
		return newTracings;
	}

	protected void removeTracingsBelow(double d, Tracing mainTracing) {
		double yStart = (mainTracing.first().y<mainTracing.last().y) ? mainTracing.first().y : mainTracing.last().y;
		double yThreshold = yStart + (mainTracing.getYDistance() * d);
		Vector<Tracing> newTracings = new Vector<Tracing>();
		Iterator<Tracing> it = tracings.iterator();
		while(it.hasNext()) {
			Tracing aTracing = it.next();
			double yStart2 = (aTracing.first().y<aTracing.last().y) ? aTracing.first().y : aTracing.last().y;
			if (yStart2<yThreshold) {
				newTracings.add(aTracing);
			}
		}
		newTracings.add(mainTracing);
		this.tracings = newTracings;
	}

	public void makeTracingsUnique() {
		image = IJ.getImage();
		if (image==null) return;
		Vector<Tracing> newTracings = new Vector<Tracing>();
		byte[][] alreadySeen = new byte[image.getWidth()][image.getHeight()]; 
		this.sortTracingsByMeanIntensity();
		Iterator<Tracing> it = tracings.iterator();
		while(it.hasNext()) {
			Tracing currentTracing = it.next();
			Tracing newTracing = new Tracing();
			ArrayList<Point> centerPoints = currentTracing.center;
			int index = 0;
			for(Point currentPoint : centerPoints) {
				if (currentPoint.x<0 || currentPoint.y <0 || alreadySeen[currentPoint.x][currentPoint.y]!=0) {	// already seen
					if (newTracing.center.size()>2) {
						newTracings.add(newTracing);
					}
					newTracing = new Tracing();
					index++;
					continue;
				} else {
					Point left = (Point) currentTracing.leftEdge.get(index);
					Point right = (Point) currentTracing.rightEdge.get(index);
					Vector<Point> points = new Vector<Point>();
					points.addAll(currentTracing.getSegment(index));
					Iterator<Point> markPointIterator = points.iterator();
					while (markPointIterator.hasNext()) {
						Point aPoint = markPointIterator.next();
						if (aPoint.x<0 || aPoint.y<0) continue;
						alreadySeen[aPoint.x][aPoint.y] = 1;
					}
					newTracing.add(left, currentPoint, right);
				}
				if (newTracing.center.size()>2) {
					newTracings.add(newTracing);
				}
				index++;	
			}
		}
		this.tracings = newTracings;
	}

	public void splitCrossingBranches() {
		Iterator<Tracing> it = tracings.iterator();
		Vector<Tracing> newTracings = new Vector<Tracing>();
		while (it.hasNext()) {
			Tracing currentTracing = it.next();
			Iterator<Tracing> it2 = tracings.iterator();
			while (it2.hasNext()) {
				Tracing theOtherTracing = it2.next();
				if (theOtherTracing==currentTracing) continue;
				Vector<Tracing> tracings = splitTracing(currentTracing, theOtherTracing);
				newTracings.addAll(tracings);
			}
		}
		tracings = newTracings;
	}

	public void removeNotDescendingTracings(Tracing mainTracing) {
		Vector<Tracing> newTracings = new Vector<Tracing>();
		tracings.remove(mainTracing);
		Iterator<Tracing> it = this.tracings.iterator();
		while(it.hasNext()) {
			Tracing aTracing = it.next();
			int yStart, yEnd;
			if (mainTracing.relativePositionOfPoint(aTracing.first())==-1) {
				if (aTracing.first().x>=aTracing.last().x) {
					yStart = aTracing.first().y;
					yEnd = aTracing.last().y;
				} else {
					yStart = aTracing.last().y;
					yEnd = aTracing.first().y;
				}
			} else {
				if (aTracing.first().x<=aTracing.last().x) {
					yStart = aTracing.first().y;
					yEnd = aTracing.last().y;
				} else {
					yStart = aTracing.last().y;
					yEnd = aTracing.first().y;
				}
			}
			if (yEnd>yStart) newTracings.add(aTracing);
		}
		newTracings.add(mainTracing);
		this.tracings = newTracings;
	}

	public void removeAscendingTracings(Tracing mainTracing) {
		Vector<Tracing> newTracings = new Vector<Tracing>();
		tracings.remove(mainTracing);
		Iterator<Tracing> it = this.tracings.iterator();
		while(it.hasNext()) {
			Tracing aTracing = it.next();
			int yStart, yEnd;
			if (mainTracing.relativePositionOfPoint(aTracing.first())==-1) {
				if (aTracing.first().x>=aTracing.last().x) {
					yStart = aTracing.first().y;
					yEnd = aTracing.last().y;
				} else {
					yStart = aTracing.last().y;
					yEnd = aTracing.first().y;
				}
			} else {
				if (aTracing.first().x<=aTracing.last().x) {
					yStart = aTracing.first().y;
					yEnd = aTracing.last().y;
				} else {
					yStart = aTracing.last().y;
					yEnd = aTracing.first().y;
				}
			}
			if (yEnd>=yStart) newTracings.add(aTracing);
		}
		newTracings.add(mainTracing);
		this.tracings = newTracings;
	}
	protected Vector<Tracing> splitTracing(Tracing tracing, Tracing mainTracing) {
		Vector<Tracing> resultTracings = new Vector<Tracing>();
		Iterator<Point> it = tracing.center.iterator();
		Tracing currentTracing = new Tracing();
		int index = 0; 
		Point lastPoint = it.next();
		int lastPosition = mainTracing.relativePositionOfPoint(lastPoint);
		if (lastPosition!=0) currentTracing.add((Point)tracing.leftEdge.get(index), lastPoint, (Point)tracing.rightEdge.get(index));
		while (it.hasNext()) {
			Point currentPoint =it.next();
			index++;
			int currentPosition = mainTracing.relativePositionOfPoint(currentPoint);
			if (lastPosition==currentPosition && currentPosition!=0) {
				currentTracing.add((Point)tracing.leftEdge.get(index), currentPoint, (Point)tracing.rightEdge.get(index));
				lastPoint = currentPoint;
				lastPosition = currentPosition;
				continue;
			}
			if ((lastPosition==currentPosition) && currentPosition==0) {
				// skip
			} else {		// last position != currentPosition
					if (currentTracing.getCenterPolygonRoi().getLength()>2) resultTracings.add(currentTracing);
					currentTracing = new Tracing();
			}
			lastPoint = currentPoint;
			lastPosition = currentPosition;
		}
		if (currentTracing.getCenterPolygonRoi().getLength()>2) resultTracings.add(currentTracing);
		return resultTracings;
	}

	public void selectTracingContour(Object selectedValue) {
		Tracing aTracing = (Tracing) selectedValue;
		image.setRoi(aTracing.getContourRoi());
	}

	public void drawCenterlines() {
		image = IJ.getImage();
		if (image==null) return;
		Iterator<Tracing> it = tracings.iterator();
		while(it.hasNext()) {
			Tracing currentTracing = it.next();
			currentTracing.drawCenterlineOn(image);
		}
	}

	public void cycleColors(Object[] selectedValues) {
		image = IJ.getImage();
		Color[] colors = this.getColorCycle();
		for (int i=0; i<selectedValues.length; i++) {
			Tracing current = (Tracing) selectedValues[i];
			current.color = colors[i % 8];
		}
		image.updateAndDraw();
	}

	protected Color[] getColorCycle() {
		Color[] result = new Color[8];
		result[0] = Color.ORANGE;
		result[1] = Color.BLUE;
		result[2] = Color.YELLOW;
		result[3] = Color.PINK;
		result[4] = Color.GREEN;
		result[5] = Color.RED;
		result[6] = Color.CYAN;
		result[7] = Color.MAGENTA;
		return result;
	}

	public void removeTrees(Object[] selectedValues) {
		trees.removeAll(new Vector<Object>(Arrays.asList(selectedValues)));
		this.changed("trees");
	}
}

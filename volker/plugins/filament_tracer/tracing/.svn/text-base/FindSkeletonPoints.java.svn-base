package tracing;

import ij.ImagePlus;
import ij.WindowManager;

import java.awt.Point;
import java.util.ArrayList;
import java.util.Observable;
import java.util.Vector;

import operations.Operation;
import operations.tracing.FindSkeletonBranchingPointsOperation;
import operations.tracing.FindSkeletonEndPointsOperation;
import applications.Application;

public class FindSkeletonPoints extends Observable implements Runnable {
	protected ImagePlus image;
	protected Vector<Point> seeds;
	
	public FindSkeletonPoints(ImagePlus anImage) {
		image = anImage;
		seeds = new Vector<Point>();
	}
	
	public void run() {
		Application app = Application.load("./_applications/roots/skeletonize root.cia");
		WindowManager.setTempCurrentImage(image);
		ArrayList<Operation> operations = app.getOperations();
		app.removeOperation(operations.get(operations.size()-1));
		app.doIt();
		operations = app.getOperations();
		ImagePlus skeleton = (operations.get(operations.size()-1)).getResult();
		Vector<Point> seeds = new Vector<Point>();
		FindSkeletonBranchingPointsOperation op1 = new FindSkeletonBranchingPointsOperation();
		op1.setShowResult(false);
		op1.setInputImage(skeleton);
		op1.run();
		seeds.addAll(op1.getResultPoints());
		FindSkeletonEndPointsOperation op2 = new FindSkeletonEndPointsOperation();
		op2.setShowResult(false);
		op2.setInputImage(skeleton);
		op2.run();
		seeds.addAll(op2.getResultPoints());
		this.seeds.addAll(seeds);
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
}

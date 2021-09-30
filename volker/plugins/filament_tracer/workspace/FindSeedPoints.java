package workspace;

import ij.IJ;
import ij.ImageJ;
import ij.ImagePlus;
import ij.gui.WaitForUserDialog;
import tracing.FilamentTracer;
import tracing.SeedPointsFinder;
import tracing.TreeTracerOptions;

public class FindSeedPoints {
	 
	public static void main(String[] args) {
		new FindSeedPoints().run();
	}

	private TreeTracerOptions options;

	private void run() {
		new ImageJ();
		IJ.open("/media/baecker/donnees/mri/in/root-hair/roots/new/images 1/rotated/test.tif");
		IJ.run("Invert");
		IJ.run("Median...", "radius=5");
		FilamentTracer.traceFrom("57", "2186", "25", "300", "3");
		new WaitForUserDialog("ok").show();
		IJ.run("Revert");
	}
	
	
	
	private SeedPointsFinder newFinderFor(ImagePlus image) {
		TreeTracerOptions options = getOptions();
		SeedPointsFinder finder = SeedPointsFinder.newFor(image, Math.round(image.getHeight() * options.getHorizontalLinesFraction()), Math.round(image.getWidth()*options.getVerticalLinesFraction()));
		finder.setThresholdScalingFactor(options.getCanThresholdScalingFactor());
		finder.setMaxFilamentWidth(options.getMaxFilamentWidth());
		finder.setSnrRegionRadius(options.getSnrEstimationRegionRadius());
		return finder;
	}
	
	public TreeTracerOptions getOptions() {
		if (this.options == null) this.options = new TreeTracerOptions();
		return options;
	}
	
	protected FilamentTracer newTracerFor(ImagePlus image) {
		TreeTracerOptions options = getOptions();
		FilamentTracer.getOptions().setMaxFilamentWidth(options.getMaxFilamentWidth());
		FilamentTracer tracer = new FilamentTracer(image);
		tracer.setStepSize(options.getStepSize());
		tracer.setMinTracingLength(options.getMinTracingLength());
		SeedPointsFinder finder = newFinderFor(image);
		tracer.setFinder(finder);
		return tracer;
	}
}

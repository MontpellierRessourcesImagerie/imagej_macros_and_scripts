package analysis;

import ij.process.ImageProcessor;

public class ThresholdFinderUtil  {

	public static double getOtsuThresholdFor(ImageProcessor ip) {
		ip.resetThreshold();
		ip.setAutoThreshold("Otsu", true, ImageProcessor.NONE);
		return ip.getMinThreshold();
	}
}

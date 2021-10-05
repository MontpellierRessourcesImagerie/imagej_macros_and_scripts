package tracing;

import ij.ImagePlus;
import ij.process.ImageStatistics;

import java.util.Comparator;

public class TracingsMeanIntensityComparator implements Comparator<Tracing> {

	private ImagePlus image;

	public TracingsMeanIntensityComparator(ImagePlus image) {
		this.image = image;
	}

	public int compare(Tracing tracing1, Tracing tracing2) {
		image.setRoi((tracing1).getContourRoi());
		ImageStatistics stats = image.getStatistics(ImageStatistics.MEAN);
		double mean1 = stats.mean;
		image.setRoi((tracing2).getContourRoi());
		stats = image.getStatistics(ImageStatistics.MEAN);
		double mean2 = stats.mean;
		int result = 0;
		if (mean1<mean2) return -1;
		if (mean1>mean2) return 1;
		return result;
	}

}

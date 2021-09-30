package tracing;

import ij.ImagePlus;

import java.util.Comparator;

public class TracingsSNRComparator implements Comparator<Tracing> {

	private ImagePlus image;

	public TracingsSNRComparator(ImagePlus image) {
		this.image = image;
	}

	public int compare(Tracing tracing1, Tracing tracing2) {
		int result = 0;
		if ((tracing1).getSNR(image)<((Tracing) tracing2).getSNR(image)) result = -1;
		if ((tracing1).getSNR(image)>((Tracing) tracing2).getSNR(image)) result = 1;
		return result;
	}

}

import roi.RoiConverter;
import ij.ImagePlus;
import ij.plugin.filter.PlugInFilter;
import ij.process.ImageProcessor;


public class MRI_Roi_Converter implements PlugInFilter {

	@Override
	public int setup(String arg, ImagePlus imp) {
		return DOES_ALL + ROI_REQUIRED;
	}

	@Override
	public void run(ImageProcessor ip) {
		RoiConverter.replaceRoiWithFreelineRoi();
	}

}

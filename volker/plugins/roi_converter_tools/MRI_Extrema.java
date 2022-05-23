import ij.ImagePlus;
import ij.Macro;
import ij.process.ImageProcessor;
import roi.RoiConverter;


public class MRI_Extrema extends MRI_Roi_Converter {

	private int radius;

	@Override
	public int setup(String arg, ImagePlus imp) {
		this.radius = Integer.parseInt(Macro.getOptions().trim());
		return DOES_ALL + ROI_REQUIRED;
	}

	@Override
	public void run(ImageProcessor ip) {
		RoiConverter.replaceRoiWithPointSelectionOfExtrema(radius);
	}
}

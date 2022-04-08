
import ij.IJ;
import ij.plugin.*;

public class MRI_Roi_To_Line implements PlugIn {
    @Override
    public void run(String s) {
        RoiToLineTool roiToLineTool = new RoiToLineTool(IJ.getImage());
        roiToLineTool.run();
    }
}

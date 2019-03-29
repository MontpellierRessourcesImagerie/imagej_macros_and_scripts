import ij.IJ;
import ij.ImageJ;
import ij.ImagePlus;
import ij.gui.Overlay;
import ij.gui.PolygonRoi;
import ij.gui.Roi;
import ij.gui.ShapeRoi;
import ij.gui.WaitForUserDialog;
import ij.macro.ExtensionDescriptor;
import ij.macro.Functions;
import ij.macro.MacroExtension;
import ij.plugin.PlugIn;
import ij.plugin.frame.RoiManager;

public class MRI_Roi_Util implements PlugIn, MacroExtension {

	public void run(String arg) {
    if (!IJ.macroRunning()) {
      IJ.error("Cannot install extensions from outside a macro!");
      return;
    }  
    Functions.registerExtensions(this);
  }

    private ExtensionDescriptor[] extensions = {
      ExtensionDescriptor.newDescriptor("doRoisOverlap", this, ARG_ARRAY, ARG_ARRAY, ARG_ARRAY, ARG_ARRAY),
      ExtensionDescriptor.newDescriptor("isRoi2IncludedIn1", this, ARG_ARRAY, ARG_ARRAY, ARG_ARRAY, ARG_ARRAY),
      ExtensionDescriptor.newDescriptor("doRoisHaveNoOverlap", this, ARG_ARRAY, ARG_ARRAY, ARG_ARRAY, ARG_ARRAY)
  };

  public ExtensionDescriptor[] getExtensionFunctions() {
    return extensions;
  }

  public String handleExtension(String name, Object[] args) {
	if (args.length!=4) return null;
	float[] X1 = convertToFloatArray((Object[]) args[0]);
  	float[] Y1 = convertToFloatArray((Object[]) args[1]);
  	float[] X2 = convertToFloatArray((Object[]) args[2]);
  	float[] Y2 = convertToFloatArray((Object[]) args[3]);
    if (name.equals("doRoisOverlap")) {	
    	String result = this.doRoisOverlap(X1, Y1, X2, Y2);
    	return result;
    } 
    if (name.equals("isRoi2IncludedIn1")) {
    	String result = this.isRoi2IncludedIn1(X1, Y1, X2, Y2);
    	return result;
    } 
    if (name.equals("doRoisHaveNoOverlap")) {
    	String result = this.doRoisHaveNoOverlap(X1, Y1, X2, Y2);
    	return result;
    } 
    return null;
  }
  
  private float[] convertToFloatArray(Object[] array) {
	float[] result = new float[array.length];
	int i = 0;
	for (Object element : array) {
		float number = Float.parseFloat(element.toString());
		result[i++] = number;
	}
	return result;
  }

  /*
   * Do the rois overlap without one being completely included in the other?
   */
  String doRoisOverlap(float[] X1, float[] Y1, float[] X2, float[] Y2) {	
	boolean result = !isSubsetOf(X1, Y1, X2, Y2) && !isSubsetOf(X2, Y2, X1, Y1) && !isIntersectionEmpty(X1, Y1, X2, Y2);	
	return Boolean.toString(result);
  }

  /*
   * Is the second roi completely included in the first one?
   */
  String isRoi2IncludedIn1(float[] X1, float[] Y1, float[] X2, float[] Y2) {
	  boolean result = isSubsetOf(X1, Y1, X2, Y2);
	  return Boolean.toString(result);
  }
  
  /*
   * Do the rois have no overlap at all?
   */
  String doRoisHaveNoOverlap(float[] X1, float[] Y1, float[] X2, float[] Y2) {
	  boolean result = isIntersectionEmpty(X1, Y1, X2, Y2);
	  return Boolean.toString(result);
  }
  
private boolean isIntersectionEmpty(float[] X1, float[] Y1, float[] X2, float[] Y2) {
	PolygonRoi roi1 = new PolygonRoi(X1, Y1, Roi.TRACED_ROI);
	PolygonRoi roi2 = new PolygonRoi(X2, Y2, Roi.TRACED_ROI);
	ShapeRoi shape1 = new ShapeRoi(roi1);
	ShapeRoi shape2 = new ShapeRoi(roi2);
	ShapeRoi shape = shape2.and(shape1);
	float[] array = shape.getShapeAsArray();
	boolean result = (array==null || array.length==0);
	return result;
}

private boolean isSubsetOf(float[] X1, float[] Y1, float[] X2, float[] Y2) {
	PolygonRoi roi = new PolygonRoi(X1, Y1, Roi.TRACED_ROI);
	PolygonRoi subRoi = new PolygonRoi(X2, Y2, Roi.TRACED_ROI);
	ShapeRoi shape1 = new ShapeRoi(roi);
	ShapeRoi shape2 = new ShapeRoi(subRoi);
	ShapeRoi shape = shape2.not(shape1);
	
	float[] array = shape.getShapeAsArray();
	boolean result = (array==null || array.length==0);
	return result;
}

  public static void main(String[] args) {
	  new ImageJ();
	  IJ.open("/media/baecker/DONNEES/mri/in/yann/work/stack01-overlay.tif");
	  int size = IJ.getImage().getOverlay().size();
	  ImagePlus image = IJ.getImage();
	  Overlay overlay = image.getOverlay();
	  new RoiManager();
	  RoiManager rm = RoiManager.getInstance();
	  for (int i = 0; i<size; i++) {
		  rm.addRoi(overlay.get(i));
	  }
	  new WaitForUserDialog("Do something, then click OK.").show();
	  Roi roi = rm.getRoi(0);

	  float[] xpoints1 = roi.getFloatPolygon().xpoints; 
	  float[] ypoints1 = roi.getFloatPolygon().ypoints;
	  
	  roi = rm.getRoi(2);

	  float[] xpoints2 = roi.getFloatPolygon().xpoints; 
	  float[] ypoints2 = roi.getFloatPolygon().ypoints;
	  
	  MRI_Roi_Util roiUtil = new MRI_Roi_Util();
	  String result = roiUtil.doRoisOverlap(xpoints1, ypoints1, xpoints2, ypoints2);
	  System.out.println(result);
	  
  }
  
}

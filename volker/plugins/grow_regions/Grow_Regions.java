import org.python.bouncycastle.util.Arrays;

import ij.*;
import ij.process.*;
import ij.plugin.filter.*;

public class Grow_Regions implements PlugInFilter {
	ImagePlus imp;
	int width, height;

	public int setup(String arg, ImagePlus imp) {
		this.imp = imp;
		this.width = imp.getWidth();
		this.height = imp.getHeight();
		return DOES_8G+DOES_8C;
	}

	public void run(ImageProcessor ip) {
		boolean changedSomething = true;
		byte[] pixels = (byte[]) this.imp.getProcessor().getPixels();
		byte[] newPixels = Arrays.copyOf(pixels, pixels.length);
		int i = 0;
		while(changedSomething && i<1001) {
			IJ.log("\\Update0:generation " + i);
			changedSomething = this.attachPointsToNearestObjects(pixels, newPixels);
			if (changedSomething) {
				pixels = Arrays.copyOf(newPixels, newPixels.length);
				byte[] tmp = newPixels;
				newPixels = pixels;
				pixels = tmp;
			}
			i++;
		}
		this.imp.getProcessor().setPixels(newPixels);
		this.imp.getProcessor().setSnapshotPixels(null);
		this.imp.setProcessor(this.imp.getProcessor());
		this.imp.updateAndDraw();
		WindowManager.setCurrentWindow(imp.getWindow());
	}

	private boolean attachPointsToNearestObjects(byte[] pixels, byte[] newPixels) {
		boolean changedSomething = false;
		for (int x=0; x<width; x++) {
			for (int y=0; y<height; y++) {
					int v=0, n1=0, n2=0, n3=0, n4=0;
					v = pixels[y*width+x]&0xff;
					if (v==0) {
						n1 = 0;
						if (y>=1) n1=pixels[(y-1)*width+x]&0xff;
						if (n1==255) n1 = 0;
						
						n2 = 0;
						if (x<(width-1)) n2=pixels[y*width+(x+1)]&0xff;
						if (n2==255) n2 = 0;
						
						n3 = 0;
						if (x>=1) n3=pixels[y*width+(x-1)]&0xff;
						if (n3==255) n3 = 0;
						
						n4 = 0;
						if (y<(height-1)) n4=pixels[(y+1)*width+x]&0xff;
						if (n4==255) n4 = 0;
						
						int max = Math.max(Math.max(n1, n2), Math.max(n3,n4));
						if (max>0) {
							newPixels[y*width+x] = (byte)max;
							changedSomething = true;
						} 
					}
			}
		}
		return changedSomething;
	}

	public static void main(String[] args) {
		new ImageJ();
		IJ.getInstance().setVisible(true);
		ImagePlus image = IJ.openImage("/media/baecker/donnees/mri/in/Jolanta Jagodzinska/new/wetransfer-390e37/test.tif");
		image.show();
		Grow_Regions gr = new Grow_Regions();
		gr.setup("", IJ.getImage());
		gr.run(IJ.getProcessor());
	}
}

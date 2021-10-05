package tracing;

public class SeedPointsFinderFloat extends SeedPointsFinder {

	public SeedPointsFinderFloat(float[] data, int hLines, int vLines, int width, int height) {
		super(data, hLines, vLines, width, height);
		// TODO Auto-generated constructor stub
	}

	public float getHPixel(int line, int index) {
		int i = hStepSize * line;
		int pos = i*width+index;
		return (((float[])(this.data))[pos]);
	}

	public float getVPixel(int line, int index) {
		int i = vStepSize * line;
		int pos = index*width+i;
		return (((float[])(this.data))[pos]);
	}
	
	public float getPixel(int x, int y) {
		int pos = y*width+x;
		return (((float[])(this.data))[pos]);
	}

}

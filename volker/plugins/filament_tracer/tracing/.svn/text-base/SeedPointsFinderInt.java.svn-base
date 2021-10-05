package tracing;

public class SeedPointsFinderInt extends SeedPointsFinder {

	public SeedPointsFinderInt(int[] data, int hLines, int vLines, int width, int height) {
		super(data, hLines, vLines, width, height);
		// TODO Auto-generated constructor stub
	}

	public float getHPixel(int line, int index) {
		int i = hStepSize * line;
		int pos = i*width+index;
		int c = (((int[])(this.data))[pos]);
		int[] iArray = new int[3];
		iArray[0] = (c&0xff0000)>>16;
		iArray[1] = (c&0xff00)>>8;
		iArray[2] = c&0xff;
		return iArray[0] + iArray[1] + iArray[2];
	}

	public float getVPixel(int line, int index) {
		int i = vStepSize * line;
		int pos = index*width+i;
		int c = (((int[])(this.data))[pos]);
		int[] iArray = new int[3];
		iArray[0] = (c&0xff0000)>>16;
		iArray[1] = (c&0xff00)>>8;
		iArray[2] = c&0xff;
		return iArray[0] + iArray[1] + iArray[2];
	}
	public float getPixel(int x, int y) {
		int pos = y*width+x;
		int c = (((int[])(this.data))[pos]);
		int[] iArray = new int[3];
		iArray[0] = (c&0xff0000)>>16;
		iArray[1] = (c&0xff00)>>8;
		iArray[2] = c&0xff;
		return iArray[0] + iArray[1] + iArray[2];
	}
}

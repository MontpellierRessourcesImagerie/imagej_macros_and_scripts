package tracing;

public class SeedPointsFinderByte extends SeedPointsFinder {

	public SeedPointsFinderByte(byte[] data, int hLines, int vLines, int width, int height) {
		super(data, hLines, vLines, width, height);
		// TODO Auto-generated constructor stub
	}

	public float getHPixel(int line, int index) {
		int i = hStepSize * line;
		int pos = i*width+index;
		return (((byte[])(this.data))[pos])&0xff;
	}

	public float getVPixel(int line, int index) {
		int i = vStepSize * line;
		int pos = index*width+i;
		return (((byte[])(this.data))[pos])&0xff;
	}

	public float getPixel(int x, int y) {
		int pos = y*width+x;
		return (((byte[])(this.data))[pos])&0xff;
	}

}

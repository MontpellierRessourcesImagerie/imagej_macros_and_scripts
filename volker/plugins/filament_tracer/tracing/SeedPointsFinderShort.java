package tracing;

public class SeedPointsFinderShort extends SeedPointsFinder {

	public SeedPointsFinderShort(short[] data, int hLines, int vLines, int width, int height) {
		super(data, hLines, vLines, width, height);
		// TODO Auto-generated constructor stub
	}

	public float getHPixel(int line, int index) {
		int i = hStepSize * line;
		int pos = i*width+index;
		return (((short[])(this.data))[pos])&0xffff;
	}

	public float getVPixel(int line, int index) {
		int i = vStepSize * line;
		int pos = index*width+i;
		return (((short[])(this.data))[pos])&0xffff;
	}
	
	public float getPixel(int x, int y) {
		int pos = y*width+x;
		return (((short[])(this.data))[pos])&0xffff;
	}

}

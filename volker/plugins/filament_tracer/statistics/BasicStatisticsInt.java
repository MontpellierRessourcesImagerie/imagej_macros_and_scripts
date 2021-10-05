package statistics;

import java.util.Arrays;

public class BasicStatisticsInt extends BasicStatistics {

	public BasicStatisticsInt(int[] data) {
		super(data);
		length = data.length;
	}
	
	public double valueAt(int index) {
		int c = (((int[])(this.data))[index]);
		int[] iArray = new int[3];
		iArray[0] = (c&0xff0000)>>16;
		iArray[1] = (c&0xff00)>>8;
		iArray[2] = c&0xff;
		return iArray[0] + iArray[1] + iArray[2];
	}
	
	protected Object copyData() {
		int[] result = new int[length];
		System.arraycopy((int[]) data, 0, result, 0, length);
		return result;
	}

	protected void sort(Object sortedData) {
		Arrays.sort((int[])sortedData);
	}

	public double valueAt(int index, Object data) {
		int c = (((int[])(data))[index]);
		int[] iArray = new int[3];
		iArray[0] = (c&0xff0000)>>16;
		iArray[1] = (c&0xff00)>>8;
		iArray[2] = c&0xff;
		return iArray[0] + iArray[1] + iArray[2];
	}

}

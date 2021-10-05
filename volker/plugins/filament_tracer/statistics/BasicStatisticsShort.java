package statistics;

import java.util.Arrays;

public class BasicStatisticsShort extends BasicStatistics {

	public BasicStatisticsShort(short[] data) {
		super(data);
		length = data.length;
	}

	protected Object copyData() {
		short[] result = new short[length];
		System.arraycopy((short[]) data, 0, result, 0, length);
		return result;
	}

	protected void sort(Object sortedData) {
		Arrays.sort((short[])sortedData);
	}
	
	public double valueAt(int index) {
		return (((short[])(this.data))[index])&0xffff;
	}

	public double valueAt(int index, Object data) {
		return (((short[])(data))[index])&0xffff;
	}
}

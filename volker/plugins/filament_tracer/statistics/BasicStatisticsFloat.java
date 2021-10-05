package statistics;

import java.util.Arrays;

public class BasicStatisticsFloat extends BasicStatistics {

	public BasicStatisticsFloat(float[] data) {
		super(data);
		length = data.length;
	}

	public double valueAt(int index) {
		return (((float[])(this.data))[index]);
	}
	
	protected Object copyData() {
		float[] result = new float[length];
		System.arraycopy((float[]) data, 0, result, 0, length);
		return result;
	}

	protected void sort(Object sortedData) {
		Arrays.sort((float[])sortedData);
	}

	public double valueAt(int index, Object data) {
		return (((float[])(data))[index]);
	}
}

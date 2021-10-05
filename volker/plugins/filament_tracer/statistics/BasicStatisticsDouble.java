package statistics;

import java.util.Arrays;

public class BasicStatisticsDouble extends BasicStatistics {

	public BasicStatisticsDouble(double[] data) {
		super(data);
		length = data.length;
	}

	@Override
	protected Object copyData() {
		double[] result = new double[length];
		System.arraycopy((double[]) data, 0, result, 0, length);
		return result;
	}

	@Override
	protected void sort(Object sortedData) {
		Arrays.sort((double[])sortedData);
	}

	@Override
	public double valueAt(int index) {
		return (((double[])(this.data))[index]);
	}

	@Override
	public double valueAt(int index, Object data) {
		return (((double[])(data))[index]);
	}

}

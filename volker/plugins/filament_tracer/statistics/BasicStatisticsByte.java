package statistics;

import java.util.Arrays;

public class BasicStatisticsByte extends BasicStatistics {

	public BasicStatisticsByte(byte[] data) {
		super(data);
		length = data.length;
	}

	public double valueAt(int index) {
		return (((byte[])(this.data))[index])&0xff;
	}

	protected Object copyData() {
		byte[] result = new byte[length];
		System.arraycopy((byte[]) data, 0, result, 0, length);
		return result;
	}

	protected void sort(Object sortedData) {
		Arrays.sort((byte[])sortedData);
	}

	public double valueAt(int index, Object data) {
		return (((byte[])(data))[index])&0xff;
	}
}

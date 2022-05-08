package fr.cnrs.mri.files.tests;

import java.util.zip.Checksum;
import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import fr.cnrs.mri.files.MD5;

public class MD5Test {

	private Checksum checksum;
	private byte[] data;
	private long result;

	@Before
	public void setUp() throws Exception {
		data = new byte[8];
		data[0] = 1;
		data[1] = 2;
		data[2] = 3;
		data[3] = 4;
		data[4] = 5;
		data[5] = 6;
		data[6] = 7;
		data[7] = 8;
		checksum = new MD5();
		result = Long.parseLong("1071967126811039763");
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void testGetValue() {
		checksum.update(data, 0, data.length);
		Assert.assertTrue(checksum.getValue()==result);
	}

	@Test
	public void testReset() {
		checksum.update(data[0]);
		checksum.update(data, 0, data.length);
		Assert.assertTrue(checksum.getValue()!=result);
		checksum.reset();
		checksum.update(data[0]);
		checksum.reset();
		checksum.update(data, 0, data.length);
		Assert.assertTrue(checksum.getValue()==result);
	}

	@Test
	public void testUpdateInt() {
		checksum.update(data[0]);
		checksum.update(data[1]);
		checksum.update(data[2]);
		checksum.update(data[3]);
		checksum.update(data[4]);
		checksum.update(data[5]);
		checksum.update(data[6]);
		checksum.update(data[7]);
		Assert.assertTrue(checksum.getValue()==result);
	}

	@Test
	public void testUpdateByteArrayIntInt() {
		byte[] data1 = new byte[4];
		byte[] data2 = new byte[4];
		data1[0] = data[0];
		data1[1] = data[1];
		data1[2] = data[2];
		data1[3] = data[3];
		data2[0] = data[4];
		data2[1] = data[5];
		data2[2] = data[6];
		data2[3] = data[7];
		checksum.update(data1, 0, data1.length);
		checksum.update(data2, 0, data2.length);
		Assert.assertTrue(checksum.getValue()==result);
	}
}

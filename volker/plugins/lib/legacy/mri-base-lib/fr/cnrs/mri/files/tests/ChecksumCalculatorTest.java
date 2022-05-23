package fr.cnrs.mri.files.tests;

import java.io.File;
import java.util.zip.Adler32;
import java.util.zip.CRC32;
import junit.framework.Assert;
import org.junit.Before;
import org.junit.Test;

import fr.cnrs.mri.files.ChecksumCalculator;
import fr.cnrs.mri.files.MD5;
import fr.cnrs.mri.testData.TestImages;

public class ChecksumCalculatorTest {

	private String path, path2, path3;

	@Before
	public void setUp() throws Exception {
		path = TestImages.image01Head();
		path2 = TestImages.image02Head();
		path3 = TestImages.imageOrgan_of_corti();
	}

	@Test
	public void testChecksumCalculator() {
		ChecksumCalculator calc = new ChecksumCalculator(new File(path));
		Assert.assertTrue(calc.getChunkSize()>0);
		Assert.assertTrue(calc.getChunkSize()<=Integer.MAX_VALUE);
	}

	@Test
	public void testSetAlgorithm() {
		ChecksumCalculator calc = new ChecksumCalculator(new File(path));
		calc.setAlgorithm(new CRC32());
		String checksum1 = calc.getChecksum();
		calc.setAlgorithm(new Adler32());
		String checksum2 = calc.getChecksum();
		Assert.assertFalse(checksum1.equals(checksum2));
		calc.setAlgorithm(new MD5());
		String checksum3 = calc.getChecksum();
		Assert.assertFalse(checksum1.equals(checksum3));
	}

	@Test
	public void testGetChecksum() {
		ChecksumCalculator calc = new ChecksumCalculator(new File(path));
		String checksum1 = calc.getChecksum();
		calc = new ChecksumCalculator(new File(path2));
		String checksum2 = calc.getChecksum();
		Assert.assertTrue(checksum1.equals(checksum2));
		calc = new ChecksumCalculator(new File(path3));
		String checksum3 = calc.getChecksum();
		Assert.assertFalse(checksum1.equals(checksum3));
	}

	@Test
	public void testGetChunkSize() {
		ChecksumCalculator calc = new ChecksumCalculator(new File(path));
		int chunkSize = 5 * 1024 * 1024;
		calc.setChunkSize(chunkSize);
		Assert.assertTrue(calc.getChunkSize()==chunkSize);
	}

	@Test
	public void testSetChunkSize() {
		ChecksumCalculator calc = new ChecksumCalculator(new File(path));
		int chunkSize = 1 * 1024 * 1024;
		calc.setChunkSize(chunkSize);
		String checksum1 = calc.getChecksum();
		calc = new ChecksumCalculator(new File(path2));
		chunkSize = 5 * 1024 * 1024;
		calc.setChunkSize(chunkSize);
		String checksum2 = calc.getChecksum();
		Assert.assertTrue(checksum1.equals(checksum2));
	}
}

package fr.cnrs.mri.files.tests;

import java.sql.Timestamp;
import junit.framework.Assert;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import fr.cnrs.mri.files.FileInformation;
import fr.cnrs.mri.testData.TestImages;

public class FileInformationTest {

	private String path, path2;
	private String path3;

	@Before
	public void setUp() throws Exception {
		path = TestImages.image01Head();
		path2 = TestImages.image02Head();
		path3 = TestImages.imageOrgan_of_corti();
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void testFileInformation() {
		FileInformation fileInformation = new FileInformation(path);
		Assert.assertTrue(fileInformation.getFullPath().equals(path));
		Assert.assertTrue(fileInformation.existsFile());
		String path2 = TestImages.path+"01/head2.tif";
		fileInformation = new FileInformation(path2);
		Assert.assertTrue(fileInformation.getFullPath().equals(path2));
		Assert.assertFalse(fileInformation.existsFile());
	}

	@Test
	public void testGetCRC32Checksum() {
		FileInformation fileInformation = new FileInformation(path);
		FileInformation fileInformation2 = new FileInformation(path2);
		String checksum = fileInformation.getCRC32Checksum();
		String checksum2 = fileInformation2.getCRC32Checksum();
		Assert.assertTrue(checksum.equals(checksum2));
		FileInformation fileInformation3 = new FileInformation(path3);
		String checksum3 = fileInformation3.getCRC32Checksum();
		Assert.assertFalse(checksum.equals(checksum3));
	}

	@Test
	public void testGetMD5Checksum() {
		FileInformation fileInformation = new FileInformation(path);
		FileInformation fileInformation2 = new FileInformation(path2);
		String checksum = fileInformation.getMD5Checksum();
		String checksum2 = fileInformation2.getMD5Checksum();
		Assert.assertTrue(checksum.equals(checksum2));
		FileInformation fileInformation3 = new FileInformation(path3);
		String checksum3 = fileInformation3.getMD5Checksum();
		Assert.assertFalse(checksum.equals(checksum3));
	}
	
	@Test
	public void testGetCreationDate() {
		FileInformation fileInformation = new FileInformation(path);
		FileInformation fileInformation2 = new FileInformation(path2);
		Timestamp date = fileInformation.getCreationDate();
		Timestamp date2 = fileInformation2.getCreationDate();
		Assert.assertTrue(date2.getTime()-date.getTime()<1000*60*5);
	}

	@Test
	public void testGetModificationDate() {
		FileInformation fileInformation = new FileInformation(path);
		FileInformation fileInformation2 = new FileInformation(path2);
		Timestamp date = fileInformation.getModificationDate();
		Timestamp date2 = fileInformation2.getModificationDate();
		Assert.assertTrue(date2.getTime()-date.getTime()<1000*60*5);
	}

	@Test
	public void testGetChunkSize() {
		FileInformation fileInformation = new FileInformation(path);
		Assert.assertTrue(fileInformation.getChunkSize()>0);
		int newSize = 1024*1024*10;
		fileInformation.setChunkSize(newSize);
		Assert.assertTrue(fileInformation.getChunkSize()==newSize);
	}
	
	@Test
	public void testGetFullPath() {
		FileInformation fileInformation = new FileInformation(path);
		Assert.assertTrue(fileInformation.getFullPath().equals(path));
	}
	
	@Test
	public void testExistsFile() {
		FileInformation fileInformation = new FileInformation(path);
		Assert.assertTrue(fileInformation.existsFile());
		FileInformation fileInformation2 = new FileInformation("plumperquatsch");
		Assert.assertFalse(fileInformation2.existsFile());
	}
	
	@Test
	public void testGetSize() {
		FileInformation fileInformation = new FileInformation(path);
		Assert.assertTrue(fileInformation.getSize()==16933237);
	}
}

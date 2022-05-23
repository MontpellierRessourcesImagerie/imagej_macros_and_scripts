package fr.cnrs.mri.util.tests;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import java.io.File;
import java.io.IOException;
import org.junit.Test;
import junit.framework.Assert;
import fr.cnrs.mri.testData.TestImages;
import fr.cnrs.mri.util.FileUtil;

public class FileUtilTest {
	
	@Test
	public void testConstructor() {
		assertNotNull(new FileUtil());
	}
	@Test
	public void testGetExtension() {
		Assert.assertTrue(FileUtil.getExtension("test.tif").equals("tif"));
		Assert.assertTrue(FileUtil.getExtension("test").equals(""));
		Assert.assertTrue(FileUtil.getExtension("test.TIF").equals("tif"));
		Assert.assertTrue(FileUtil.getExtension("test.tar.gz").equals("gz"));
	}
	
	@Test
	public void testDeleteFolder () throws IOException{
		File folderTest = new File(TestImages.outputPath + "folder1/folder2");
		File folderTest2 = new File(TestImages.outputPath +"folder");
		File fileTest = new File(TestImages.outputPath+ "folder1/folder2/test.txt");
		folderTest.mkdirs();
		folderTest2.mkdir();
		fileTest.createNewFile();
		Assert.assertTrue(fileTest.exists());
		Assert.assertTrue(folderTest.exists());
		Assert.assertTrue(folderTest2.exists());
		Assert.assertTrue(FileUtil.deleteFolder(folderTest.getParent()));
		Assert.assertTrue(FileUtil.deleteFolder(folderTest2.getAbsolutePath()));
		Assert.assertFalse(fileTest.exists());
		Assert.assertFalse(folderTest.exists());
		Assert.assertFalse(folderTest2.exists());
		Assert.assertFalse(FileUtil.deleteFolder(""));
	}
	
	@Test 
	public void testGetNameWithoutExtension() {
		assertEquals("cell", FileUtil.getNameWithoutExtension("cell.tif"));
		assertEquals("cell", FileUtil.getNameWithoutExtension("cell"));
	}
}

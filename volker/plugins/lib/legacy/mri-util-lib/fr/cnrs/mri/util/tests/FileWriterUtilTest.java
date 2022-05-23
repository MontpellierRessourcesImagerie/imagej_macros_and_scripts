package fr.cnrs.mri.util.tests;

import static org.junit.Assert.assertNotNull;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import org.junit.Assert;
import org.junit.Test;
import fr.cnrs.mri.files.FileInformation;
import fr.cnrs.mri.testData.TestImages;
import fr.cnrs.mri.util.FileUtil;
import fr.cnrs.mri.util.FileWriterUtil;
import fr.cnrs.mri.util.TimeAndDateUtil;

public class FileWriterUtilTest {
	
	@Test
	public void testConstructor() {
		assertNotNull(new FileWriterUtil());
	}
	
	@Test
	public void testWriteData() throws IOException {
		byte[] data = new byte[8];
		for (byte i=0; i<8 ;i++) data[i] = (byte) (i+1);
		String path = TestImages.path + "test.data";
		FileOutputStream outStream = new FileOutputStream(path);
		FileWriterUtil.writeData(data, outStream);
		FileInputStream inStream = new FileInputStream(path);
		byte[] inData = new byte[8];
		inStream.read(inData);
		inStream.close();
		boolean ok = true;
		for (byte b : inData) {
			if (data[b-1]!=b) ok=false;
		}
		Assert.assertTrue(ok);
		byte[] newData = new byte[1];
		newData[0]=9;
		outStream = new FileOutputStream(path, true);
		FileWriterUtil.writeData(newData, outStream);
		inStream = new FileInputStream(path);
		inData = new byte[9];
		inStream.read(inData);
		inStream.close();
		for (byte b : inData) {
			if (inData[b-1]!=b) ok=false;
		}
		Assert.assertTrue(ok);
		new File(path).delete();
	}

	@Test
	public void testGetOutputStreamForFile() throws IOException {
		String path = TestImages.path + "test.data";
		FileOutputStream stream = FileWriterUtil.getOutputStreamForFile(path, false);
		stream.write(1);
		stream.write(2);
		stream.write(3);
		stream.write(4);
		stream.write(5);
		stream.close();
		stream = FileWriterUtil.getOutputStreamForFile(path, true);
		stream.write(6);
		stream.write(7);
		stream.write(8);
		stream.close();
		byte[] inData = new byte[8];
		FileInputStream inStream = new FileInputStream(path);
		inStream.read(inData);
		inStream.close();
		boolean ok = true;
		for (byte b : inData) {
			if (inData[b-1]!=b) ok=false;
		}
		Assert.assertTrue(ok);
		stream = FileWriterUtil.getOutputStreamForFile(path, false);
		stream.write(9);
		stream.close();
		inData = new byte[8];
		inStream = new FileInputStream(path);
		inStream.read(inData);
		inStream.close();
		Assert.assertTrue(inData[0]==9);
		new File(path).delete();
	}

	@Test
	public void testCopyFile () {
		String sourceFile = TestImages.imageBridge();
		FileInformation information = new  FileInformation(sourceFile);		
		String destinationFile = TestImages.outputPath
		+ "/home/stagiaire/" + TimeAndDateUtil.getDateFor(information.getCreationDate()) 
		+ "/10." + FileUtil.getExtension(sourceFile);

		File fileSource = new File(sourceFile);
		File fileDestination = new File(destinationFile);
		Assert.assertTrue(fileSource.exists());
		Assert.assertFalse(fileDestination.exists());
		
		Assert.assertTrue(FileWriterUtil.copyFile(sourceFile, destinationFile));
		Assert.assertTrue(fileDestination.exists());
		Assert.assertTrue(fileDestination.delete());
		new File(TestImages.outputPath	+ "/home//stagiaire/" + TimeAndDateUtil.getDateFor(information.getCreationDate())).delete();
		new File(TestImages.outputPath	+ "/home//stagiaire/").delete();
		new File(TestImages.outputPath	+ "/home/").delete();
		
	}
}

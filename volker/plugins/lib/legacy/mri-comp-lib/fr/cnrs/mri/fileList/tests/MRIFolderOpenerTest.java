package fr.cnrs.mri.fileList.tests;

import static org.junit.Assert.*;
import ij.ImagePlus;
import ij.gui.NewImage;
import ij.io.FileSaver;
import java.io.File;
import java.io.IOException;
import org.junit.Before;
import org.junit.Test;

import fr.cnrs.mri.dialog.ModalDialogKiller;
import fr.cnrs.mri.fileList.MRIFolderOpener;
import fr.cnrs.mri.testData.TestConfig;

public class MRIFolderOpenerTest {

	private MRIFolderOpener folderOpener;

	@Before
	public void setUp() throws Exception {
		folderOpener = new MRIFolderOpener();
	}

	@Test
	public void testRun() throws IOException {
		File bTif = new File(TestConfig.testFolder + "/b.tif");
		File aTif = new File(TestConfig.testFolder + "/a.tif");
		bTif.createNewFile();
		aTif.createNewFile();
		folderOpener.run(TestConfig.testFolder);
		bTif.delete();
		aTif.delete();
	}

	@Test
	public void testGetFileList() throws InterruptedException {
		ImagePlus imageB = NewImage.createByteImage("testB.tif", 10, 10, 1, NewImage.FILL_BLACK);
		ImagePlus imageA = NewImage.createByteImage("testA.tif", 10, 10, 1, NewImage.FILL_BLACK);
		FileSaver saver = new FileSaver(imageB);
		saver.saveAsTiff(TestConfig.testFolder + "testB.tif");
		saver = new FileSaver(imageA);
		saver.saveAsTiff(TestConfig.testFolder + "testA.tif");
		ModalDialogKiller mdk = new ModalDialogKiller();
		mdk.start();
		folderOpener.run(TestConfig.testFolder);
		mdk.stop();
		assertEquals(2, folderOpener.getFileList().length);
		assertTrue(folderOpener.getFileList()[0].getName().contains("testA"));
		assertTrue(folderOpener.getFileList()[1].getName().contains("testB"));
		new File(TestConfig.testFolder + "testB.tif").delete();
		new File(TestConfig.testFolder + "testA.tif").delete();
	}

}

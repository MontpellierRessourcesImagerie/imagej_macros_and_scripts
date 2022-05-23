package fr.cnrs.mri.fileList.tests;

import static org.junit.Assert.*;
import ij.ImagePlus;
import ij.io.FileInfo;
import org.junit.Before;
import org.junit.Test;
import fr.cnrs.mri.fileList.FolderOpenerProxy;
import fr.cnrs.mri.fileList.MRIFolderOpener;
import fr.cnrs.mri.dialog.ModalDialogKiller;

public class FolderOpenerProxyTest {

	private FolderOpenerProxy fop;
	private MRIFolderOpener folderOpener;

	@Before
	public void setUp() {
		folderOpener = new MRIFolderOpener();
		fop = new FolderOpenerProxy(folderOpener);
	}

	@Test
	public void testSetFi() {
		FileInfo info = new FileInfo();
		info.directory = "/test";
		info.description = "A test image";
		fop.setFi(info);
		assertEquals(info, fop.getSuperclassField(folderOpener, "fi"));
	}

	@Test
	public void testShowDialog() {
		String[] choices = {"a", "b"};
		ModalDialogKiller mdk = new ModalDialogKiller();
		mdk.start();
		boolean result = fop.showDialog(new ImagePlus(), choices);
		mdk.stop();
		assertTrue(result);
	}

	@Test
	public void testGetFilter() {
		fop.setFilter("*.tif");
		assertEquals(fop.getFilter(), "*.tif");
	}
}


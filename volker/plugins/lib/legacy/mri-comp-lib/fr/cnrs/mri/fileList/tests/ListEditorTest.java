package fr.cnrs.mri.fileList.tests;

import static org.junit.Assert.*;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.swing.filechooser.FileSystemView;

import org.junit.Before;
import org.junit.Test;
import fr.cnrs.mri.fileList.ListEditor;
import fr.cnrs.mri.testData.TestConfig;

public class ListEditorTest {

	private ListEditor listEditor;

	@Before
	public void setUp() throws Exception {
		File testFolder = new File(TestConfig.testFolder);
		if (!testFolder.exists()) testFolder.mkdir();
		listEditor = new ListEditor();
	}

	@Test
	public void testView() {
		assertEquals("list editor", listEditor.view().getTitle());
	}

	@Test
	public void testGetTiffFileFilter() {
		assertTrue(ListEditor.getTiffFileFilter().accept(new File("test.tif")));
		assertTrue(ListEditor.getTiffFileFilter().accept(new File("test.tiff")));
		assertTrue(ListEditor.getTiffFileFilter().accept(new File("test.TIF")));
		assertTrue(ListEditor.getTiffFileFilter().accept(new File("test.TIFF")));
		assertFalse(ListEditor.getTiffFileFilter().accept(new File("test.gif")));
	}

	@Test
	public void testGetImageFileFilter() {
		assertTrue(ListEditor.getImageFileFilter().accept(new File("test.tif")));
		assertTrue(ListEditor.getImageFileFilter().accept(new File("test.tiff")));
		assertTrue(ListEditor.getImageFileFilter().accept(new File("test.TIF")));
		assertTrue(ListEditor.getImageFileFilter().accept(new File("test.TIFF")));
		assertTrue(ListEditor.getImageFileFilter().accept(new File("test.gif")));
		assertTrue(ListEditor.getImageFileFilter().accept(new File("test.GIF")));
		assertTrue(ListEditor.getImageFileFilter().accept(new File("test.jpg")));
		assertTrue(ListEditor.getImageFileFilter().accept(new File("test.JPG")));
		assertTrue(ListEditor.getImageFileFilter().accept(new File("test.bmp")));
		assertTrue(ListEditor.getImageFileFilter().accept(new File("test.BMP")));
		assertTrue(ListEditor.getImageFileFilter().accept(new File("test.pgm")));
		assertTrue(ListEditor.getImageFileFilter().accept(new File("test.PGM")));
		assertTrue(ListEditor.getImageFileFilter().accept(new File("test.stk")));
		assertTrue(ListEditor.getImageFileFilter().accept(new File("test.STK")));
		assertFalse(ListEditor.getImageFileFilter().accept(new File("test.txt")));
	}

	@Test
	public void testAddToListFileArrayFileFilter() throws IOException {
		File inDir = new File(TestConfig.testFolder + "/in/");
		inDir.mkdir();
		File aDir = new File(TestConfig.testFolder + "/in/a/");
		aDir.mkdir();
		File bDir = new File(TestConfig.testFolder + "/in/b/");
		bDir.mkdir();
		File inTif = new File(TestConfig.testFolder + "/in/in.tif");
		inTif.createNewFile();
		File aBmp = new File(TestConfig.testFolder + "/in/a/a.bmp");
		aBmp.createNewFile();
		File bTxt = new File(TestConfig.testFolder + "/in/b/b.txt");
		bTxt.createNewFile();
		File[] files = new File[1];assertTrue(ListEditor.getImageFileFilter().accept(new File("test.tif")));
		files[0] = inDir;
		listEditor.addToList(files, ListEditor.getImageFileFilter());
		List<File> fileList = listEditor.getList();
		assertTrue(fileList.contains(inTif));
		assertTrue(fileList.contains(aBmp));
		assertEquals(2, fileList.size());
		bTxt.delete();
		aBmp.delete();
		inTif.delete();
		bDir.delete();
		aDir.delete();
		inDir.delete();
	}

	@Test
	public void testAddToListFileArray() {
		File[] files = new File[3];
		files[0] = new File(TestConfig.testFolder + "/in/in.tif");
		files[1] = new File(TestConfig.testFolder + "/in/a/a.bmp");
		files[2] = new File(TestConfig.testFolder + "/in/b/b.txt");
		listEditor.addToList(files);
		List<File> fileList = listEditor.getList();
		assertTrue(fileList.contains(files[0]));
		assertTrue(fileList.contains(files[1]));
		assertTrue(fileList.contains(files[2]));
		assertEquals(3, fileList.size());
	}

	@Test
	public void testGetList() {
		assertTrue(listEditor.getList().isEmpty());
		File[] files = new File[1];
		files[0] = new File("a.file");
		listEditor.addToList(files);
		List<File> fileList = listEditor.getList();
		assertTrue(fileList.contains(files[0]));
		assertEquals(1, fileList.size());
		File[] moreFiles = new File[2];
		moreFiles[0] = new File("b.file");
		moreFiles[1] = new File("c.file");
		listEditor.addToList(moreFiles);
		fileList = listEditor.getList();
		assertEquals(3, fileList.size());
	}

	@Test
	public void testRemoveElementsFromList() {
		File[] files = new File[3];
		files[0] = new File(TestConfig.testFolder + "/in/in.tif");
		files[1] = new File(TestConfig.testFolder + "/in/a/a.bmp");
		files[2] = new File(TestConfig.testFolder + "/in/b/b.txt");
		listEditor.addToList(files);
		assertEquals(3, listEditor.getList().size());
		File[] toBeRemoved = new File[2];
		toBeRemoved[0] = files[0];
		toBeRemoved[1] = files[2];
		listEditor.removeElementsFromList(toBeRemoved);
		assertEquals(1, listEditor.getList().size());
	}

	@Test
	public void testSetList() {
		List<File> files = new ArrayList<File>();
		files.add(new File("a.file"));
		files.add(new File("b.file"));
		files.add(new File("c.file"));
		files.add(new File("d.file"));
		listEditor.setList(files);
		assertEquals(4, listEditor.getList().size());
		assertEquals(files, listEditor.getList());
	}

	@Test
	public void testGetExcelFileFilter() {
		assertTrue(ListEditor.getExcelFileFilter().accept(new File("test.xls")));
		assertFalse(ListEditor.getExcelFileFilter().accept(new File("test.txt")));
	}

	@Test
	public void testSetUseSequenceOpener() {
		listEditor.setUseSequenceOpener(true);
		listEditor.setUseSequenceOpener(false);
	}

	@Test
	public void testGetItemsMatching() {
		List<File> files = new ArrayList<File>();
		files.add(new File("abc.file"));
		files.add(new File("bcd.file"));
		files.add(new File("cde.file"));
		files.add(new File("def.file"));
		listEditor.setList(files);
		int[] indices = listEditor.getItemsMatching("b");
		assertTrue(indices[0]==0);
		assertTrue(indices[1]==1);
		indices = listEditor.getItemsMatching("de");
		assertTrue(indices[0]==2);
		assertTrue(indices[1]==3);
		indices = listEditor.getItemsMatching(".file");
		assertTrue(indices[0]==0);
		assertTrue(indices[1]==1);
		assertTrue(indices[2]==2);
		assertTrue(indices[3]==3);
	}

	@Test
	public void testIsModal() {
		assertTrue(listEditor.isModal());
		listEditor.setModal(false);
		assertFalse(listEditor.isModal());
		listEditor.show();
		listEditor.view().setVisible(false);
		listEditor.setModal(true);
		assertTrue(listEditor.isModal());
	}

	@Test
	public void testGetFilenameList() {
		File[] files = new File[3];
		files[0] = new File(TestConfig.testFolder + "/in/in.tif");
		files[1] = new File(TestConfig.testFolder + "/in/a/a.bmp");
		files[2] = new File(TestConfig.testFolder + "/in/b/b.txt");
		listEditor.addToList(files);
		List<String> names = listEditor.getFilenameList();
		assertTrue(names.contains(TestConfig.testFolder + "in/in.tif"));
		assertTrue(names.contains(TestConfig.testFolder + "in/a/a.bmp"));
		assertTrue(names.contains(TestConfig.testFolder + "in/b/b.txt"));
		assertEquals(3, names.size());
	}

	@Test
	public void testGetFilesystemView() {
		assertNull(listEditor.getFilesystemView());
		FileSystemView fsv = FileSystemView.getFileSystemView();
		listEditor.setFilesystemView(fsv);
		assertEquals(fsv, listEditor.getFilesystemView());
	}
}

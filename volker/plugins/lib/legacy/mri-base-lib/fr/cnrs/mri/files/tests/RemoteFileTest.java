package fr.cnrs.mri.files.tests;

import static org.junit.Assert.*;
import java.io.File;
import org.junit.Before;
import org.junit.Test;
import fr.cnrs.mri.files.RemoteFile;

public class RemoteFileTest {

	private File testFolder;

	@Before
	public void setUp() throws Exception {
		testFolder = new File("/a/b/c");
	}

	@Test
	public void testExists() {
		assertFalse(testFolder.exists());
		RemoteFile rf = RemoteFile.from(testFolder);
		assertTrue(rf.exists());
	}
	
	@Test
	public void testIsDirectory() {
		assertFalse(testFolder.isDirectory());
		RemoteFile rf = RemoteFile.from(testFolder);
		assertFalse(rf.isDirectory());
		RemoteFile rf2 = RemoteFile.from(new File("/media"));
		assertTrue(rf2.isDirectory());
	}

	@Test
	public void testIsFile() {
		assertFalse(testFolder.isFile());
		RemoteFile rf = RemoteFile.from(testFolder);
		rf.setIsDirectory(true);
		assertFalse(rf.isFile());
		RemoteFile rf2 = RemoteFile.from(new File("/media"));
		assertFalse(rf2.isFile());
		rf2.setIsDirectory(false);
		assertTrue(rf2.isFile());
	}

	@Test
	public void winFileName() {
		File aFile = new File("E:/test/a/b");
		RemoteFile rf = RemoteFile.from(aFile);
		assertEquals("E:/test/a/b", rf.getPath());
	}
}

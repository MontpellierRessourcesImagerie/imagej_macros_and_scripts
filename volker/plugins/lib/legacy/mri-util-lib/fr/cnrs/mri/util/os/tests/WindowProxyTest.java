package fr.cnrs.mri.util.os.tests;

import static org.junit.Assert.*;

import java.io.File;

import org.junit.Before;
import org.junit.Test;

import fr.cnrs.mri.util.os.WindowsProxy;

public class WindowProxyTest {

	private WindowsProxy win;

	@Before
	public void setUp() {
		win = new WindowsProxy();
	}
	@Test
	public void testIsWindows() {
		assertTrue(win.isWindows());
		assertFalse(win.isMac());
		assertFalse(win.isUnix());
	}

	@Test
	public void testExecute() {
		win.execute("cd .");
	}

	@Test
	public void testExecuteWaiting() {
		String dirBefore = System.getProperty("user.dir");
		win.executeWaiting("cd .");
		String dirAfter = System.getProperty("user.dir");
		assertEquals(dirBefore, dirAfter);
	}
	
	@Test
	public void testGetTimestampStringFromDirOutput() {
		String time = "17/03/2011 17:26					";
		assertEquals("2011-03-17 17:26:00", win.getTimestampStringFromDirOutput(time));
	}
	
	@Test
	public void testGetFileCreationDate() {
		new File(System.getProperty("java.io.tmpdir") + "creationdate.bat").delete(); 
		win.getFileCreationDate(new File("."));
		assertTrue(new File(System.getProperty("java.io.tmpdir") + "/creationdate.bat").exists() );
		new File(System.getProperty("java.io.tmpdir") + "creationdate.bat").delete(); 
	}
}

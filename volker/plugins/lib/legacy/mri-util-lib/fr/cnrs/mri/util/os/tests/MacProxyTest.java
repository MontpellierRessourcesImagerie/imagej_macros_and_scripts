package fr.cnrs.mri.util.os.tests;

import static org.junit.Assert.*;
import java.io.File;
import junit.framework.Assert;
import org.junit.Before;
import org.junit.Test;
import fr.cnrs.mri.testData.TestImages;
import fr.cnrs.mri.util.os.MacProxy;

public class MacProxyTest {

	private MacProxy mac;

	@Before
	public void setUp() throws Exception {
		mac = new MacProxy();
	}

	@Test
	public void testIsMac() {
		assertTrue(mac.isMac());
		assertFalse(mac.isUnix());
		assertFalse(mac.isWindows());
	}

	@Test
	public void testExecute() {
		mac.execute("cd .");
	}

	@Test
	public void testExecuteWaiting() {
		String dirBefore = System.getProperty("user.dir");
		mac.executeWaiting("cd .");
		String dirAfter = System.getProperty("user.dir");
		assertEquals(dirBefore, dirAfter);
	}

	@Test
	public void testMove() {
		mac.move(TestImages.image01Head(), TestImages.path+"head.tif");
		File file1 = new File(TestImages.image01Head());
		File file2 = new File(TestImages.path+"head.tif");
		Assert.assertFalse(file1.exists());
		Assert.assertTrue(file2.exists());
		mac.move(TestImages.path+"head.tif", TestImages.image01Head());
		Assert.assertTrue(file1.exists());
		Assert.assertFalse(file2.exists());
	}

}

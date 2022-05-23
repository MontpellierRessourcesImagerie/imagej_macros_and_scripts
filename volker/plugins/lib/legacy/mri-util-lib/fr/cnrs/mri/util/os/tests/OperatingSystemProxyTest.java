package fr.cnrs.mri.util.os.tests;

import static org.junit.Assert.*;
import java.io.File;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.sql.Timestamp;
import junit.framework.Assert;
import org.junit.Before;
import org.junit.Test;
import fr.cnrs.mri.testData.TestImages;
import fr.cnrs.mri.util.os.MacProxy;
import fr.cnrs.mri.util.os.OperatingSystemProxy;
import fr.cnrs.mri.util.os.UnixProxy;
import fr.cnrs.mri.util.os.WindowsProxy;

public class OperatingSystemProxyTest {

	private OperatingSystemProxy proxy;

	@Before
	public void setUp() throws Exception {
		proxy = OperatingSystemProxy.current();
	}

	@Test
	public void testCurrent() {
		Assert.assertTrue(proxy == OperatingSystemProxy.current());
	}

	@Test
	public void testOperatingSystem() {
		String os = OperatingSystemProxy.operatingSystem();
		Assert.assertTrue(os.equals(System.getProperty( "os.name" )));
	}

	@Test
	public void testUsername() {
		String user = proxy.username();
		Assert.assertTrue(user.equals(System.getProperty( "user.name" )));
	}

	@Test
	public void testHostname() throws UnknownHostException {
		String name = null;
		String hostname = null;
		name = InetAddress.getLocalHost().getHostName();
		hostname = proxy.hostname();
		assertTrue(name!=null);
		assertTrue(hostname.equals(name));
	}

	@Test
	public void testIpAddress() throws UnknownHostException {
		String address = null;
		String hostaddress = null;
		address = InetAddress.getLocalHost().getHostAddress();
		hostaddress = proxy.ipAddress();
		assertTrue(address!=null);
		assertTrue(hostaddress.equals(address));
	}

	@Test
	public void testGetFileCreationDate() {
		File file = new File(TestImages.image01Head());
		Timestamp date = proxy.getFileCreationDate(file);
		if (proxy.isWindows()) 
			Assert.assertTrue(date.toString().equals(TestImages.image01Date()));
		else
			Assert.assertEquals(TestImages.image01ModificationDate(), date.toString());
		File fileNDPI = new File (TestImages.imageNdpi());
		assertTrue(fileNDPI.exists());
		date = proxy.getFileCreationDate(fileNDPI);
		if (proxy.isWindows()) 
			Assert.assertEquals(TestImages.imageNdpiDate(),date.toString());
		else
			Assert.assertEquals(TestImages.imageNdpiModificationDate(),date.toString());
	}


	@Test
	public void testExecute() {
		proxy.execute("cd .");
		Assert.assertTrue(true);
	}
	
	@Test
	public void testExecuteWaiting() {
		proxy.executeWaiting("cd .");
		Assert.assertTrue(true);
	}
	
	@Test
	public void testMove() {
		proxy.move(TestImages.image01Head(), TestImages.path+"head.tif");
		File file1 = new File(TestImages.image01Head());
		File file2 = new File(TestImages.path+"head.tif");
		Assert.assertFalse(file1.exists());
		Assert.assertTrue(file2.exists());
		proxy.move(TestImages.path+"head.tif", TestImages.image01Head());
		Assert.assertTrue(file1.exists());
		Assert.assertFalse(file2.exists());
	}
	
	@Test
	public void testIsUnix() {
		if (proxy.getClass()==UnixProxy.class) Assert.assertTrue(proxy.isUnix());
		else Assert.assertFalse(proxy.isUnix());
	}
	
	@Test
	public void testIsWindows() {
		if (proxy.getClass()==WindowsProxy.class) Assert.assertTrue(proxy.isWindows());
		else Assert.assertFalse(proxy.isWindows());
	}
	
	@Test
	public void testIsMac() {
		if (proxy.getClass()==MacProxy.class) Assert.assertTrue(proxy.isMac());
		else Assert.assertFalse(proxy.isMac());
	}
}

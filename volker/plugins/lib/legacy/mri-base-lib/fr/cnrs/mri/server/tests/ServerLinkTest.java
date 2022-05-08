package fr.cnrs.mri.server.tests;

import static org.junit.Assert.*;
import org.junit.Before;
import org.junit.Test;
import fr.cnrs.mri.server.ServerLink;

public class ServerLinkTest {

	@Before
	public void setUp() throws Exception {
	}

	@Test
	public void testServerLink() {
		ServerLink serverLink = new ServerLink("mathusalem.mri.cnrs.fr", 4000);
		assertEquals(serverLink.getHost(), "mathusalem.mri.cnrs.fr");
		assertEquals(serverLink.getPort(), 4000);
	}

	@Test
	public void testGetHost() {
		ServerLink serverLink = new ServerLink("ishtar.mri.cnrs.fr", 4000);
		assertEquals(serverLink.getHost(), "ishtar.mri.cnrs.fr");
		serverLink.setHost("abel");
		assertEquals(serverLink.getHost(), "abel");
	}


	@Test
	public void testGetPort() {
		ServerLink serverLink = new ServerLink("ishtar.mri.cnrs.fr", 4000);
		assertEquals(serverLink.getPort(), 4000);
		serverLink.setPort(5000);
		assertEquals(serverLink.getPort(), 5000);
	}

	@Test
	public void testFromString() {
		ServerLink serverLink = ServerLink.fromString("mathusalem.mri.cnrs.fr:4000");
		assertEquals(serverLink.getHost(), "mathusalem.mri.cnrs.fr");
		assertEquals(serverLink.getPort(), 4000);
	}

	@Test
	public void testToString() {
		ServerLink serverLink = ServerLink.fromString("mathusalem.mri.cnrs.fr:4000");
		assertEquals("mathusalem.mri.cnrs.fr:4000", serverLink.toString());
	}

	@Test
	public void testEquals() {
		ServerLink serverLink = ServerLink.fromString("mathusalem.mri.cnrs.fr:4000");
		assertEquals(serverLink, serverLink);
		ServerLink serverLink2 = ServerLink.fromString("mathusalem.mri.cnrs.fr:4001");
		assertFalse(serverLink.equals(serverLink2));
		ServerLink serverLink3 = ServerLink.fromString("caen.mri.cnrs.fr:4000");
		assertFalse(serverLink.equals(serverLink3));
		ServerLink serverLink4 = ServerLink.fromString("mathusalem.mri.cnrs.fr:4000");
		assertEquals(serverLink, serverLink4);
	}
	
	@Test
	public void testHashCode() {
		ServerLink serverLink = ServerLink.fromString("mathusalem.mri.cnrs.fr:4000");
		assertEquals(serverLink.hashCode(), serverLink.hashCode());
		ServerLink serverLink2 = ServerLink.fromString("mathusalem.mri.cnrs.fr:4001");
		assertFalse(serverLink.hashCode()==serverLink2.hashCode());
		ServerLink serverLink3 = ServerLink.fromString("caen.mri.cnrs.fr:4000");
		assertFalse(serverLink.hashCode()==serverLink3.hashCode());
		ServerLink serverLink4 = ServerLink.fromString("mathusalem.mri.cnrs.fr:4000");
		assertEquals(serverLink.hashCode(), serverLink4.hashCode());
	}
}
package fr.cnrs.mri.server.tests;


import static org.junit.Assert.assertEquals;

import org.junit.Before;
import org.junit.Test;

import fr.cnrs.mri.server.Server;

public class ServerTest {

	@Before
	public void setUp() throws Exception {
	}

	@Test
	public void testAspect() {
		assertEquals("IS_RUNNING", Server.Aspect.IS_RUNNING.name());
	}
}

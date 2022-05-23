package fr.cnrs.mri.util.config.tests;

import static org.junit.Assert.*;

import java.io.File;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;

import fr.cnrs.mri.util.config.AbstractConfiguration;

public class AbstractConfigurationTest extends AbstractConfiguration {
	private static final long serialVersionUID = -6527374262733556846L;

	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		File file = new File(filename());
		file.delete();
	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {
	}

	@Test
	public void testAbstractConfiguration() {
		AbstractConfiguration config = new AbstractConfigurationTest();
		assertTrue(config.getLogger()!=null);
	}

	@Test
	public void testGetLogger() {
		assertTrue(this.getLogger()!=null);
	}

	@Test
	public void testLoad() {
		AbstractConfiguration config = new AbstractConfigurationTest();
		config.setProperty("a", "aValue");
		config.setProperty("b", "bValue");
		config.save();
		assertNull(this.getProperty("a"));
		assertNull(this.getProperty("b"));
		this.load();
		assertEquals("aValue", this.getProperty("a"));
		assertEquals("bValue", this.getProperty("b"));
		new File(this.getFilename()).delete();
	}

	@Test
	public void testSave() {
		File file = new File(this.getFilename());
		assertFalse(file.exists());
		this.setProperty("a", "aValue");
		this.setProperty("b", "bValue");
		this.save();
		assertTrue(file.exists());
		AbstractConfiguration config = new AbstractConfigurationTest();
		config.load();
		assertEquals("aValue", config.getProperty("a"));
		assertEquals("bValue", config.getProperty("b"));
		new File(this.getFilename()).delete();
	}

	@Test
	public void testSetProperty() {
		this.setProperty("a", "aValue");
		assertTrue(this.getProperty("a").equals("aValue"));
	}

	@Test
	public void testGetPropertyString() {
		assertNull(this.getProperty("a"));
		this.setProperty("a", "aValue");
		assertTrue(this.getProperty("a").equals("aValue"));
	}

	@Override
	protected String getComment() {
		return "test configuration file for the unit-test of the abstract-configuration class";
	}

	@Override
	protected String getFilename() {
		return filename();
	}

	public static String filename() {
		return "abstract-configuration-test-config.txt";
	}
}

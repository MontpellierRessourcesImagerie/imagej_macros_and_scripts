package fr.cnrs.mri.files.tests;

import static org.junit.Assert.*;
import java.io.File;
import org.junit.Test;
import fr.cnrs.mri.files.ConfigurableFileFilter;

public class ConfigurableFileFilterTest {

	@Test
	public void testConfigurableFileFilter() {
		String[] extensions = {"bmp", "jpg", "tif", "tiff"};
		String description = "images (bmp, jpg, or tif)";
		ConfigurableFileFilter filter = new ConfigurableFileFilter(extensions, description);
		assertTrue(extensions == filter.getFileExtensions());
		assertEquals(description, filter.getDescription());
	}

	@Test
	public void testAcceptFile() {
		String[] extensions = {"bmp", "jpg", "tif", "tiff"};
		String description = "images (bmp, jpg, or tif)";
		ConfigurableFileFilter filter = new ConfigurableFileFilter(extensions, description);
		assertTrue(filter.accept(new File("/home/baecker/a.tif")));
		assertTrue(filter.accept(new File("/home/baecker/b.jpg")));
		assertTrue(filter.accept(new File("/home/baecker/c.bmp")));
		assertTrue(filter.accept(new File("/home/baecker/d.tiff")));
		assertTrue(filter.accept(new File("/home/")));
		assertFalse(filter.accept(new File("/home/baecker/a.txt")));
		assertFalse(filter.accept(new File("/home/baecker/B.TIF")));
		assertFalse(filter.accept(new File("/home/baecker/c.gif")));
	}

	@Test
	public void testGetDescription() {
		String[] extensions = {"bmp", "jpg", "tif", "tiff"};
		String description = "images (bmp, jpg, or tif)";
		ConfigurableFileFilter filter = new ConfigurableFileFilter(extensions, description);
		filter.setDescription("test-description");
		assertEquals("test-description", filter.getDescription());
	}

	@Test
	public void testGetFileExtensions() {
		String[] extensions = {"bmp", "jpg", "tif", "tiff"};
		String description = "images (bmp, jpg, or tif)";
		ConfigurableFileFilter filter = new ConfigurableFileFilter(extensions, description);
		String[] extensions2 = {"aab", "aac"};
		filter.setFileExtensions(extensions2);
		assertTrue(extensions2==filter.getFileExtensions());
	}
}

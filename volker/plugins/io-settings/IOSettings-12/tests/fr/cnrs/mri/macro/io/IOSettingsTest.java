package tests.fr.cnrs.mri.macro.io;

import static org.junit.Assert.*;

import java.util.ArrayList;
import java.util.List;

import org.junit.Test;

import fr.cnrs.mri.macro.io.IOSettings;

public class IOSettingsTest {

	@Test
	public void testGetInputFolder() {
		assertEquals(IOSettings.getInputFolder(), IOSettings.none());
		IOSettings.setInputFolder("/home/baecker/images/");
		assertEquals(IOSettings.getInputFolder(), "/home/baecker/images/");
		IOSettings.setInputFolder("/home/baecker/in/");
		assertEquals(IOSettings.getInputFolder(), "/home/baecker/in/");
		IOSettings.resetInputFolders();
		assertEquals(IOSettings.getInputFolder(), IOSettings.none());
	}

	@Test
	public void testGetOutputFolder() {
		assertEquals(IOSettings.getOutputFolder(), IOSettings.none());
		IOSettings.setOutputFolder("/home/baecker/images/");
		assertEquals(IOSettings.getOutputFolder(), "/home/baecker/images/");
		IOSettings.setOutputFolder("/home/baecker/out/");
		assertEquals(IOSettings.getOutputFolder(), "/home/baecker/out/");
		IOSettings.resetOutputFolders();
		assertEquals(IOSettings.getOutputFolder(), IOSettings.none());
	}

	@Test
	public void testGetFileList() {
		assertEquals(IOSettings.getFileList(), IOSettings.none());
		List<String> files = new ArrayList<String>();
		files.add("/home/baecker/images/image01.tif");
		files.add("/home/baecker/images/image02.tif");
		files.add("/home/baecker/images/image03.tif");
		IOSettings.setFileList(files);
		String[] parts = IOSettings.getFileList().split(",");
		assertEquals("/home/baecker/images/image01.tif", parts[0]);
		assertEquals("/home/baecker/images/image02.tif", parts[1]);
		assertEquals("/home/baecker/images/image03.tif", parts[2]);
		IOSettings.resetFileLists();
		assertEquals(IOSettings.getFileList(), IOSettings.none());
	}

	@Test
	public void testGetInputFolders() {
		assertEquals(IOSettings.getInputFolders(), IOSettings.none());
		List<String> folders = new ArrayList<String>();
		folders.add("/home/baecker/images/in01/");
		folders.add("/home/baecker/images/in02/");
		folders.add("/home/baecker/images/in03/");
		IOSettings.setInputFolders(folders);
		String[] parts = IOSettings.getInputFolders().split(",");
		assertEquals("/home/baecker/images/in01/", parts[0]);
		assertEquals("/home/baecker/images/in02/", parts[1]);
		assertEquals("/home/baecker/images/in03/", parts[2]);
		IOSettings.resetInputFolders();
		assertEquals(IOSettings.getInputFolders(), IOSettings.none());
	}

	@Test
	public void testGetOutputFolders() {
		assertEquals(IOSettings.getOutputFolders(), IOSettings.none());
		List<String> folders = new ArrayList<String>();
		folders.add("/home/baecker/images/out01/");
		folders.add("/home/baecker/images/out02/");
		folders.add("/home/baecker/images/out03/");
		IOSettings.setOutputFolders(folders);
		String[] parts = IOSettings.getOutputFolders().split(",");
		assertEquals("/home/baecker/images/out01/", parts[0]);
		assertEquals("/home/baecker/images/out02/", parts[1]);
		assertEquals("/home/baecker/images/out03/", parts[2]);
		IOSettings.resetOutputFolders();
		assertEquals(IOSettings.getOutputFolders(), IOSettings.none());
	}

	@Test
	public void testGetFileLists() {
		assertEquals(IOSettings.getFileLists(), IOSettings.none());
		List<List<String>> files = new ArrayList<List<String>>();
		List<String> channel01 = new ArrayList<String>();
		List<String> channel02 = new ArrayList<String>();
		List<String> channel03 = new ArrayList<String>();
		channel01.add("/home/baecker/images/cell-gfp-01.tif");
		channel01.add("/home/baecker/images/cell-gfp-02.tif");
		channel01.add("/home/baecker/images/cell-gfp-03.tif");
		channel02.add("/home/baecker/images/cell-rhod-01.tif");
		channel02.add("/home/baecker/images/cell-rhod-02.tif");
		channel02.add("/home/baecker/images/cell-rhod-03.tif");
		channel03.add("/home/baecker/images/cell-act-01.tif");
		channel03.add("/home/baecker/images/cell-act-02.tif");
		channel03.add("/home/baecker/images/cell-act-03.tif");
		files.add(channel01);
		files.add(channel02);
		files.add(channel03);
		IOSettings.setFileLists(files);
		String[] parts = IOSettings.getFileLists().split(";");
		String[] list01 = parts[0].split(",");
		assertEquals("/home/baecker/images/cell-gfp-01.tif", list01[0]);
		assertEquals("/home/baecker/images/cell-gfp-02.tif", list01[1]);
		assertEquals("/home/baecker/images/cell-gfp-03.tif", list01[2]);
		String[] list02 = parts[1].split(",");
		assertEquals("/home/baecker/images/cell-rhod-01.tif", list02[0]);
		assertEquals("/home/baecker/images/cell-rhod-02.tif", list02[1]);
		assertEquals("/home/baecker/images/cell-rhod-03.tif", list02[2]);
		String[] list03 = parts[2].split(",");
		assertEquals("/home/baecker/images/cell-act-01.tif", list03[0]);
		assertEquals("/home/baecker/images/cell-act-02.tif", list03[1]);
		assertEquals("/home/baecker/images/cell-act-03.tif", list03[2]);
	}

}

/*
This file is part of the Montpellier RIO Imaging mri-comp-lib package.
 
(c) 2011 INSERM
This software is developed at Montpellier RIO Imaging (IFR 122), Montpellier, France (www.mri.cnrs.fr)
Developer: Volker Baecker (volker.baecker@mri.cnrs.fr) 

The Montpellier RIO Imaging mri-comp-lib package contains different components that
are needed in multiple projects.

This software is governed by the CeCILL-B license under French law and
abiding by the rules of distribution of free software.  You can  use, 
modify and/ or redistribute the software under the terms of the CeCILL-B
license as circulated by CEA, CNRS and INRIA at the following URL
"http://www.cecill.info". 

As a counterpart to the access to the source code and  rights to copy,
modify and redistribute granted by the license, users are provided only
with a limited warranty  and the software's author,  the holder of the
economic rights,  and the successive licensors  have only  limited
liability. 

In this respect, the user's attention is drawn to the risks associated
with loading,  using,  modifying and/or developing or reproducing the
software by the user in light of its specific status of free software,
that may mean  that it is complicated to manipulate,  and  that  also
therefore means  that it is reserved for developers  and  experienced
professionals having in-depth computer knowledge. Users are therefore
encouraged to load and test the software's suitability as regards their
requirements in conditions enabling the security of their systems and/or 
data to be ensured and,  more generally, to use and operate it in the 
same conditions as regards security. 

The fact that you are presently reading this means that you have had
knowledge of the CeCILL-B license and that you accept its terms. 
*/
package fr.cnrs.mri.fileList;

import java.awt.Dialog.ModalityType;
import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Observable;
import javax.swing.filechooser.FileFilter;
import javax.swing.filechooser.FileSystemView;

import fr.cnrs.mri.files.ConfigurableFileFilter;

/**
 * A list editor for files. Files can be added, seleted and removed.
 * 
 * @author baecker
 *
 */
public class ListEditor extends Observable {
	protected ListEditorView view;
	protected List<File> list;
	protected boolean showPath = true;
	protected boolean useSequenceOpener = false;
	protected boolean modal = true;
	private FileSystemView filesystemView;
	
	public static void main(String[] args) {
		new ListEditor().show();
	}
	
	public void show() {
		if (!isModal()) this.view().setModalityType(ModalityType.MODELESS);
		this.view().setVisible(true);
		this.changed("list");
	}
	
	public ListEditorView view() {
		if (this.view == null) {
			this.view = new ListEditorView(this);
		}
		return this.view;
	}

	public static ConfigurableFileFilter getTiffFileFilter() {
		String[] extensions = {"tif", "tiff", "TIF", "TIFF"};
		ConfigurableFileFilter filter = new ConfigurableFileFilter(extensions, "tif images");
		return filter;
	}
	
	public static ConfigurableFileFilter getImageFileFilter() {
		String[] extensions = {"tiff", "tif", "TIF", "TIFF", "gif", "GIF", "jpg", "JPG", "bmp", "BMP", "pgm", "PGM", "stk", "STK"};
		ConfigurableFileFilter filter = new ConfigurableFileFilter(extensions, "all images");
		return filter;
	}

	public void addToList(File[] selectedFiles, FileFilter filter) {
		for(int i=0; i<selectedFiles.length;i++) {
			File aFile = selectedFiles[i];
			if (!filter.accept(aFile)) {
				selectedFiles[i] = null;
				continue;
			}
			if (aFile.isDirectory()) {
				if (filesystemView!=null) {
					this.addToList(filesystemView.getFiles(aFile, true), (FileFilter)filter);
				} else 
					this.addToList(aFile.listFiles(), (FileFilter)filter);
				selectedFiles[i] = null;
			}
		}
		ArrayList<File> fileList = new ArrayList<File>();
		fileList.addAll(Arrays.asList(selectedFiles));
		while (fileList.remove(null));
		this.getList().addAll(fileList);
		this.changed("list");
	}

	public void addToList(File[] selectedFiles) {
		ArrayList<File> fileList = new ArrayList<File>();
		fileList.addAll(Arrays.asList(selectedFiles));
		while (fileList.remove(null));
		this.getList().addAll(fileList);
		this.changed("list");
	}

	protected void changed(String anAspect) {
		this.setChanged();
		this.notifyObservers(anAspect);
	}

	public List<File> getList() {
		if (list==null) {
			list = new ArrayList<File>();
		}
		return list;
	}

	public void removeElementsFromList(Object[] toBeRemoved) {
		for(int i=0; i<toBeRemoved.length; i++) {
			this.getList().remove(toBeRemoved[i]);
		}
		this.changed("list");
	}

	public void setList(List<File> list) {
		this.list = list;
	}

	public static ConfigurableFileFilter getExcelFileFilter() {
		String[] extensions = {"xls"};
		ConfigurableFileFilter filter = new ConfigurableFileFilter(extensions, "excel");
		return filter;
	}

	public void setUseSequenceOpener(boolean value) {
		this.useSequenceOpener = value;
	}

	public int[] getItemsMatching(String text) {
		ArrayList<Integer> indices = new ArrayList<Integer>();
		Iterator<File> it = list.iterator();
		while (it.hasNext()) {
			File current = it.next();
			if (current.getPath().contains(text)) indices.add(new Integer(list.indexOf(current)));
		}
		int[] result = new int[indices.size()];
		int index = 0;
		Iterator<Integer> indexIterator = indices.iterator();
		while (indexIterator.hasNext()) {
			Integer current = indexIterator.next();
			result[index] = current.intValue();
			index++;
		}
		return result;
	}

	public boolean isModal() {
		return modal;
	}

	public void setModal(boolean modal) {
		this.modal = modal;
	}

	public List<String> getFilenameList() {
		List<String> names = new ArrayList<String>();
		List<File> files = this.getList();
		for (File file : files) {
			names.add(file.getPath());
		}
		return names;
	}

	public FileSystemView getFilesystemView() {
		return this.filesystemView;
	}
	
	public void setFilesystemView(FileSystemView filesystemView) {
		this.filesystemView = filesystemView;
	}
}

/*
This file is part of the Montpellier RIO Imaging mri-base-lib package.
 
(c) 2011 INSERM
This software is developed at Montpellier RIO Imaging (IFR 122), Montpellier, France (www.mri.cnrs.fr)
Developer: Volker Baecker (volker.baecker@mri.cnrs.fr) 

The Montpellier RIO Imaging mri-base-lib package contains different components that
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
package fr.cnrs.mri.files;

import java.io.File;
import java.util.Arrays;

import javax.swing.filechooser.FileFilter;

/**
 * Allows to create a file-filter from a list of extensions (for example txt, bmp, tif, tiff, etc.)
 * 
 * @author baecker
 *
 */
public class ConfigurableFileFilter extends FileFilter implements java.io.FileFilter{
	protected String description;
	protected String[] fileExtensions;
	
	public ConfigurableFileFilter(String[] fileExtensions, String description) {
		this.setFileExtensions(fileExtensions);
		this.setDescription(description);
	}
	
	/* (non-Javadoc)
	 * @see javax.swing.filechooser.FileFilter#accept(java.io.File)
	 */
	@Override
	public boolean accept(File file) {
		if (file.isDirectory()) return true;
		int index = file.getName().lastIndexOf('.');
		if (index==-1) return false;
		String extension = file.getName().substring(index+1, file.getName().length());
		if (Arrays.asList(fileExtensions).contains(extension)) return true;
		return false;
	}

	/* (non-Javadoc)
	 * @see javax.swing.filechooser.FileFilter#getDescription()
	 */
	@Override
	public String getDescription() {
		return description;
	}

	/**
	 * @param description The description to set.
	 */
	public void setDescription(String description) {
		this.description = description;
	}
	/**
	 * @return Returns the fileExtensions.
	 */
	public String[] getFileExtensions() {
		return fileExtensions;
	}
	/**
	 * @param fileExtensions The fileExtensions to set.
	 */
	public void setFileExtensions(String[] fileExtensions) {
		this.fileExtensions = fileExtensions;
	}
}

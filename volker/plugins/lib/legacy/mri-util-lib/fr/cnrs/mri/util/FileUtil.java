/*
This file is part of the Montpellier RIO Imaging mri-util-lib package.
 
(c) 2011 INSERM
This software is developed at Montpellier RIO Imaging (IFR 122), Montpellier, France (www.mri.cnrs.fr)
Developer: Volker Baecker (volker.baecker@mri.cnrs.fr) 

The Montpellier RIO Imaging mri-util-lib package contains different simple tools that
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
package fr.cnrs.mri.util;

import java.io.File;

/**
 * File and filename related utility methods.
 * 
 * @author Volker Baecker
 *
 */
public class FileUtil {
	
	/**
	 * Answer the extension of the file or an empty string if there is no extension. 
	 * The extension consists of everything after the last dot in the filename. The 
	 * extension will be answered using lower case letters.
	 * 
	 * @param filename	the name of the file
	 * @return	the file-extension
	 */
	public static String getExtension(String filename) {
		int index = filename.lastIndexOf('.');
		if (index==-1) return "";
		String ext = filename.substring(filename.lastIndexOf('.')+1, filename.length()).toLowerCase();
		return ext;
	}
	
	/**
	 * Answer the name of the file without its extension or filename if there is no extension. 
	 * The extension consists of everything after the last dot in the filename. 
	 * 
	 * @param filename	the name of the file
	 * @return	the base name
	 */
	public static String getNameWithoutExtension(String filename) {
		int index = filename.lastIndexOf('.');
		if (index==-1) return filename;
		String ext = filename.substring(0, filename.lastIndexOf('.'));
		return ext;
	}
	
	/**
	 * Delete the folder and all files and sub folders in the 
	 * folder. If the folderPath is a file, the method deletes it.
	 * @param folderPath
	 */
	public static boolean deleteFolder (String folderPath){
		File file =new File(folderPath);
		if (!file.exists()) return false;
		if (file.isFile()) return file.delete();
		if (file.list().equals(null)) return file.delete();
		String[] children = file.list();
		for (int i =0; i<children.length; i++) {
			if (!deleteFolder(file.getAbsolutePath() + "/" + children[i])) return false;
		}
		return file.delete();
	}
	
	
}

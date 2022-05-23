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

import java.io.File;

import ij.IJ;
import ij.ImagePlus;
import ij.Prefs;
import ij.io.OpenDialog;
import ij.io.Opener;
import ij.plugin.FolderOpener;

/**
 * 
 * @author baecker
 *
 */
public class MRIFolderOpener extends FolderOpener {
	FolderOpenerProxy proxy;
	private File[] fileList;
	
	public MRIFolderOpener() {
		proxy = new FolderOpenerProxy(this);
	}
	
	public void run(String arg) {
		boolean oldPref = Prefs.useJFileChooser;
		Prefs.useJFileChooser = false;
		OpenDialog od = new OpenDialog("Open Image Sequence...", arg);
		String directory = od.getDirectory();
		String name = od.getFileName();
		if (name==null)
			return;
		String[] list = (new File(directory)).list();
		if (list==null)
			return;
		String title = directory;
		if (title.endsWith(File.separator))
			title = title.substring(0, title.length()-1);
		int index = title.lastIndexOf(File.separatorChar);
		if (index!=-1) title = title.substring(index + 1);
		if (title.endsWith(":"))
			title = title.substring(0, title.length()-1);
		
		IJ.register(FolderOpener.class);
		list = this.sortFileList(list);
		if (IJ.debugMode) IJ.log("FolderOpener: "+directory+" ("+list.length+" files)");
		int width=0;
		IJ.resetEscape();		
			for (int i=0; i<list.length; i++) {
				if (list[i].endsWith(".txt"))
					continue;
				IJ.redirectErrorMessages();
				ImagePlus imp = (new Opener()).openImage(directory, list[i]);
				if (imp!=null) {
					width = imp.getWidth();
					proxy.setFi(imp.getOriginalFileInfo());
					if (!proxy.showDialog(imp, list))
						return;
					break;
				}
			}
			if (width==0) {
				IJ.error("Import Sequence", "This folder does not appear to contain any TIFF,\n"
				+ "JPEG, BMP, DICOM, GIF, FITS or PGM files.");
				return;
			}

			if (proxy.getFilter()!=null && (proxy.getFilter().equals("") || proxy.getFilter().equals("*")))
				proxy.setFilter(null);
			if (proxy.getFilter()!=null) {
				int filteredImages = 0;
  				for (int i=0; i<list.length; i++) {
 					if (list[i].indexOf(proxy.getFilter())>=0)
 						filteredImages++;
 					else
 						list[i] = null;
 				}
  				if (filteredImages==0) {
  					IJ.error("None of the "+list.length+" files contain\n the string '"+proxy.getFilter()+"' in their name.");
  					return;
  				}
  				String[] list2 = new String[filteredImages];
  				int j = 0;
  				for (int i=0; i<list.length; i++) {
 					if (list[i]!=null)
 						list2[j++] = list[i];
 				}
  				list = list2;
  			}
			fileList = new File[list.length];
			for (int i=0; i<list.length; i++) {
				fileList[i] = new File(directory + list[i]);
			}
			Prefs.useJFileChooser = oldPref;
	}
	
	public File[] getFileList() {
		return fileList;
	}
}

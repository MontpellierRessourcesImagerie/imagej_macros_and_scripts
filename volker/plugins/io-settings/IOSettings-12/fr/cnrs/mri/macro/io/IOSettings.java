/*
This file is part of the Remote ImageJ.
 
(c) 2011 INSERM
This software is developed at Montpellier RIO Imaging (IFR 122), Montpellier, France (www.mri.cnrs.fr)
Developer: Volker Baecker (volker.baecker@mri.cnrs.fr) 

The Remote ImageJ allows to run ImageJ macros on a distant machine.

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
package fr.cnrs.mri.macro.io;

import java.awt.Window;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.Observable;

import javax.swing.filechooser.FileSystemView;

public class IOSettings extends Observable implements Serializable {
	private static final long serialVersionUID = -8324234808155708901L;

	public enum Aspect {FILE_LISTS, INPUT_FOLDERS, OUTPUT_FOLDERS, FILESYSTEM_VIEW};

	protected  List<String> inputFolders = new ArrayList<String>();
	protected  List<String> outputFolders = new ArrayList<String>();
	protected  List<List<String>> fileLists = new ArrayList<List<String>>();
	transient protected  IOSettingsEditorView view;
	transient protected static IOSettings instance;
	transient private  FileSystemView filesystemView;
	
	// API begin

	public static IOSettings getInstance() {
		if (instance==null) instance = new IOSettings();
		return instance;
	}

	public static void setInstance(IOSettings anIOSetting) {
		instance = anIOSetting;
	}

	public static String getInputFolder() {
		return getInstance().GetInputFolder();
	}
	
	public static void setInputFolder(String folder) {
		getInstance().SetInputFolder(folder);
	}

	public static void resetInputFolders() {
		getInstance().ResetInputFolders();
	}
	
	public static String getOutputFolder() {
		return getInstance().GetOutputFolder();
	}
	
	public static void setOutputFolder(String folder) {
		getInstance().SetOutputFolder(folder);
	}
	
	public static void resetOutputFolders() {
		getInstance().ResetOutputFolders();
	}
	
	public static String getFileList() {
		return getInstance().GetFileList();
	}
	
	public static void setFileList(List<String> files) {
		getInstance().SetFileList(files);
	}
	
	public static void resetFileLists() {
		getInstance().ResetFileLists();
	}
	
	public static String getInputFolders() {
		return getInstance().GetInputFolders();
	}
	
	public static void setInputFolders(List<String> folders) {
		getInstance().SetInputFolders(folders);
	}
	
	public static void addInputFolder(String folder) {
		getInstance().AddInputFolder(folder);
	}
	
	public static String getOutputFolders() {
		return getInstance().GetOutputFolders();
	}
	
	public static void setOutputFolders(List<String> folders) {
		getInstance().SetOutputFolders(folders);
	}
	
	public static String getFileLists() {
		return getInstance().GetFileLists();
	}
	
	public static void setFileLists(List<List<String>> lists) {
		getInstance().SetFileLists(lists);
	}
	
	public static void addFileList(List<String> fileList) {
		getInstance().AddFileList(fileList);
	}
	
	public static void replaceFileList(int index, List<String> filenameList) {
		getInstance().ReplaceFileList(index, filenameList);
	}
	
	public static void removeFileLists(int[] indices) {
		getInstance().RemoveFileLists(indices);
	}
	
	public static void removeInputFolders(int[] indices) {
		getInstance().RemoveInputFolders(indices);
	}
	
	public static void addOutputFolder(String folder) {
		getInstance().AddOutputFolder(folder);
	}
	
	public static void removeOutputFolders(int[] indices) {
		getInstance().RemoveOutputFolders(indices);
	}
	
	public static void show() {
		getInstance().Show();
	}
	
	// API end
	
	private String GetInputFolder() {
		if (inputFolders.size()==0) return none();
		return inputFolders.get(0);
	}
	
	private void SetInputFolder(String folder) {
		if (inputFolders.size()==0) inputFolders.add(folder);
		else inputFolders.set(0, folder);
	}
	
	private void ResetInputFolders() {
		inputFolders.clear();
		this.changed(Aspect.INPUT_FOLDERS);
	}
	
	private String GetOutputFolder() {
		if (outputFolders.size()==0) return none();
		return outputFolders.get(0);
	}
	
	private void SetOutputFolder(String folder) {
		if (outputFolders.size()==0) outputFolders.add(folder);
		else outputFolders.set(0, folder);
		this.changed(Aspect.OUTPUT_FOLDERS);
	}
	
	private void ResetOutputFolders() {
		outputFolders.clear();
		this.changed(Aspect.OUTPUT_FOLDERS);
	}
	
	private String GetFileList() {
		if (fileLists.isEmpty() || fileLists.get(0).isEmpty()) return none();
		List<String> fileList = fileLists.get(0);
		return  listToString(fileList);
	}
	
	private void SetFileList(List<String> files) {
		if (fileLists.size()==0) fileLists.add(files);
		else fileLists.set(0, files);
		this.changed(Aspect.FILE_LISTS);
	}
	
	private void ResetFileLists() {
		fileLists.clear();
		this.changed(Aspect.FILE_LISTS);
	}
	
	private String GetInputFolders() {
		if (inputFolders.isEmpty()) return none();
		return listToString(inputFolders);
	}
	
	private void SetInputFolders(List<String> folders) {
		inputFolders = folders;
		this.changed(Aspect.INPUT_FOLDERS);
	}
	
	private void AddInputFolder(String folder) {
		inputFolders.add(folder);
		this.changed(Aspect.INPUT_FOLDERS);
	}
	
	private String GetOutputFolders() {
		if (outputFolders.isEmpty()) return none();
		return listToString(outputFolders);
	}
	
	private void SetOutputFolders(List<String> folders) {
		outputFolders = folders;
		this.changed(Aspect.OUTPUT_FOLDERS);
	}
	
	private String GetFileLists() {
		if (fileLists.isEmpty()) return none();
		String result = "";
		int index = 0;
		for (List<String> list : fileLists) {
			result += listToString(list);
			if (index<fileLists.size()-1) result += ";";
			index++;
		}
		return result;
	}
	
	private void SetFileLists(List<List<String>> lists) {
		fileLists = lists;
		this.changed(Aspect.FILE_LISTS);
	}
	
	private static String listToString(List<String> list) {
		String result = "";
		int index = 0;
		for (String file : list) {
			result += file;
			if (index<list.size()-1) result += ",";
			index++;
		}
		return result;
	}
	
	public static String none() {
		return "none";
	}
	
	private void AddFileList(List<String> fileList) {
		fileLists.add(fileList);
		this.changed(Aspect.FILE_LISTS);
	}

	private void ReplaceFileList(int index, List<String> filenameList) {
		fileLists.set(index, filenameList);
		this.changed(Aspect.FILE_LISTS);
	}

	private void RemoveFileLists(int[] indices) {
		removeFromList(fileLists, indices);
		this.changed(Aspect.FILE_LISTS);
	}

	private void RemoveInputFolders(int[] indices) {
		removeFromList(inputFolders, indices);
		this.changed(Aspect.INPUT_FOLDERS);
	}

	private void AddOutputFolder(String folder) {
		outputFolders.add(folder);
		this.changed(Aspect.OUTPUT_FOLDERS);
	}

	private void RemoveOutputFolders(int[] indices) {
		removeFromList(outputFolders, indices);
		this.changed(Aspect.OUTPUT_FOLDERS);
	}
	
	private void Show() {
		this.getView().setVisible(true);
	}

	public static FileSystemView getFilesystemView() {
		return getInstance().GetFilesystemView();
	}
	
	public static void setFilesystemView(FileSystemView aFilesystemView) {
		getInstance().SetFilesystemView(aFilesystemView);
	}
	
	private Window getView() {
		if (view==null) view = new IOSettingsEditorView();
		return view;
	}

	private void changed(Aspect anAspect) {
		this.setChanged();
		this.notifyObservers(anAspect);
		this.clearChanged();
	}
	
	private FileSystemView GetFilesystemView() {
		return filesystemView;
	}
	
	private void SetFilesystemView(FileSystemView aFilesystemView) {
		filesystemView = aFilesystemView;
		getInstance().changed(Aspect.FILESYSTEM_VIEW);
	}
	
	private void removeFromList(List<?> list, int[] indices) {
		int sub = 0;
		for (int index : indices) {
			list.remove(index-sub);
			sub++;
		}
	}
}

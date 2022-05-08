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

import java.awt.BorderLayout;
import javax.swing.JPanel;
import java.util.Observable;
import java.util.Observer;
import javax.swing.JFrame;
import javax.swing.JTabbedPane;
import java.awt.Dimension;
import java.io.File;
import javax.swing.Box;
import javax.swing.DefaultListModel;
import javax.swing.JFileChooser;
import javax.swing.JScrollPane;
import javax.swing.JList;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.filechooser.FileSystemView;

import fr.cnrs.mri.dialog.RemoteJFileChooser;
import fr.cnrs.mri.fileList.ListEditor;
import fr.cnrs.mri.macro.io.IOSettings.Aspect;

public class IOSettingsEditorView extends JFrame implements Observer {

	private static final long serialVersionUID = 1L;
	private JPanel jContentPane = null;
	private JTabbedPane jTabbedPane = null;
	private JPanel jPanel = null;
	private JPanel jPanel1 = null;
	private JPanel jPanel2 = null;
	private JScrollPane jScrollPane = null;
	private JList fileList = null;
	private JPanel jPanel3 = null;
	private JButton addFileListButton = null;
	private JButton editFileListButton = null;
	private JButton removeSelectedFileListsButton = null;
	private JScrollPane jScrollPane1 = null;
	private JList inputFoldersList = null;
	private JPanel jPanel4 = null;
	private JPanel jPanel5 = null;
	private JPanel jPanel6 = null;
	private JButton addInputFolderButton = null;
	private JButton removeSelectedInputFoldersButton = null;
	private JPanel jPanel7 = null;
	private JScrollPane jScrollPane2 = null;
	private JList outputFoldersList = null;
	private JPanel jPanel8 = null;
	private JButton addOutputFolderButton = null;
	private JButton removeSelectedOutputFoldersButton = null;

	@Override
	public void update(Observable sender, Object aspect) {
		if (aspect.equals(Aspect.FILE_LISTS)) this.updateFileLists();
		if (aspect.equals(Aspect.INPUT_FOLDERS)) this.updateInputFolders();
		if (aspect.equals(Aspect.OUTPUT_FOLDERS)) this.updateOutputFolders();
	}

	/**
	 * This is the default constructor
	 */
	public IOSettingsEditorView() {
		super();
		IOSettings.getInstance().addObserver(this);
		initialize();
	}

	/**
	 * This method initializes this
	 * 
	 * @return void
	 */
	private void initialize() {
		this.setSize(370, 293);
		this.setContentPane(getJContentPane());
		this.setTitle("IO Settings");
	}

	/**
	 * This method initializes jContentPane
	 * 
	 * @return javax.swing.JPanel
	 */
	private JPanel getJContentPane() {
		if (jContentPane == null) {
			jContentPane = new JPanel();
			jContentPane.setLayout(new BorderLayout());
			jContentPane.add(getJTabbedPane(), BorderLayout.CENTER);
		}
		return jContentPane;
	}

	/**
	 * This method initializes jTabbedPane	
	 * 	
	 * @return javax.swing.JTabbedPane	
	 */
	private JTabbedPane getJTabbedPane() {
		if (jTabbedPane == null) {
			jTabbedPane = new JTabbedPane();
			jTabbedPane.addTab("file lists", null, getJPanel(), null);
			jTabbedPane.addTab("input folders", null, getJPanel1(), null);
			jTabbedPane.addTab("output folders", null, getJPanel2(), null);
		}
		return jTabbedPane;
	}

	/**
	 * This method initializes jPanel	
	 * 	
	 * @return javax.swing.JPanel	
	 */
	private JPanel getJPanel() {
		if (jPanel == null) {
			jPanel = new JPanel();
			jPanel.setLayout(new BorderLayout());
			jPanel.add(getJScrollPane(), BorderLayout.CENTER);
			jPanel.add(getJPanel4(), BorderLayout.SOUTH);
		}
		return jPanel;
	}

	/**
	 * This method initializes jPanel1	
	 * 	
	 * @return javax.swing.JPanel	
	 */
	private JPanel getJPanel1() {
		if (jPanel1 == null) {
			jPanel1 = new JPanel();
			jPanel1.setLayout(new BorderLayout());
			jPanel1.add(getJScrollPane1(), BorderLayout.CENTER);
			jPanel1.add(getJPanel5(), BorderLayout.SOUTH);
		}
		return jPanel1;
	}

	/**
	 * This method initializes jPanel2	
	 * 	
	 * @return javax.swing.JPanel	
	 */
	private JPanel getJPanel2() {
		if (jPanel2 == null) {
			jPanel2 = new JPanel();
			jPanel2.setLayout(new BorderLayout());
			jPanel2.add(getJScrollPane2(), BorderLayout.CENTER);
			jPanel2.add(getJPanel7(), BorderLayout.SOUTH);
		}
		return jPanel2;
	}

	/**
	 * This method initializes jScrollPane	
	 * 	
	 * @return javax.swing.JScrollPane	
	 */
	private JScrollPane getJScrollPane() {
		if (jScrollPane == null) {
			jScrollPane = new JScrollPane();
			jScrollPane.setViewportView(getFileList());
		}
		return jScrollPane;
	}

	/**
	 * This method initializes fileList	
	 * 	
	 * @return javax.swing.JList	
	 */
	private JList getFileList() {
		if (fileList == null) {
			fileList = new JList(new DefaultListModel());
			updateFileLists();
		}
		return fileList;
	}

	/**
	 * This method initializes jPanel3	
	 * 	
	 * @return javax.swing.JPanel	
	 */
	private JPanel getJPanel3() {
		if (jPanel3 == null) {
			jPanel3 = new JPanel();
			jPanel3.setLayout(new BoxLayout(getJPanel3(), BoxLayout.X_AXIS));
			jPanel3.add(Box.createRigidArea(new Dimension(15,0)));
			jPanel3.add(getAddFileListButton(), null);
			jPanel3.add(Box.createRigidArea(new Dimension(15,0)));
			jPanel3.add(getEditFileListButton(), null);
			jPanel3.add(Box.createRigidArea(new Dimension(15,0)));
			jPanel3.add(getRemoveSelectedFileListsButton(), null);
			jPanel3.add(Box.createRigidArea(new Dimension(15,0)));
		}
		return jPanel3;
	}

	/**
	 * This method initializes addFileListButton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getAddFileListButton() {
		if (addFileListButton == null) {
			addFileListButton = new JButton();
			addFileListButton.setText("add...");
			addFileListButton.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					ListEditor listEditor = new ListEditor();
					listEditor.setFilesystemView(IOSettings.getFilesystemView());
					listEditor.setModal(true);
					listEditor.view().getAddButton().doClick();
					listEditor.show();
					IOSettings.addFileList(listEditor.getFilenameList());
				}
			});
		}
		return addFileListButton;
	}

	private void updateFileLists() {
		DefaultListModel list = (DefaultListModel) getFileList().getModel();
		list.removeAllElements();
		String[] lists = IOSettings.getFileLists().split(";");
		for (String aList : lists) {
			list.addElement(aList);
		}
	}
	
	private void updateInputFolders() {
		DefaultListModel list = (DefaultListModel) getInputFoldersList().getModel();
		list.removeAllElements();
		String[] folders = IOSettings.getInputFolders().split(",");
		for (String aFolder : folders) {
			list.addElement(aFolder);
		}
	}
	
	private void updateOutputFolders() {
		DefaultListModel list = (DefaultListModel) getOutputFoldersList().getModel();
		list.removeAllElements();
		String[] folders = IOSettings.getOutputFolders().split(",");
		for (String aFolder : folders) {
			list.addElement(aFolder);
		}
	}
	/**
	 * This method initializes editFileListButton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getEditFileListButton() {
		if (editFileListButton == null) {
			editFileListButton = new JButton();
			editFileListButton.setText("edit...");
			editFileListButton.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					int listIndex = getFileList().getSelectedIndex();
					if (listIndex==-1) return;
					String[] filenames = ((String) getFileList().getSelectedValue()).split(",");
					if (IOSettings.getFileList().equals(IOSettings.none())) return;
					ListEditor editor = new ListEditor();
					editor.setFilesystemView(IOSettings.getFilesystemView());
					editor.setModal(true);
					File[] files = new File[filenames.length];
					int index = 0;
					for (String filename : filenames) {
						files[index] = new File(filename);
						index++;
					}
					editor.addToList(files);
					editor.show();
					IOSettings.replaceFileList(listIndex, editor.getFilenameList());
				}
			});
		}
		return editFileListButton;
	}

	/**
	 * This method initializes removeSelectedFileListsButton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getRemoveSelectedFileListsButton() {
		if (removeSelectedFileListsButton == null) {
			removeSelectedFileListsButton = new JButton();
			removeSelectedFileListsButton.setText("remove selected");
			removeSelectedFileListsButton.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					int[] indices = getFileList().getSelectedIndices();
					if (indices.length==0) return;
					if (IOSettings.getFileList().equals(IOSettings.none())) return;
					IOSettings.removeFileLists(indices);
				}
			});
		}
		return removeSelectedFileListsButton;
	}

	/**
	 * This method initializes jScrollPane1	
	 * 	
	 * @return javax.swing.JScrollPane	
	 */
	private JScrollPane getJScrollPane1() {
		if (jScrollPane1 == null) {
			jScrollPane1 = new JScrollPane();
			jScrollPane1.setViewportView(getInputFoldersList());
		}
		return jScrollPane1;
	}

	/**
	 * This method initializes inputFoldersList	
	 * 	
	 * @return javax.swing.JList	
	 */
	private JList getInputFoldersList() {
		if (inputFoldersList == null) {
			inputFoldersList = new JList(new DefaultListModel());
			this.updateInputFolders();
		}
		return inputFoldersList;
	}

	/**
	 * This method initializes jPanel4	
	 * 	
	 * @return javax.swing.JPanel	
	 */
	private JPanel getJPanel4() {
		if (jPanel4 == null) {
			jPanel4 = new JPanel();
			jPanel4.setLayout(new BoxLayout(getJPanel4(), BoxLayout.Y_AXIS));
			jPanel4.add(getJPanel3(), null);
		}
		return jPanel4;
	}

	/**
	 * This method initializes jPanel5	
	 * 	
	 * @return javax.swing.JPanel	
	 */
	private JPanel getJPanel5() {
		if (jPanel5 == null) {
			jPanel5 = new JPanel();
			jPanel5.setLayout(new BoxLayout(getJPanel5(), BoxLayout.Y_AXIS));
			jPanel5.add(getJPanel6(), null);
		}
		return jPanel5;
	}

	/**
	 * This method initializes jPanel6	
	 * 	
	 * @return javax.swing.JPanel	
	 */
	private JPanel getJPanel6() {
		if (jPanel6 == null) {
			jPanel6 = new JPanel();
			jPanel6.setLayout(new BoxLayout(getJPanel6(), BoxLayout.X_AXIS));
			jPanel6.add(Box.createRigidArea(new Dimension(15,0)));
			jPanel6.add(getAddInputFolderButton(), null);
			jPanel6.add(Box.createRigidArea(new Dimension(15,0)));
			jPanel6.add(getRemoveSelectedInputFoldersButton(), null);
			jPanel6.add(Box.createRigidArea(new Dimension(15,0)));
		}
		return jPanel6;
	}

	/**
	 * This method initializes addInputFolderButton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getAddInputFolderButton() {
		if (addInputFolderButton == null) {
			addInputFolderButton = new JButton();
			addInputFolderButton.setText("add...");
			addInputFolderButton.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					FileSystemView filesystemView = IOSettings.getFilesystemView();
					JFileChooser fileChooser = RemoteJFileChooser.getFileChooserFor(filesystemView);
					fileChooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
					fileChooser.setMultiSelectionEnabled(true);
					fileChooser.showOpenDialog(null);
					File[] files = fileChooser.getSelectedFiles();
					for (File file : files) {
						IOSettings.addInputFolder(file.getAbsolutePath());
					}
				}
			});
		}
		return addInputFolderButton;
	}

	/**
	 * This method initializes removeSelectedInputFoldersButton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getRemoveSelectedInputFoldersButton() {
		if (removeSelectedInputFoldersButton == null) {
			removeSelectedInputFoldersButton = new JButton();
			removeSelectedInputFoldersButton.setText("remove selected");
			removeSelectedInputFoldersButton.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					int[] indices = getInputFoldersList().getSelectedIndices();
					if (indices.length==0) return;
					if (IOSettings.getInputFolders().equals(IOSettings.none())) return;
					IOSettings.removeInputFolders(indices);
				}
			});
		}
		return removeSelectedInputFoldersButton;
	}

	/**
	 * This method initializes jPanel7	
	 * 	
	 * @return javax.swing.JPanel	
	 */
	private JPanel getJPanel7() {
		if (jPanel7 == null) {
			jPanel7 = new JPanel();
			jPanel7.setLayout(new BoxLayout(getJPanel7(), BoxLayout.Y_AXIS));
			jPanel7.add(getJPanel8(), null);
		}
		return jPanel7;
	}

	/**
	 * This method initializes jScrollPane2	
	 * 	
	 * @return javax.swing.JScrollPane	
	 */
	private JScrollPane getJScrollPane2() {
		if (jScrollPane2 == null) {
			jScrollPane2 = new JScrollPane();
			jScrollPane2.setViewportView(getOutputFoldersList());
		}
		return jScrollPane2;
	}

	/**
	 * This method initializes jList2	
	 * 	
	 * @return javax.swing.JList	
	 */
	private JList getOutputFoldersList() {
		if (outputFoldersList == null) {
			outputFoldersList = new JList(new DefaultListModel());
			this.updateOutputFolders();
		}
		return outputFoldersList;
	}

	/**
	 * This method initializes jPanel8	
	 * 	
	 * @return javax.swing.JPanel	
	 */
	private JPanel getJPanel8() {
		if (jPanel8 == null) {
			jPanel8 = new JPanel();
			jPanel8.setLayout(new BoxLayout(getJPanel8(), BoxLayout.X_AXIS));
			jPanel8.add(Box.createRigidArea(new Dimension(15,0)));
			jPanel8.add(getAddOutputFolderButton(), null);
			jPanel8.add(Box.createRigidArea(new Dimension(15,0)));
			jPanel8.add(getRemoveSelectedOutputFoldersButton(), null);
			jPanel8.add(Box.createRigidArea(new Dimension(15,0)));
		}
		return jPanel8;
	}

	/**
	 * This method initializes addOutputFolderButton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getAddOutputFolderButton() {
		if (addOutputFolderButton == null) {
			addOutputFolderButton = new JButton();
			addOutputFolderButton.setText("add...");
			addOutputFolderButton.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					FileSystemView filesystemView = IOSettings.getFilesystemView();
					JFileChooser fileChooser = RemoteJFileChooser.getFileChooserFor(filesystemView);
					fileChooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
					fileChooser.setMultiSelectionEnabled(true);
					fileChooser.showOpenDialog(null);
					File[] files = fileChooser.getSelectedFiles();
					for (File file : files) {
						IOSettings.addOutputFolder(file.getAbsolutePath());
					}
				}
			});
		}
		return addOutputFolderButton;
	}

	/**
	 * This method initializes removeSelectedOutputFoldersButton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getRemoveSelectedOutputFoldersButton() {
		if (removeSelectedOutputFoldersButton == null) {
			removeSelectedOutputFoldersButton = new JButton();
			removeSelectedOutputFoldersButton.setText("remove selected");
			removeSelectedOutputFoldersButton
					.addActionListener(new java.awt.event.ActionListener() {
						public void actionPerformed(java.awt.event.ActionEvent e) {
							int[] indices = getOutputFoldersList().getSelectedIndices();
							if (indices.length==0) return;
							if (IOSettings.getOutputFolders().equals(IOSettings.none())) return;
							IOSettings.removeOutputFolders(indices);
						}
					});
		}
		return removeSelectedOutputFoldersButton;
	}

}  //  @jve:decl-index=0:visual-constraint="10,10"

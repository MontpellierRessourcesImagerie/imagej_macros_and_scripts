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

import fr.cnrs.mri.dialog.RemoteJFileChooser;
import ij.IJ;
import ij.io.OpenDialog;
import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.io.File;
import java.util.Observable;
import java.util.Observer;
import java.util.Vector;
import javax.swing.JButton;
import javax.swing.JFileChooser;
import javax.swing.JList;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextField;
import javax.swing.filechooser.FileSystemView;

import java.awt.Dimension;

/**
 * The gui of the list-editor. Allows to add files, to select files manually or by 
 * using sub-strings of the path and to remove selected files. When a file is double-clicked,
 * it is opened using ImageJ.
 * 
 * @author baecker
 *
 */
public class ListEditorView extends javax.swing.JDialog implements Observer {
	private static final long serialVersionUID = 1L;
	private javax.swing.JPanel ivjJFrameContentPane = null;
	private JPanel jPanel = null;
	private JPanel jPanel1 = null;
	private JScrollPane jScrollPane = null;
	private JList theList = null;
	private JButton addButton = null;
	private JButton removeSelectedButton = null;
	private JButton closeButton = null;
	protected ListEditor model;
	private JPanel jPanel2 = null;
	private JPanel jPanel3 = null;
	private JPanel filterPanel = null;
	private JButton selectFilteredButton = null;
	private JTextField filterTextField = null;

	public ListEditorView(ListEditor model) {
		super();
		this.model = model;
		model.addObserver(this);
		initialize();
	}
	
	/**
	 * Return the JFrameContentPane property value.
	 * @return javax.swing.JPanel
	 */
	public javax.swing.JPanel getJFrameContentPane() {
		if (ivjJFrameContentPane == null) {
			ivjJFrameContentPane = new javax.swing.JPanel();
			ivjJFrameContentPane.setName("JFrameContentPane");
			ivjJFrameContentPane.setLayout(new BorderLayout());
			ivjJFrameContentPane.add(getJPanel(), java.awt.BorderLayout.CENTER);
			ivjJFrameContentPane.add(getJPanel1(), java.awt.BorderLayout.SOUTH);
		}
		return ivjJFrameContentPane;
	}

	/**
	 * Initialize the class.
	 */
	private void initialize() {

		// this.setIconImage(Toolkit.getDefaultToolkit().getImage(getClass().getResource("/resources/images/icon.gif")));
		this.setName("JFrame1");
		this.setModal(true);
		this
				.setDefaultCloseOperation(javax.swing.WindowConstants.DISPOSE_ON_CLOSE);
		this.setBounds(45, 25, 426, 273);
		this.setTitle("list editor");
		this.setContentPane(getJFrameContentPane());

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
			jPanel.add(getJScrollPane(), java.awt.BorderLayout.CENTER);
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
			jPanel1.setPreferredSize(new java.awt.Dimension(100,60));
			jPanel1.add(getJPanel2(), java.awt.BorderLayout.WEST);
			jPanel1.add(getJPanel3(), java.awt.BorderLayout.EAST);
			jPanel1.add(getFilterPanel(), java.awt.BorderLayout.SOUTH);
		}
		return jPanel1;
	}
	/**
	 * This method initializes jScrollPane	
	 * 	
	 * @return javax.swing.JScrollPane	
	 */    
	private JScrollPane getJScrollPane() {
		if (jScrollPane == null) {
			jScrollPane = new JScrollPane();
			jScrollPane.setViewportView(getTheList());
		}
		return jScrollPane;
	}
	/**
	 * This method initializes theList	
	 * 	
	 * @return javax.swing.JList	
	 */    
	private JList getTheList() {
		if (theList == null) {
			theList = new JList();
			this.handleListChanged();
			theList.addMouseListener(new java.awt.event.MouseAdapter() {
				public void mouseClicked(java.awt.event.MouseEvent e) {
					if (e.getClickCount() == 2) {
						int index = theList.locationToIndex(e.getPoint());
						File theFile = (File) theList.getModel().getElementAt(index);		
						IJ.open(theFile.getAbsolutePath());			             
			          }
				}
			});
		}
		return theList;
	}
	/**
	 * This method initializes addButton	
	 * 	
	 * @return javax.swing.JButton	
	 */    
	public JButton getAddButton() {
		if (addButton == null) {
			addButton = new JButton();
			addButton.setText("add...");
			addButton.setBorder(javax.swing.BorderFactory.createBevelBorder(javax.swing.border.BevelBorder.RAISED));
			addButton.setBounds(5, 5, 66, 19);
			addButton.setPreferredSize(new java.awt.Dimension(45,19));
			addButton.addActionListener(new java.awt.event.ActionListener() { 
				public void actionPerformed(java.awt.event.ActionEvent e) {    
					if (model.useSequenceOpener) {
						getFilesWithSequenceOpener();
					} else {
						getFilesWithFileChooser();
					}
				}
			});
		}
		return addButton;
	}
	/**
	 * 
	 */
	protected void getFilesWithSequenceOpener() {
		MRIFolderOpener opener = new MRIFolderOpener();
		opener.run(null);
		File[] list = opener.getFileList();
		model.addToList(list);
	}

	/**
	 * This method initializes removeSelectedButton	
	 * 	
	 * @return javax.swing.JButton	
	 */    
	private JButton getRemoveSelectedButton() {
		if (removeSelectedButton == null) {
			removeSelectedButton = new JButton();
			removeSelectedButton.setText("remove selected");
			removeSelectedButton.setBorder(javax.swing.BorderFactory.createBevelBorder(javax.swing.border.BevelBorder.RAISED));
			removeSelectedButton.setBounds(85, 5, 137, 19);
			removeSelectedButton.addActionListener(new java.awt.event.ActionListener() { 
				public void actionPerformed(java.awt.event.ActionEvent e) {    
					Object[] toBeRemoved = getTheList().getSelectedValues();
					model.removeElementsFromList(toBeRemoved);
				}
			});
		}
		return removeSelectedButton;
	}
	/**
	 * This method initializes closeButton	
	 * 	
	 * @return javax.swing.JButton	
	 */    
	private JButton getCloseButton() {
		if (closeButton == null) {
			closeButton = new JButton();
			closeButton.setText("close");
			closeButton.setBorder(javax.swing.BorderFactory.createBevelBorder(javax.swing.border.BevelBorder.RAISED));
			closeButton.setPreferredSize(new java.awt.Dimension(45,19));
			closeButton.setBounds(130, 5, 65, 19);
			closeButton.addActionListener(new java.awt.event.ActionListener() { 
				public void actionPerformed(java.awt.event.ActionEvent e) {    
					dispose();
				}
			});
		}
		return closeButton;
	}

	/* (non-Javadoc)
	 * @see java.util.Observer#update(java.util.Observable, java.lang.Object)
	 */
	public void update(Observable aModel, Object anAspect) {
		if (anAspect.equals("list")) this.handleListChanged();
		
	}

	private void handleListChanged() {
		this.getTheList().setListData(new Vector<File>(model.getList()));
		
	}
	/**
	 * This method initializes jPanel2	
	 * 	
	 * @return javax.swing.JPanel	
	 */    
	private JPanel getJPanel2() {
		if (jPanel2 == null) {
			jPanel2 = new JPanel();
			jPanel2.setLayout(null);
			jPanel2.setPreferredSize(new Dimension(230, 30));
			jPanel2.add(getAddButton(), null);
			jPanel2.add(getRemoveSelectedButton(), null);
		}
		return jPanel2;
	}
	/**
	 * This method initializes jPanel3	
	 * 	
	 * @return javax.swing.JPanel	
	 */    
	public JPanel getJPanel3() {
		if (jPanel3 == null) {
			jPanel3 = new JPanel();
			jPanel3.setLayout(null);
			jPanel3.setPreferredSize(new java.awt.Dimension(200,29));
			jPanel3.add(getCloseButton(), null);
		}
		return jPanel3;
	}

	protected void getFilesWithFileChooser() {
		FileSystemView filesystemView = model.getFilesystemView();
		JFileChooser fileChooser = RemoteJFileChooser.getFileChooserFor(filesystemView);
		fileChooser.setFileSelectionMode(JFileChooser.FILES_AND_DIRECTORIES);
		fileChooser.setMultiSelectionEnabled(true);
		fileChooser.addChoosableFileFilter(ListEditor.getImageFileFilter());
		fileChooser.addChoosableFileFilter(ListEditor.getTiffFileFilter());
		int returnVal = fileChooser.showOpenDialog(model.view());
		if (returnVal != JFileChooser.APPROVE_OPTION) return;
		model.addToList(fileChooser.getSelectedFiles(), fileChooser.getFileFilter());
		File aFile = fileChooser.getSelectedFile();
		String currentFolder = fileChooser.getSelectedFile().getAbsolutePath();
		if (!aFile.isDirectory() || fileChooser.getSelectedFiles().length>1) {
			currentFolder = fileChooser.getSelectedFile().getParent();
		}
		OpenDialog.setDefaultDirectory(currentFolder);
	}

	/**
	 * This method initializes filterPanel	
	 * 	
	 * @return javax.swing.JPanel	
	 */
	private JPanel getFilterPanel() {
		if (filterPanel == null) {
			FlowLayout flowLayout = new FlowLayout();
			flowLayout.setAlignment(java.awt.FlowLayout.LEFT);
			filterPanel = new JPanel();
			filterPanel.setLayout(flowLayout);
			filterPanel.setPreferredSize(new java.awt.Dimension(10,30));
			filterPanel.add(getFilterTextField(), null);
			filterPanel.add(getSelectFilteredButton(), null);
		}
		return filterPanel;
	}

	/**
	 * This method initializes selectFilteredButton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getSelectFilteredButton() {
		if (selectFilteredButton == null) {
			selectFilteredButton = new JButton();
			selectFilteredButton.setText("select");
			selectFilteredButton.setPreferredSize(new java.awt.Dimension(99,20));
			selectFilteredButton.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					model.view().selectContaining(getFilterTextField().getText());
				}
			});
		}
		return selectFilteredButton;
	}

	protected void selectContaining(String text) {
		int[] matching = model.getItemsMatching(text);
		this.getTheList().setSelectedIndices(matching);
	}

	/**
	 * This method initializes filterTextField	
	 * 	
	 * @return javax.swing.JTextField	
	 */
	private JTextField getFilterTextField() {
		if (filterTextField == null) {
			filterTextField = new JTextField();
			filterTextField.setPreferredSize(new java.awt.Dimension(210,20));
		}
		return filterTextField;
	}
}

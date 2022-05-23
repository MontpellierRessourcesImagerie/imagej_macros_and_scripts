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
package fr.cnrs.mri.dialog;

import ij.util.Java2;
import java.awt.BorderLayout;
import java.util.Date;
import java.util.logging.Handler;
import java.util.logging.LogRecord;
import java.util.logging.Logger;
import javax.swing.JPanel;
import javax.swing.JFrame;
import javax.swing.JButton;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import java.awt.Toolkit;

/**
* A simple user interface for the modal-dialog-killer. Allows to start
* and stop the modal-dialog-killer and shows log-messages. The messages
* contain the titles of the dialogs that have been made modeless.
* 
* @author baecker
*
*/
public class ModalDialogKillerView extends JFrame {

	private static final long serialVersionUID = 1L;
	private JPanel jContentPane = null;
	private JButton startStopButton = null;
	private JScrollPane jScrollPane = null;
	private JTextArea jTextArea = null;

	/**
	 * This is the default constructor
	 */
	public ModalDialogKillerView() {
		super();
		Java2.setSystemLookAndFeel();
		initialize();
		Logger.getLogger("fr.cnrs.mri.tools.dialog").addHandler(new Handler() {
			@Override
			public void publish(LogRecord record) {
				getJTextArea().append(new Date(record.getMillis()).toString() + " - " + record.getMessage() + "\n");
			}
			@Override
			public void flush() {
			}
			@Override
			public void close() throws SecurityException {
			}
		}
		);
	}

	/**
	 * This method initializes this
	 * 
	 * @return void
	 */
	private void initialize() {
		this.setSize(440, 202);
		this.setIconImage(Toolkit.getDefaultToolkit().getImage(getClass().getResource("/fr/cnrs/mri/tools/resources/images/logomri1.jpg")));
		this.setContentPane(getJContentPane());
		this.setTitle("Modal Dialog Killer");
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
			jContentPane.add(getStartStopButton(), BorderLayout.NORTH);
			jContentPane.add(getJScrollPane(), BorderLayout.CENTER);
		}
		return jContentPane;
	}

	/**
	 * This method initializes startStopButton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getStartStopButton() {
		if (startStopButton == null) {
			startStopButton = new JButton();
			startStopButton.setText("start");
			startStopButton.addActionListener(new java.awt.event.ActionListener() {
				public void actionPerformed(java.awt.event.ActionEvent e) {
					ModalDialogKiller mdk = ModalDialogKiller.getInstance();
					if (mdk.isRunning()) {
						mdk.stop();
						getStartStopButton().setText("start");
					} else {
						mdk.start();
						getStartStopButton().setText("stop");
					}
				}
			});
		}
		return startStopButton;
	}

	/**
	 * This method initializes jScrollPane	
	 * 	
	 * @return javax.swing.JScrollPane	
	 */
	private JScrollPane getJScrollPane() {
		if (jScrollPane == null) {
			jScrollPane = new JScrollPane();
			jScrollPane.setViewportView(getJTextArea());
		}
		return jScrollPane;
	}

	/**
	 * This method initializes jTextArea	
	 * 	
	 * @return javax.swing.JTextArea	
	 */
	private JTextArea getJTextArea() {
		if (jTextArea == null) {
			jTextArea = new JTextArea();
		}
		return jTextArea;
	}

}  //  @jve:decl-index=0:visual-constraint="10,10"

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

package fr.cnrs.mri.logging;

import java.awt.BorderLayout;
import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;

import javax.swing.JPanel;
import java.util.Observable;
import java.util.Observer;

import javax.swing.JFrame;
import javax.swing.JScrollPane;
import javax.swing.JTextPane;
import javax.swing.WindowConstants;
import java.awt.Toolkit;

/**
* A simple user interface for the log-viewer. The messages are displayed in a window.
* When the window is closed, the log-viewer is closed, as well.
* 
* @author baecker
*
*/
public class LogViewerView extends JFrame implements Observer, WindowListener {

	private static final long serialVersionUID = 1L;
	private JPanel jContentPane = null;
	private LogViewer model;
	private JScrollPane jScrollPane = null;
	private JTextPane jTextPane = null;

	@Override
	public void update(Observable o, Object aspect) {
		if (o!=model) return;
		String newLogText = (String)aspect;
		this.getJTextPane().setText(newLogText);
	}

	/**
	 * This is the default constructor
	 */
	public LogViewerView() {
		super();
		this.model = new LogViewer("", 100);
		model.addObserver(this);
		this.addWindowListener(this);
		initialize();
	}

	public LogViewerView(LogViewer logViewer) {
		super();
		this.model = logViewer;
		model.addObserver(this);
		this.addWindowListener(this);
		initialize();
	}

	/**
	 * This method initializes this
	 * 
	 * @return void
	 */
	private void initialize() {
		this.setSize(300, 200);
		this.setIconImage(Toolkit.getDefaultToolkit().getImage(getClass().getResource("/fr/cnrs/mri/logging/resources/logomri1.jpg")));
		this.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
		this.setContentPane(getJContentPane());
		this.setTitle("Log Viewer");
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
			jContentPane.add(getJScrollPane(), BorderLayout.CENTER);
		}
		return jContentPane;
	}

	/**
	 * This method initializes jScrollPane	
	 * 	
	 * @return javax.swing.JScrollPane	
	 */
	private JScrollPane getJScrollPane() {
		if (jScrollPane == null) {
			jScrollPane = new JScrollPane();
			jScrollPane.setViewportView(getJTextPane());
		}
		return jScrollPane;
	}

	/**
	 * This method initializes jTextPane	
	 * 	
	 * @return javax.swing.JTextPane	
	 */
	private JTextPane getJTextPane() {
		if (jTextPane == null) {
			jTextPane = new JTextPane();
		}
		return jTextPane;
	}

	@Override
	public void windowClosing(WindowEvent e) {
		model.close();
	}

	@Override
	public void windowActivated(WindowEvent arg0) {
		// do nothing
	}

	@Override
	public void windowClosed(WindowEvent arg0) {
		// do nothing	
	}

	@Override
	public void windowDeactivated(WindowEvent arg0) {
		// do nothing	
	}

	@Override
	public void windowDeiconified(WindowEvent arg0) {
		// do nothing
	}

	@Override
	public void windowIconified(WindowEvent arg0) {
		// do nothing
	}

	@Override
	public void windowOpened(WindowEvent arg0) {
		// do nothing	
	}
}

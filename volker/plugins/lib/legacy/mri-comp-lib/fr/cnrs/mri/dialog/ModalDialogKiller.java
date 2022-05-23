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

import ij.gui.WaitForUserDialog;
import java.awt.Dialog;
import java.awt.KeyboardFocusManager;
import java.awt.Window;
import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.util.logging.Logger;
import fr.cnrs.mri.util.logging.LoggingUtil;

/**
* While running, modal dialogs, and ImageJ's WaitForUser-dialogs
* and GenericDialogs are made modeless and closed or disposed off, 
* so that the execution in the thread continues inspite of the dialog.
* 
* @author baecker
*
*/
public class ModalDialogKiller implements PropertyChangeListener {

	private Logger logger;
	private static ModalDialogKiller instance;
	private boolean isRunning = false;
	private KeyboardFocusManager keyboardFocusManager;
	private ModalDialogKillerView view;

	public ModalDialogKiller() {
		logger = LoggingUtil.getLoggerFor(this); 
	}

	public void start() {
		keyboardFocusManager = KeyboardFocusManager.getCurrentKeyboardFocusManager();
		this.stop();
		keyboardFocusManager.addPropertyChangeListener("activeWindow", this);
		this.setRunning(true);
	}
		
	public void stop() {
		keyboardFocusManager.removePropertyChangeListener("activeWindow", this);
		this.setRunning(false);
	} 
	
	@Override
	public void propertyChange(PropertyChangeEvent event) {
		if (event.getPropertyName()!="activeWindow") return;
		Window newWin = (Window)event.getNewValue();
		if (newWin==null) return;
		if (!(newWin instanceof Dialog)) return;
		Dialog dialog = (Dialog)newWin;
		if (dialog instanceof WaitForUserDialog) ((WaitForUserDialog)dialog).close(); 
		else { 
			if (!dialog.isModal()) return;
			dialog.setModalityType(Dialog.ModalityType.MODELESS);
			dialog.setVisible(false);
			dialog.dispose();
		}
		logger.info(dialog.getClass().getName() + ":" + dialog.getTitle());
	}

	public static ModalDialogKiller getInstance() {
		if (instance==null) instance = new ModalDialogKiller();
		return instance;
	}

	public boolean isRunning() {
		return isRunning;
	}
	
	private void setRunning(boolean value) {
		this.isRunning = value;		 
	}
	
	public void show() {
		if (view == null) view = new ModalDialogKillerView();
		view.setVisible(true);
	}
}

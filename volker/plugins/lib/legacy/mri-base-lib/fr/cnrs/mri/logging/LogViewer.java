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

import java.util.Observable;
import java.util.Observer;
import java.util.logging.Logger;
import java.util.logging.SimpleFormatter;

/**
 * A simple log-viewer. A viewer is created for a given subsystem and
 * sends the log text to observers whenever a new message is added by
 * the java logging system. 
 * 
 * @author baecker
 *
 */
public class LogViewer extends Observable implements Observer {

	private StringListHandler handler;
	private LogViewerView view;
	private String subsystem;

	public void show() {
		this.getView().setVisible(true);
	}
	
	public LogViewerView getView() {
		if (this.view==null) this.view = new LogViewerView(this);
		return view;
	}

	public LogViewer(String subsystem, int size) {
		this.subsystem = subsystem;
		this.handler = new StringListHandler(size, this);
		handler.setFormatter(new SimpleFormatter());
		Logger logger = Logger.getLogger(subsystem);
		logger.addHandler(handler);
	}
	
	@Override
	public void update(Observable sender, Object aspect) {
		this.changed(aspect);
	}

	private void changed(Object aspect) {
		this.setChanged();
		this.notifyObservers(aspect);
		this.clearChanged();
	}
	
	public void close() {
		Logger logger = Logger.getLogger(subsystem);
		logger.removeHandler(handler);
		handler.close();
	}
}

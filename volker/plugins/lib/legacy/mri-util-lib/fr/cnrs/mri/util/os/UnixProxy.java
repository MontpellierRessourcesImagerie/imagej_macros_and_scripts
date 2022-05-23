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
package fr.cnrs.mri.util.os;

import java.io.IOException;

import fr.cnrs.mri.util.logging.LoggingUtil;

/**
 * The os proxy implementation for unix/linux computers.
 *
 * @author Volker Baecker
 */
public class UnixProxy extends OperatingSystemProxy {
	
	@Override
	public void logout() {
		while(true) this.execute("logoff");
	}

	@Override
	public void startWindowsManager() {
		// for the time being this is not done on unix systems
	}

	@Override
	public void execute(String command) {
		this.runCommand(command);
	}

	@Override
	public void move(String sourceFile, String destFile) {
		this.executeWaiting("mv \"" + sourceFile + "\" \"" + destFile+ "\"");
	}
	
	@Override
	public void executeWaiting(String command) {
		Process process = this.runCommand(command);
		if (process==null) return;
		boolean finished = false;
		while (!finished) {
			boolean errorOccured = false;
			try {
				process.exitValue();
				if (!errorOccured) finished = true;
			} catch (IllegalThreadStateException e) {
				errorOccured = true;
			}
		}
	}

	/**
	 * Answer whether the current operating system is unix (or linux)
	 * @return true if the system is unix (or linux)
	 */
	@Override
	public boolean isUnix() {
		return true;
	}
	
	private Process runCommand(String command)  {
		String[] commandStrings = new String[3];
		commandStrings[0] =  "/bin/sh";
		commandStrings[1] =  "-c";
		commandStrings[2] =  command;
		Process process = null;
		try {
			process = Runtime.getRuntime().exec(commandStrings);
		} catch (IOException e) {
			LoggingUtil.getLoggerFor(this.getClass()).warning(LoggingUtil.getMessageAndStackTrace(e));
		}
		return process;
	}
}

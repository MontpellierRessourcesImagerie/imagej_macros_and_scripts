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

import java.io.File;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.sql.Timestamp;

/**
 * The operating system proxy handles the communication with
 * the underlying operating system. Information that has to be gathered
 * in an os dependent way is provided by it.
 * 
 * @author Volker Baecker
 */
public abstract class OperatingSystemProxy {

	/**
	 * The current instance of the proxy.
	 */
	private static OperatingSystemProxy current;
	
	/**
	 * Answer the current os proxy. Create one according to the operating
	 * system if no current proxy is set.
	 * 
	 * @return the current os proxy.
	 */
	public static OperatingSystemProxy current() {
		if (current==null) {
			String os = operatingSystem().toLowerCase();
			current = new UnixProxy();
			if (os.indexOf("windows")!=-1) current = new WindowsProxy();
			if (os.indexOf("linux")!=-1) current = new UnixProxy();
			if (os.indexOf("mac")!=-1)current = new MacProxy();
		}
		return current;
	}
	
	/**
	 * Answer a string identifying the operating system
	 * 
	 * @return a string identifying the operating system
	 */
	public static String operatingSystem() {
		String os = System.getProperty( "os.name" );
		return os;
	}
	
	/**
	 * Answer the name of the user who runs the operating system session.
	 *  
	 * @return the name of the user
	 */
	public String username() {
		String username = System.getProperty("user.name");
		return username;
	}
	
	/**
	 * Answer the name of the machine from the operating system.
	 * 
	 * @return the hostname of the machine
	 * @throws UnknownHostException
	 */
	public String hostname() throws UnknownHostException {
		InetAddress localHost = InetAddress.getLocalHost();
		return localHost.getHostName();
	}
	
	/**
	 * Answer the ip-address of the machine.
	 * 
	 * @return the ip-address of the machine
	 * @throws UnknownHostException
	 */
	public String ipAddress() throws UnknownHostException {
		InetAddress localHost = InetAddress.getLocalHost();
		return localHost.getHostAddress();
	}
	
	/**
	 * Answer the file creation date for the given file. On systems that don't
	 * manage file creation dates the date of the last modification is answered.
	 * 
	 * @param file the file 
	 * @return the creation date of the file or the date of the last modification.
	 */
	public Timestamp getFileCreationDate(File file) {
		Timestamp date = new Timestamp(file.lastModified());
		return date;
	}
	
	/**
	 * Answer whether the current operating system is windows
	 * @return true if the system is windows
	 */
	public boolean isWindows() {
		return false;
	}
	
	/**
	 * Answer whether the current operating system is unix (or linux)
	 * @return true if the system is unix (or linux)
	 */
	public boolean isUnix() {
		return false;
	}
	
	/**
	 * Answer whether the current operating system is mac
	 * @return true if the system is mac
	 */
	public boolean isMac() {
		return false;
	}
	
	/**
	 * Run a window manager like for example the windows shell explorer.
	 */
	abstract public void startWindowsManager();

	/**
	 * Execute the given command in the operating system.
	 * The execution continues directly without waiting for the end of the process.
	 * @param command: the command 
	 */
	abstract public void execute(String command);

	/**
	 * Execute the given command in the operating system.
	 * The execution waits for the end of the process.
	 * @param command: the command 
	 */
	abstract public void executeWaiting(String command);
	
	/**
	 * Close the current operating system session.
	 */
	abstract public void logout();
	
	/**
	 * Move the file with the complete path sourceFile to the file destFile.
	 * @param sourceFile	the file to move
	 * @param destFile		the result file
	 */
	abstract public void move(String sourceFile, String destFile);
}

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

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.Timestamp;

import fr.cnrs.mri.util.logging.LoggingUtil;

/**
 * The os proxy implementation for windows machines.
 *
 * @author Volker Baecker
 */
public class WindowsProxy extends OperatingSystemProxy {

	private String batchFileContent = "@echo off" + "\r\n" +
					"dir /TW %1 | find %2 /i > \"%temp%\\temp.txt\"" + "\r\n" +
					"for /F \"tokens=1 delims= \" %%i in (%temp%\\temp.txt) do set VERI1=%%i" + "\r\n" +
					"for /F \"tokens=2 delims= \" %%j in (%temp%\\temp.txt) do set VERI2=%%j"+ "\r\n" +
					"echo %VERI1% %VERI2%" + "\r\n" +
					"set VERI1=" + "\r\n" +
					"set VERI2=";
	@Override
	public void logout() {
		String logoffCommand = "shutdown -l -f";
		while(true) this.execute(logoffCommand);
	}
	
	@Override
	public void startWindowsManager() {
		String command = "explorer.exe";
		this.execute(command);
	}
	
	@Override
	public void execute(String command) {
		try {
			Runtime.getRuntime().exec("cmd /C " + command);
		} catch (IOException e) {
			LoggingUtil.getLoggerFor(WindowsProxy.class).warning(LoggingUtil.getMessageAndStackTrace(e));
		}
	}
	
	@Override
	public Timestamp getFileCreationDate(File file) {
		BufferedReader br = null;
		Timestamp result = null;
		String line = null;
		try {
			this.createBatchFile();
			String command = System.getProperty("java.io.tmpdir") + "creationdate.bat "+ "\"" + file.getAbsolutePath() + "\"" + " \"" +file.getName()+"\"";
			System.out.println(command);
			Process output = Runtime.getRuntime().exec(command);
			br = new BufferedReader (new InputStreamReader(output.getInputStream()));
			line = br.readLine();
			result = Timestamp.valueOf(getTimestampStringFromDirOutput(line));
		} catch (IOException e) {
			LoggingUtil.getLoggerFor(WindowsProxy.class).warning(LoggingUtil.getMessageAndStackTrace(e));
		} finally {
			closeStream(br);
		}
		return result;
	}
	
	private void createBatchFile() throws IOException {
	    // Create file 
		String tmpdir = System.getProperty("java.io.tmpdir");
	    FileWriter fstream = new FileWriter(tmpdir + "/creationdate.bat");
	    BufferedWriter out = new BufferedWriter(fstream);
	    out.write(this.batchFileContent);
	    //Close the output stream
	    out.close();
	}

	/**
	 * Answer a string in the timestamp format: yyyy-mm-dd hh:mm:ss
	 * 
	 * @param line
	 * @return
	 */
	public String getTimestampStringFromDirOutput(String line) {
		String info = line.replace(" ", "");
		String dateString = info.substring(6, 10) + "-" + info.substring(3, 5) + "-" + info.substring(0,2);
		String timeString = info.substring(10,15);
		String timestampString = dateString + " " + timeString + ":00";
		return timestampString;
	}

	/**
	 * Close the stream if it is not null.
	 * 
	 * @param br
	 */
	private void closeStream(BufferedReader br) {
		if (br != null)
			try {
				br.close();
			} catch (IOException e) {
				LoggingUtil.getLoggerFor(WindowsProxy.class).info(
						LoggingUtil.getMessageAndStackTrace(e));
			}
	}

	@Override
	public void move(String sourceFile, String destFile) {
		this.executeWaiting("(move " + sourceFile.replace("/", "\\") + " " + destFile.replace("/", "\\") + ")");
	}

	@Override
	public void executeWaiting(String command) {
		try {
			Process process = Runtime.getRuntime().exec("cmd /C " + command);
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
		} catch (IOException e) {
			LoggingUtil.getLoggerFor(WindowsProxy.class).warning(LoggingUtil.getMessageAndStackTrace(e));
		}
	}
	
	/**
	 * Answer whether the current operating system is windows
	 * @return true if the system is windows
	 */
	@Override
	public boolean isWindows() {
		return true;
	}
}

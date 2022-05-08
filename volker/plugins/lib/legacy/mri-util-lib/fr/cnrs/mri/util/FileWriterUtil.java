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
package fr.cnrs.mri.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import fr.cnrs.mri.util.logging.LoggingUtil;


public class FileWriterUtil {
	
	/**
	 * Write the given data to the given output stream and close the stream.
	 * Answers false if an io-exception occured and true otherwise.
	 * 
	 * @param data
	 * @param outputStream
	 * @return false if an io-exception occured.
	 */
	public static boolean writeData(byte[] data, FileOutputStream outputStream) {
		boolean result = true;
		try {
			outputStream.write(data);
			outputStream.close();
		} catch (IOException e) {
			result = false;
			LoggingUtil.getLoggerFor(FileWriterUtil.class).warning(LoggingUtil.getMessageAndStackTrace(e));
		}
		return result;
	}
	
	/**
	 * Create an output stream for the file with the given path. Not existing directories
	 * in the path are created. If the file doesn't exist it will be created. If append is
	 * true, the output stream will be created with the append option meaning that data
	 * will be added at the end. 
	 * 
	 * @param path		the path to the file that will be written
	 * @return			an output stream to the file with the given path
	 */
	public static FileOutputStream getOutputStreamForFile(String path, boolean append) {
		FileOutputStream outputStream = null;
		boolean error = false;
		try {
			File tmpFile = new File(path);
			if (!tmpFile.exists()) {
				tmpFile.getParentFile().mkdirs();
				tmpFile.createNewFile();
			}
			outputStream = new FileOutputStream(tmpFile, append);
		} catch (FileNotFoundException e) {
			error = true;
			LoggingUtil.getLoggerFor(FileWriterUtil.class).warning(LoggingUtil.getMessageAndStackTrace(e));
		} catch (IOException e) {
			error = true;
			LoggingUtil.getLoggerFor(FileWriterUtil.class).warning(LoggingUtil.getMessageAndStackTrace(e));
		} finally {
			if (error && outputStream!=null)
				try {
					outputStream.close();
					outputStream = null;
				} catch (IOException e1) {
					LoggingUtil.getLoggerFor(FileWriterUtil.class).warning(LoggingUtil.getMessageAndStackTrace(e1));
				}
		}
		return outputStream;
	}
	
	
	/**
	 *  The method copy the file sourcefile in the file destinationFile and return true
	 *  if the operation was successfully or return false if failed
	 * @param sourceFile
	 * @param destinationFile
	 * @return
	 */
	public static boolean copyFile (String sourceFile, String destinationFile){
		boolean result = false;
		FileOutputStream outputstream = null;
		FileInputStream inpustream = null;
		try{
		inpustream = new FileInputStream (new File (sourceFile));
		outputstream = FileWriterUtil.getOutputStreamForFile(destinationFile, true);
		byte buffer[] = new byte[512 * 1024];
		int nbRead;
		while ((nbRead = inpustream.read(buffer)) != -1){
			outputstream.write(buffer, 0, nbRead);
		}
		result = true;
		}catch (FileNotFoundException e) {
			result = false;
			LoggingUtil.getLoggerFor(FileWriterUtil.class).warning(LoggingUtil.getMessageAndStackTrace(e));
		} catch (IOException e) {
			result = false;
			LoggingUtil.getLoggerFor(FileWriterUtil.class).warning(LoggingUtil.getMessageAndStackTrace(e));
		}finally {
			if (outputstream!=null || inpustream!= null)
				try {
					outputstream.close();
					outputstream = null;
					inpustream.close();
					inpustream = null;
				} catch (Exception e1) {
					LoggingUtil.getLoggerFor(FileWriterUtil.class).warning(LoggingUtil.getMessageAndStackTrace(e1));
				}
		}
		return result;
	}
}

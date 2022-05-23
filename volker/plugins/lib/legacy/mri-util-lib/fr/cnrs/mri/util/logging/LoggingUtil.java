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
package fr.cnrs.mri.util.logging;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.logging.Logger;

/**
 * Get a logger for a given class or object and get an error message and the stack-trace
 * as a string.
 * 
 * @author baecker
 *
 */
public class LoggingUtil {
	/**
	 * Get a new logger for the class of the given object.
	 * @param anObject : get a logger for the class of anObject
	 * @return a new logger for the class of the given object.
	 */
	public static Logger getLoggerFor(Object anObject) {
		Logger logger = Logger.getLogger(anObject.getClass().getName());
		return logger;
	}
	
	/**
	 * Get a new logger for the given class.
	 * @param aClass : get a logger for aClass
	 * @return a new logger for the given class
	 */
	public static Logger getLoggerFor(Class<?> aClass) {
		Logger logger = Logger.getLogger(aClass.getName());
		return logger;
	}
	
	/**
	 * Append the message and the stack trace of the exception.
	 * @param exception 
	 * @return a string containing the message and the stack trace of exception
	 */
	public static String getMessageAndStackTrace(Throwable exception) {
		StringWriter stringWriter = new StringWriter();
		exception.printStackTrace(new PrintWriter(stringWriter));
		String trace = stringWriter.toString();
		String result = exception.getMessage() + "\n" + trace;
		return result;
	}
}

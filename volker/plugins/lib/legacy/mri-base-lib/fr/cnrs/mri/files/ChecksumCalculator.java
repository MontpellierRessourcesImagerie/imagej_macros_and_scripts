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
package fr.cnrs.mri.files;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.zip.CRC32;
import java.util.zip.Checksum;

import fr.cnrs.mri.util.logging.LoggingUtil;

/**
 * Calculate the checksum of a file. The file is read in chunk by chunk with a configurable chunk
 * size. Different algorithms can be used to calculate the checksum (for example crc32 or adler32).
 * 
 * @author Volker Baecker
 */
public class ChecksumCalculator {
	
	/**
	 * The file for which a checksum will be calculated. The file must exist and be readable.
	 */
	private File file;
	
	/**
	 * The method that will be used to calculate a checksum (for example crc32 or adler32).
	 */
	private Checksum checksumAlgorithm;

	/**
	 * The calculated checksum as a hex-string.
	 */
	private String checksum;
	
	/**
	 * The size of the data chunks, i.e. the size of the data that will be read into memory in
	 * the same time.
	 */
	private int chunkSize = 3 * 1024 * 1024;

	/**
	 * Create a new checksum calculator for the given file.
	 * 
	 * @param file:	the file for which a checksum will be calculated
	 */
	public ChecksumCalculator(File file) {
		this.file = file;
	}
	
	/**
	 * Set the algorithm that will be used to calculate the checksum. The method must
	 * implement the Checksum interface.
	 * 
	 * @param aChecksumAlgorithm:	the algorithm that will be used to calculate the checksum
	 */
	public void setAlgorithm(Checksum aChecksumAlgorithm) {
		checksumAlgorithm = aChecksumAlgorithm;
		checksum = null;
	}
	
	/**
	 * Answer the checksum for the file.
	 * @return the checksum as a hex-string.
	 */
	public String getChecksum() {
		if (checksum==null) calculateChecksum();
		return checksum;
	}
	
	/**
	 * Answer the chunk size, i.e. the size of data read in at once.
	 * @return the chunk size
	 */
	public int getChunkSize() {
		return this.chunkSize;
	}

	/**
	 * Set the chunk size, i.e. the size of data read in at once.
	 * 
	 * @param newSize: the new chunk size
	 */
	public void setChunkSize(int newSize) {
		this.chunkSize = newSize;
	}
	
	/**
	 * Answer the algorithm used to calculate the checksum.
	 * @return the algorithm that will be used to calculate the checksum
	 */
	private Checksum getChecksumAlgorithm() {
		if (this.checksumAlgorithm==null) this.checksumAlgorithm = new CRC32();
		return checksumAlgorithm;
	}

	/**
	 * Calculate the checksum of the file.
	 */
	private void calculateChecksum() {
		this.getChecksumAlgorithm().reset();
		byte[] chunk = new byte[chunkSize];
		InputStream is = null;	
		int read = 0;
		try {
			is = new FileInputStream(file);
			while ((read=is.read(chunk, 0, chunkSize))>=0) 
				checksumAlgorithm.update(chunk, 0, read);
		} catch (FileNotFoundException e) {LoggingUtil.getLoggerFor(FileInformation.class).warning(LoggingUtil.getMessageAndStackTrace(e));
		} catch (IOException e) {LoggingUtil.getLoggerFor(FileInformation.class).warning(LoggingUtil.getMessageAndStackTrace(e));}
		 finally {closeStream(is);}
		this.checksum = Long.toHexString(checksumAlgorithm.getValue());	
	}

	/**
	 * Close the given input stream if it is not null.
	 * @param is: the input stream that will be closed
	 */
	private void closeStream(InputStream is) {
		if (is!=null)
			try {is.close();} 
			catch (IOException e) {
				LoggingUtil.getLoggerFor(FileInformation.class).warning(LoggingUtil.getMessageAndStackTrace(e));
			}
	}
}

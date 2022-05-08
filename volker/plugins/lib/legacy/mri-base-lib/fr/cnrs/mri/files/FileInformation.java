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
import java.sql.Timestamp;
import java.util.zip.CRC32;

import fr.cnrs.mri.util.os.OperatingSystemProxy;

/**
 * The FileInformation gives access to information about a file, like the path of the file, its
 * creation and modification date and the crc32 checksum of the file.
 * 
 * @author Volker Baecker
 */
public class FileInformation {
	
	/**
	 * The file. It does not necessarily exist. 
	 */
	private File file;
	
	/**
	 * The crc32 checksum of the file as a hex-string.
	 */
	private String crc32;

	/**
	 * The size of data chunks for the calculation of the checksum
	 */
	private int chunkSize = 3 * 1024 * 1024;

	/**
	 * The last modification date of the file.
	 */
	private Timestamp lastModificationDate;

	/**
	 * The creation date of the file. This is only different from the modification date
	 * on windows systems.
	 */
	private Timestamp creationDate;

	/**
	 * The md5 checksum of the file as a hex-string 
	 */
	private String  md5;

	/**
	 * Create a new file information for the given path.
	 * 
	 * @param path	the path to a file.
	 */
	public FileInformation(String path) {
		file = new File(path);
	}

	/**
	 * Answer the crc32 checksum of the file as a hex-String.
	 * 
	 * @return the crc32 checksum of the file as a hex-String
	 */
	public String getCRC32Checksum() {
		if (crc32==null) calculateCRC32Checksum();
		return crc32;
	}

	/**
	 * Calculate the crc32 checksum of the file.
	 */
	private void calculateCRC32Checksum() {
		ChecksumCalculator calc = getCRC32ChecksumCalculator();
		crc32 = calc.getChecksum();
	}

	/**
	 * Answer a checksum-calculator on the file, that uses the crc32 algorithm and
	 * the given chunk size 
	 * 
	 * @return a checksum-calculator
	 */
	private ChecksumCalculator getCRC32ChecksumCalculator() {
		ChecksumCalculator calc = new ChecksumCalculator(file);
		calc.setAlgorithm(new CRC32());
		calc.setChunkSize(this.getChunkSize());
		return calc;
	}
	/**
	 * Answer the md5 checksum of the file as a hex-string
	 */
	public String getMD5Checksum() {
		if (md5==null) calculateMD5Checksum();
		return md5;
	}
	
	/**
	 * Calculate the md5 checksum of the file.
	 */
	private void calculateMD5Checksum() {
		ChecksumCalculator calc = getMD5ChecksumCalculator();
		md5 = calc.getChecksum();
	}
	
	/**
	 * Answer a checksum-calculator on the file, that uses the md5 algorithm and
	 * the given chunk size 
	 * 
	 * @return a checksum-calculator
	 */
	private ChecksumCalculator getMD5ChecksumCalculator() {
		ChecksumCalculator calc = new ChecksumCalculator(file);
		calc.setAlgorithm(new MD5());
		calc.setChunkSize(this.getChunkSize());
		return calc;
	}

	/**
	 * Answer the chunk size, i.e. the size of data loaded into memory at once.
	 * 
	 * @return the data chunk size.
	 */
	public int getChunkSize() {
		return this.chunkSize;
	}

	/**
	 * Set the chunk size to the given value. The chunk size is the size of data loaded
	 * at once into the memory for the calculation of the checksum.
	 * 
	 * @param aSize  the new chunk size
	 */
	public void setChunkSize(int aSize) {
		this.chunkSize = aSize;
	}
	
	/**
	 * Answer the creation date of the file as a timestamp.
	 * @return the creation date of the file
	 */
	public Timestamp getCreationDate() {
		if (this.creationDate==null) this.calculateCreationDate();
		return creationDate;
	}

	/**
	 * Calculate the creation date of the file. On windows this is done by running
	 * a dir /TC command. On all other systems the creation date is the last modification date. 
	 */
	private void calculateCreationDate() {
		OperatingSystemProxy osProxy = OperatingSystemProxy.current();
		creationDate = osProxy.getFileCreationDate(file);
	}

	/**
	 * Answer the last modification date of the file.
	 * 
	 * @return the last modification date
	 */
	public Timestamp getModificationDate() {
		if (this.lastModificationDate == null) this.calculateModificationDate();
		return this.lastModificationDate;
	}

	/**
	 * Calculate the last modification date of the file.
	 */
	private void calculateModificationDate() {
		this.lastModificationDate = new Timestamp(file.lastModified());
	}

	/**
	 * Answer the full path of the file.
	 * @return the full path of the file
	 */
	public String getFullPath() {
		return file.getAbsolutePath();
	}

	/**
	 * Test whether the file exists.
	 * @return true if the file exists and false otherwise.
	 */
	public boolean existsFile() {
		return file.exists();
	}

	/**
	 * Answer the size of the file in bytes.
	 * @return the size of the file
	 */
	public long getSize() {
		return file.length();
	}
}

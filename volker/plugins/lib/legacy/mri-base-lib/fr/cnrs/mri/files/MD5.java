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

import java.nio.ByteBuffer;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.zip.Checksum;

import fr.cnrs.mri.util.logging.LoggingUtil;

/**
 * This is a wrapper around the MessageDigest using the md5 algorithm that implements
 * the Checksum interface. This way the md5 can be used as a checksum.
 * 
 * @author Volker Baecker
 */
public class MD5 implements Checksum {

	/**
	 * The message digest that does all the work to calculate the hash.
	 */
	private MessageDigest digest;

	/**
	 * The constructor creates the digest and selects the md5 algorithm.
	 */
	public MD5() {
		try {
			digest = java.security.MessageDigest.getInstance("MD5");
			digest.reset();
		} catch (NoSuchAlgorithmException e) {
			LoggingUtil.getLoggerFor(MD5.class).severe(LoggingUtil.getMessageAndStackTrace(e));
		}	
	}
	
	/**
	 * Answer the md5 as a long and reset the digest.
	 */
	@Override
	public long getValue() {
		byte[] hash = digest.digest();
		ByteBuffer buffer = ByteBuffer.wrap(hash);
		long result = buffer.getLong();
		return result;
	}

	/**
	 * Reset the digest to calculate a new hash.
	 */
	@Override
	public void reset() {
		digest.reset();
	}

	/**
	 * Add a byte to the digest.
	 * 
	 * @param datum		the byte to add to the digest
	 */
	@Override
	public void update(int datum) {
		digest.update((byte)datum);
	}

	/**
	 * Add len bytes from data starting at off to the digest.
	 * 
	 * @param data		the data to be added to the digest
	 * @param off		the index of the first byte that will be added
	 * @param len		the number of bytes that will be added to the digest
	 */
	@Override
	public void update(byte[] data, int off, int len) {
		digest.update(data, off, len);
	}

}

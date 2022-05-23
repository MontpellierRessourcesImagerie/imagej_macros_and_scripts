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

/**
 * Utility methods for text processing.
 * 
 * @author baecker
 *
 */
public class TextUtil {
	
	/**
	 * This can be used to make a text independent of singular / plural. Replaces all occurences of %
	 * by number and if number is bigger than one, appends an s to all occurences of word. 
	 * Examples:
	 * 	getSingularOrPluralMessage(1, "% file copied", "file") 	->	"1 file copied"
	 *  getSingularOrPluralMessage(2, "% file copied", "file") 	->	"2 files copied"
	 *  
	 * @param number	
	 * @param message
	 * @param word
	 * @return
	 */
	public static String getSingularOrPluralMessage(int number, String message, String word) {
		String result = message.replaceAll("%", ""+ number);
		if (number==1) return result;
		return result.replaceAll(word, word+"s");
	}
	
	/**
	 * Answer a copy of the given name with all trailing digits removed.
	 * Examples:
	 * 	hello 	  -> hello
	 *  hello21   -> hello
	 *  r2d2	  -> r2d
	 *  
	 * @param 		the input name
	 * @return		a copy of the input name without the trailing digits 
	 */
	public static String copyWithoutTrailingDigits(String name) {
		String reversedName = new StringBuffer(name).reverse().toString();
		int index=0;
		for (int i=0; i<reversedName.length(); i++) {
			if (!Character.isDigit(reversedName.charAt(i))) {
					index = i;
					break;
			}
		}
		String result = new StringBuffer(reversedName.substring(index)).reverse().toString();
		return result;
	}

	/**
	 * Answer a copy of name without the given suffix.
	 * Examples:
	 * 	copyWithoutSuffix("New Folder (1)", " (1)") -> "New Folder" 
	 * 
	 * @param name
	 * @param suffix
	 * @return
	 */
	public static String copyWithoutSuffix(String name, String suffix) {
		int index = name.lastIndexOf(suffix);
		if (index==-1) return name;
		String result = name.substring(0, index);
		return result;
	}
	
/**
 * Add zeros at the beginning of the input string so that the total length becomes the 
 * given length.
 *
 * @param aString	the input string
 * @param length	the total length of the output string
 * @return			a string with the input string as suffix padded at the beginning with zeros
 */
	public static String zeroPaddedString(String aString, int length) {
			String result = aString;
			for (int i=0; i<length-aString.length(); i++) 
				result = "0" + result;
			return result;
	}
}

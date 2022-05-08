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

import java.util.List;
import java.util.Vector;

/**
 * Utility class for database accesses and
 * result handling.
 * 
 * @author Volker Baecker
 */
public class DatabaseUtil {
	
	/**
	 * When the query selects a single column containing strings, the result
	 * comes nevertheless as a vector for each row. Convert the query result 
	 * to an array of strings.
	 * 
	 * @param lines			the answer of the query 
	 * @return				the flattened answer of the query
	 */
	public static String[] flattenLines(List<Vector<String>> lines) {
		String[] result = new String[lines.size()];
		int counter = 0;
		for (Vector<String> line : lines)
			result[counter++] = line.firstElement();
		return result;
	}
	
	/**
	 * When the query selects a single column containing strings, the result
	 * comes nevertheless as a vector for each row. Convert the query result 
	 * to an array of strings.
	 * 
	 * @param lines			the answer of the query 
	 * @return				the flattened answer of the query
	 */
	public static Integer[] flattenLines(List<Vector<Integer>> lines) {
		Integer[] result = new Integer[lines.size()];
		int counter = 0;
		for (Vector<Integer> line : lines)
			result[counter++] = line.firstElement();
		return result;
	}
}

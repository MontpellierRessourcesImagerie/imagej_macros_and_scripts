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
package fr.cnrs.mri.mvc;

import java.util.Observable;

/**
 * Observable model with status and progress.
 * 
 * @author Volker Baecker
 */
public class OWSPModel extends Observable {

	public enum Aspect {DATA, STATUS, WORK_ON_DATA_STARTED, WORK_ON_DATA_FINISHED, 
						PROGRESS_MIN_CHANGED, PROGRESS_MAX_CHANGED, PROGRESS_CHANGED, 
						PROGRESS_MODE};
	
	private int progressMin;
	private int progressMax;
	private int progress;
	private boolean isIndeterminateProgressMode = true;
	private String status;

	/**
	 * Notify observers that an aspect has changed.
	 * 
	 * @param the aspect that has changed
	 */
	public void changed(Aspect aspect) {
		this.setChanged();
		this.notifyObservers(aspect);
		this.clearChanged();
	}

	/**
	 * Set the minimum of the progress.
	 * 
	 * @param  the minimum value of the progress
	 */
	public void setProgressMin(int value) {
		this.progressMin = value;
		this.changed(Aspect.PROGRESS_MIN_CHANGED);
	}

	/**
	 * Set the maximum value of the progress.
	 * 
	 * @param the maximum value of the progress
	 */
	public void setProgressMax(int value) {
		this.progressMax = value;
		this.changed(Aspect.PROGRESS_MAX_CHANGED);
	}

	/**
	 * Set the current progress.
	 * 
	 * @param value the current progress
	 */
	public void setProgress(int value) {
		this.progress = value;
		this.changed(Aspect.PROGRESS_CHANGED);
	}

	/**
	 * Answer the current progress.
	 * 
	 * @return the current progress
	 */
	public int getProgress() {
		return progress;
	}

	/**
	 * Answer the minimum value of the progress.
	 * 
	 * @return the minimum value of the progress
	 */
	public int getProgressMin() {
		return progressMin;
	}

	/**
	 * Answer the maximum value of the progress.
	 * 
	 * @return  the maximum value of the progress
	 */
	public int getProgressMax() {
		return progressMax;
	}

	/**
	 * Use the indeterminate progress bar, that moves from the
	 * start to the end of the bar and back while the process is in progress.
	 */
	public void useIndeterminateProgressMode() {
		this.isIndeterminateProgressMode = true;
		this.changed(Aspect.PROGRESS_MODE);
	}

	/**
	 * Use the determinate progress bar, that advances from the minimum progress
	 * to the maximum progress.
	 */
	public void useDeterminateProgressMode() {
		this.isIndeterminateProgressMode = false;
		this.changed(Aspect.PROGRESS_MODE);
	}

	/**
	 * Answer true if the progress mode is indeterminate.
	 * 
	 * @return true if the progress mode is indeterminate
	 */
	public boolean isIndeterminateProgressMode() {
		return this.isIndeterminateProgressMode;
	}

	/**
	 * Set the status message.
	 * 
	 * @param message	the status message
	 */
	public void setStatus(String message) {
		this.status = message;
		this.changed(Aspect.STATUS);
	}

	/**
	 * Answer the status message.
	 * @return the status message
	 */
	public String getStatus() {
		return status;
	}
}

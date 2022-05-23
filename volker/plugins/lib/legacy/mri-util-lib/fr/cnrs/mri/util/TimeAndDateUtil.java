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

import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public class TimeAndDateUtil {
	public static final int SECONDS_PER_DAY = 60 * 60 * 24;
	public static final int SECONDS_PER_HOUR = 60 * 60;
	public static final int SECONDS_PER_MINUTE = 60;
	
	public static String getDaysHoursMinutesSecondsStringFor(long intervalInSeconds) {
		if (intervalInSeconds<=0) return "0 sec";
		long days = intervalInSeconds / SECONDS_PER_DAY;
		long rest = intervalInSeconds % SECONDS_PER_DAY;
		long hours = rest / SECONDS_PER_HOUR;
		rest = rest % SECONDS_PER_HOUR;
		long minutes = rest / SECONDS_PER_MINUTE;
		long seconds = rest % SECONDS_PER_MINUTE;
		String result = seconds + " sec";
		if (days==0 && hours==0 && minutes==0) return result;
		result = minutes + " min " + result;
		if (days==0 && hours==0) return result;
		result = hours + " hr " + result;
		if (days==0) return result;
		result = days + " d " + result;
		return result;
	}
	
	public static String getDateHourMinuteStringFor(Date time) {
		DateFormat df = new SimpleDateFormat("dd.MM.yyyy kk:mm");
		return df.format(time);
	}

	
	public static String getDateFor (Date time){
		DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
		return df.format(time);
	}

	
	public static Timestamp tomorrowMidnight() {
		Calendar calendar = getCalendarTomorrowMidnight();
		Timestamp result = new Timestamp(calendar.getTime().getTime());
		return result;
	}

	public static Timestamp tomorrowAtHour(int hour) {
		Calendar calendar = getCalendarTomorrowMidnight();
		calendar.set(Calendar.HOUR_OF_DAY, hour);
		Timestamp result = new Timestamp(calendar.getTime().getTime());
		return result;
	}
	
	public static Calendar getCalendarTomorrowMidnight() {
		Calendar calendar = Calendar.getInstance();
		calendar.add(Calendar.DAY_OF_YEAR, 1);
		calendar.set(Calendar.HOUR_OF_DAY, 0);
		calendar.set(Calendar.MINUTE, 0);
		calendar.set(Calendar.SECOND, 0);
		calendar.set(Calendar.MILLISECOND, 0);
		return calendar;
	}

	public static Timestamp getDateNMonthAgo(int numberOfMonth) {
		Calendar calendar = Calendar.getInstance();
		calendar.add(Calendar.MONTH, -1 * numberOfMonth);
		Timestamp result = new Timestamp(calendar.getTime().getTime());
		return result;
	}

}

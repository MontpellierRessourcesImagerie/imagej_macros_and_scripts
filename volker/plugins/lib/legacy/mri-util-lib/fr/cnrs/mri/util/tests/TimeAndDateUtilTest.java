package fr.cnrs.mri.util.tests;
import static org.junit.Assert.assertNotNull;

import java.sql.Timestamp;
import java.util.Calendar;
import java.util.Date;
import junit.framework.Assert;
import org.junit.Test;
import fr.cnrs.mri.util.TimeAndDateUtil;

public class TimeAndDateUtilTest {

	@Test
	public void testConstructor() {
		assertNotNull(new TimeAndDateUtil());
	}
	
	@Test
	public void testGetDaysHoursMinutesSecondsStringFor() {
		String time = TimeAndDateUtil.getDaysHoursMinutesSecondsStringFor(-1);
		Assert.assertTrue(time.equals("0 sec"));
		time = TimeAndDateUtil.getDaysHoursMinutesSecondsStringFor(0);
		Assert.assertTrue(time.equals("0 sec"));
		time = TimeAndDateUtil.getDaysHoursMinutesSecondsStringFor(1);
		Assert.assertTrue(time.equals("1 sec"));
		time = TimeAndDateUtil.getDaysHoursMinutesSecondsStringFor(TimeAndDateUtil.SECONDS_PER_MINUTE-1);
		Assert.assertTrue(time.equals("59 sec"));
		time = TimeAndDateUtil.getDaysHoursMinutesSecondsStringFor(TimeAndDateUtil.SECONDS_PER_MINUTE);
		Assert.assertTrue(time.equals("1 min 0 sec"));
		time = TimeAndDateUtil.getDaysHoursMinutesSecondsStringFor(TimeAndDateUtil.SECONDS_PER_MINUTE+1);
		Assert.assertTrue(time.equals("1 min 1 sec"));
		time = TimeAndDateUtil.getDaysHoursMinutesSecondsStringFor(TimeAndDateUtil.SECONDS_PER_HOUR-1);
		Assert.assertTrue(time.equals("59 min 59 sec"));
		time = TimeAndDateUtil.getDaysHoursMinutesSecondsStringFor(TimeAndDateUtil.SECONDS_PER_HOUR);
		Assert.assertTrue(time.equals("1 hr 0 min 0 sec"));
		time = TimeAndDateUtil.getDaysHoursMinutesSecondsStringFor(TimeAndDateUtil.SECONDS_PER_HOUR+1);
		Assert.assertTrue(time.equals("1 hr 0 min 1 sec"));
		time = TimeAndDateUtil.getDaysHoursMinutesSecondsStringFor(TimeAndDateUtil.SECONDS_PER_DAY-1);
		Assert.assertTrue(time.equals("23 hr 59 min 59 sec"));
		time = TimeAndDateUtil.getDaysHoursMinutesSecondsStringFor(TimeAndDateUtil.SECONDS_PER_DAY);
		Assert.assertTrue(time.equals("1 d 0 hr 0 min 0 sec"));
		time = TimeAndDateUtil.getDaysHoursMinutesSecondsStringFor(TimeAndDateUtil.SECONDS_PER_DAY+1);
		Assert.assertTrue(time.equals("1 d 0 hr 0 min 1 sec"));
	}
	
	@Test
	public void testGetDateHourMinuteStringFor() {
		Timestamp time = Timestamp.valueOf("1970-08-29 12:45:30.123");
		String result = TimeAndDateUtil.getDateHourMinuteStringFor(time);
		Assert.assertTrue(result.equals("29.08.1970 12:45"));
	}
	
	@Test 
	public void testTomorrowMidnight() {
		Timestamp now = new Timestamp(new Date().getTime());
		Calendar calendar = Calendar.getInstance();
		calendar.add(Calendar.DAY_OF_MONTH, 1);
		Timestamp tomorrow = new Timestamp(calendar.getTime().getTime());
		Timestamp tomorrowMidnight = TimeAndDateUtil.tomorrowMidnight();
		Assert.assertTrue(now.before(tomorrowMidnight));
		Assert.assertTrue(tomorrowMidnight.before(tomorrow));
		Assert.assertTrue(tomorrowMidnight.toString().contains("00:00:00.0"));
	}
	
	@Test 
	public void testTomorrowAtHour() {
		Timestamp now = new Timestamp(new Date().getTime());
		Calendar calendar = Calendar.getInstance();
		calendar.add(Calendar.DAY_OF_MONTH, 1);
		calendar.add(Calendar.HOUR_OF_DAY, 3);
		Timestamp tomorrow = new Timestamp(calendar.getTime().getTime());
		Timestamp tomorrowAtHour = TimeAndDateUtil.tomorrowAtHour(1);
		Assert.assertTrue(now.before(tomorrowAtHour));
		Assert.assertTrue(tomorrowAtHour.before(tomorrow));
		Assert.assertTrue(tomorrowAtHour.toString().contains("01:00:00.0"));
	}
	
	@Test
	public void testGetDateNMonthAgo() {
		Timestamp date = new Timestamp(new Date().getTime());
		Timestamp futur = TimeAndDateUtil.getDateNMonthAgo(-3);
		Assert.assertTrue(date.before(futur));
		Timestamp ago = TimeAndDateUtil.getDateNMonthAgo(3);
		Timestamp longAgo = TimeAndDateUtil.getDateNMonthAgo(6);
		Assert.assertTrue(longAgo.before(ago));
	}
}

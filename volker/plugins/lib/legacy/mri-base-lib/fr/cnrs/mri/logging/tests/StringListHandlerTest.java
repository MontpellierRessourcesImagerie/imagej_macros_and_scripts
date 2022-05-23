package fr.cnrs.mri.logging.tests;

import static org.junit.Assert.*;
import java.util.Observable;
import java.util.Observer;
import java.util.logging.Level;
import java.util.logging.LogRecord;

import org.junit.Test;

import fr.cnrs.mri.logging.StringListHandler;

public class StringListHandlerTest implements Observer {

	private String log;
	private int count;

	@Test
	public void testFlush() {
		StringListHandler handler = new StringListHandler(2, this);
		assertEquals(0, count);
		handler.flush();
		assertEquals(1, count);
		handler.flush();
		assertEquals(2, count);
	}

	@Test
	public void testClose() {
		StringListHandler handler = new StringListHandler(2, this);
		assertEquals(0, count);
		handler.flush();
		assertEquals(1, count);
		handler.close();
		handler.flush();
		assertEquals(1, count);
	}

	@Test
	public void testPublishLogRecord() {
		StringListHandler handler = new StringListHandler(2, this);
		LogRecord record = new LogRecord(Level.INFO, "test");
		handler.publish(record);
		assertTrue(log.contains("INFO"));
		assertTrue(log.contains("test"));
		assertEquals(1, count);
	}

	@Override
	public void update(Observable sender, Object aspect) {
		log = (String)aspect;
		count++;
	}

}

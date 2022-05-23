package fr.cnrs.mri.util.logging.tests;

import static org.junit.Assert.*;
import java.util.logging.Logger;
import org.junit.Test;
import fr.cnrs.mri.util.logging.LoggingUtil;

public class LoggingUtilTest {

	@Test
	public void testConstructor() {
		assertNotNull(new LoggingUtil());
	}
	
	@Test
	public void testGetLoggerForObject() {
		Logger logger = LoggingUtil.getLoggerFor(this);
		assertTrue(logger.getName().equals(this.getClass().getName()));
	}

	@Test
	public void testGetLoggerForClassOfQ() {
		Logger logger = LoggingUtil.getLoggerFor(this.getClass());
		assertTrue(logger.getName().equals(this.getClass().getName()));
	}

	@Test
	public void testGetMessageAndStackTrace() {
		String message = "plumperquatsch";
		Exception exc = new Exception(message);
		String messageAndTrace = LoggingUtil.getMessageAndStackTrace(exc);
		assertTrue(messageAndTrace.contains(exc.getMessage()));
		assertTrue(messageAndTrace.contains("testGetMessageAndStackTrace"));
		try {
			Integer.parseInt("bla");
		} catch (NumberFormatException e) {
			String text = LoggingUtil.getMessageAndStackTrace(e);
			assertTrue(text.contains("NumberFormatException"));
			assertTrue(text.contains("parseInt"));
		}
	}
}

package fr.cnrs.mri.logging.tests;

import static org.junit.Assert.*;
import java.util.Observable;
import java.util.Observer;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.junit.Test;
import fr.cnrs.mri.logging.LogViewer;
import fr.cnrs.mri.util.logging.LoggingUtil;

public class LogViewerTest implements Observer {

	private String log;

	@Test
	public void testLogViewer() {
		LogViewer viewer = new LogViewer(this.getClass().getName(), 100);
		viewer.addObserver(this);
		Logger logger = LoggingUtil.getLoggerFor(this);
		logger.warning("test 01");
		assertTrue(log.contains("test 01"));
		assertTrue(log.contains("WARNING"));
		logger.setLevel(Level.WARNING);
		logger.info("test 02");
		assertFalse(log.contains("test 02"));
		logger.warning("test 02");
		assertTrue(log.contains("test 02"));
	}

	@Test
	public void testShow() {
		LogViewer viewer = new LogViewer(this.getClass().getName(), 100);
		viewer.show();
		assertTrue(viewer.getView().isShowing());
		viewer.getView().setVisible(false);
		viewer.close();
		assertFalse(viewer.getView().isShowing());
	}
	@Override
	public void update(Observable o, Object arg) {
		log = (String) arg;
	}
}

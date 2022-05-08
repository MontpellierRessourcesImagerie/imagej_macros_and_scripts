package fr.cnrs.mri.logging.tests;

import static org.junit.Assert.*;

import java.util.Observable;
import java.util.Observer;
import org.junit.Test;
import fr.cnrs.mri.logging.Log;

public class LogTest implements Observer {

	private String text;
	
	@Test
	public void testLog() {
		Log log = new Log(2);
		log.addRecord("line 1");
		log.addRecord("line 2");
		log.addRecord("line 3");
		assertEquals("line 2\nline 3\n", log.getText());
	}

	@Test
	public void testAddRecord() {
		Log log = new Log(1024);
		log.addObserver(this);
		log.addRecord("test 01");
		assertEquals("test 01\n", text);
		assertEquals("test 01\n", log.getText());
		log.addRecord("test 02");
		assertEquals("test 01\ntest 02\n", text);
		assertEquals("test 01\ntest 02\n", log.getText());
	}

	@Test
	public void testGetText() {
		Log log = new Log(1024);
		assertEquals("", log.getText());
		log.addRecord("test");
		assertEquals("test\n", log.getText());
	}

	@Override
	public void update(Observable sender, Object aspect) {
		text = (String) aspect;
	}

}

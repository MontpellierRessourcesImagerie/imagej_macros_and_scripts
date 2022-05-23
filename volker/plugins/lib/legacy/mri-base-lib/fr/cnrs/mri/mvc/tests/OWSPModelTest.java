package fr.cnrs.mri.mvc.tests;

import static org.junit.Assert.*;

import java.util.Observable;
import java.util.Observer;

import org.junit.Before;
import org.junit.Test;

import fr.cnrs.mri.mvc.OWSPModel;
import fr.cnrs.mri.mvc.OWSPModel.Aspect;

public class OWSPModelTest implements Observer {

	private OWSPModel model;
	private Aspect lastUpdatedAspect;

	@Before
	public void setUp() throws Exception {
		model = new OWSPModel();
		model.addObserver(this);
	}

	@Test
	public void testChanged() {
		for (Aspect aspect : Aspect.values()) {
			model.changed(aspect);
			assertEquals(aspect, lastUpdatedAspect);
		}
	}

	@Test
	public void testSetProgressMin() {
		model.setProgressMin(-50);
		assertEquals(Aspect.PROGRESS_MIN_CHANGED, lastUpdatedAspect);
		assertEquals(-50, model.getProgressMin());
	}

	@Test
	public void testSetProgressMax() {
		model.setProgressMax(200);
		assertEquals(Aspect.PROGRESS_MAX_CHANGED, lastUpdatedAspect);
		assertEquals(200, model.getProgressMax());
	}

	@Test
	public void testSetProgress() {
		model.setProgress(20);
		assertEquals(Aspect.PROGRESS_CHANGED, lastUpdatedAspect);
		assertEquals(20, model.getProgress());
	}

	@Test
	public void testGetProgress() {
		assertEquals(0, model.getProgress());
	}

	@Test
	public void testGetProgressMin() {
		assertEquals(0, model.getProgressMin());
	}

	@Test
	public void testGetProgressMax() {
		assertEquals(0, model.getProgressMax());
	}

	@Test
	public void testUseIndeterminateProgressMode() {
		model.useIndeterminateProgressMode();
		assertEquals(Aspect.PROGRESS_MODE, lastUpdatedAspect);
		assertTrue(model.isIndeterminateProgressMode());
	}

	@Test
	public void testUseDeterminateProgressMode() {
		model.useDeterminateProgressMode();
		assertEquals(Aspect.PROGRESS_MODE, lastUpdatedAspect);
		assertFalse(model.isIndeterminateProgressMode());
	}

	@Test
	public void testIsIndeterminateProgressMode() {
		assertTrue(model.isIndeterminateProgressMode());
	}

	@Test
	public void testSetStatus() {
		model.setStatus("finished");
		assertEquals(Aspect.STATUS, lastUpdatedAspect);
		assertEquals("finished", model.getStatus());
	}

	@Test
	public void testGetStatus() {
		assertNull(model.getStatus());
	}

	@Override
	public void update(Observable sender, Object aspect) {
		lastUpdatedAspect = (Aspect)aspect;
	}

}

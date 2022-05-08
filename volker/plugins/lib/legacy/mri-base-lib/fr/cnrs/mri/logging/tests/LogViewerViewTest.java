package fr.cnrs.mri.logging.tests;

import org.junit.Test;
import fr.cnrs.mri.logging.LogViewer;
import fr.cnrs.mri.logging.LogViewerView;

public class LogViewerViewTest {

	@Test
	public void testEvents() {
		LogViewerView viewer = new LogViewerView();
		viewer.windowActivated(null);
		viewer.windowDeactivated(null);
		viewer.windowDeiconified(null);
		viewer.windowIconified(null);
		viewer.windowOpened(null);
		viewer.windowClosed(null);
		viewer.windowClosing(null);
	}

	@Test
	public void testUpdateObservableObject() {
		LogViewer logger = new LogViewer(this.getClass().getName(), 100);
		LogViewerView viewer = new LogViewerView(logger);
		viewer.update(logger, "changed");
	}

}

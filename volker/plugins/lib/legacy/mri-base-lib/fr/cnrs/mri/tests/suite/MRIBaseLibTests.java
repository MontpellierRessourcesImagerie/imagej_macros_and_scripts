package fr.cnrs.mri.tests.suite;

import fr.cnrs.mri.files.tests.ChecksumCalculatorTest;
import fr.cnrs.mri.files.tests.ConfigurableFileFilterTest;
import fr.cnrs.mri.files.tests.FileInformationTest;
import fr.cnrs.mri.files.tests.MD5Test;
import fr.cnrs.mri.files.tests.RemoteFileTest;
import fr.cnrs.mri.logging.tests.LogTest;
import fr.cnrs.mri.logging.tests.LogViewerTest;
import fr.cnrs.mri.logging.tests.LogViewerViewTest;
import fr.cnrs.mri.logging.tests.StringListHandlerTest;
import fr.cnrs.mri.mvc.tests.OWSPModelTest;
import fr.cnrs.mri.server.tests.ServerLinkTest;
import fr.cnrs.mri.server.tests.ServerTest;
import junit.framework.JUnit4TestAdapter;
import junit.framework.Test;
import junit.framework.TestSuite;

public class MRIBaseLibTests {

	public static Test suite() {
		TestSuite suite = new TestSuite("Test for mri-base-lib");
		//$JUnit-BEGIN$
		// files
		suite.addTest(new JUnit4TestAdapter(ChecksumCalculatorTest.class));
		suite.addTest(new JUnit4TestAdapter(ConfigurableFileFilterTest.class));
		suite.addTest(new JUnit4TestAdapter(FileInformationTest.class));
		suite.addTest(new JUnit4TestAdapter(MD5Test.class));
		suite.addTest(new JUnit4TestAdapter(RemoteFileTest.class));
		// logging
		suite.addTest(new JUnit4TestAdapter(LogTest.class));
		suite.addTest(new JUnit4TestAdapter(LogViewerTest.class));
		suite.addTest(new JUnit4TestAdapter(LogViewerViewTest.class));
		suite.addTest(new JUnit4TestAdapter(StringListHandlerTest.class));
		// mvc
		suite.addTest(new JUnit4TestAdapter(OWSPModelTest.class));
		// server
		suite.addTest(new JUnit4TestAdapter(ServerLinkTest.class));
		suite.addTest(new JUnit4TestAdapter(ServerTest.class));
		//$JUnit-END$
		return suite;
	}

}

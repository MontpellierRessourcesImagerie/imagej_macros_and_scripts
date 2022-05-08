package fr.cnrs.mri.util.tests.suite;

import fr.cnrs.mri.util.config.tests.AbstractConfigurationTest;
import fr.cnrs.mri.util.logging.tests.LoggingUtilTest;
import fr.cnrs.mri.util.os.tests.MacProxyTest;
import fr.cnrs.mri.util.os.tests.OperatingSystemProxyTest;
import fr.cnrs.mri.util.os.tests.WindowProxyTest;
import fr.cnrs.mri.util.tests.AccessibilityProxyTest;
import fr.cnrs.mri.util.tests.DatabaseUtilTest;
import fr.cnrs.mri.util.tests.EncryptionUtilTest;
import fr.cnrs.mri.util.tests.FileUtilTest;
import fr.cnrs.mri.util.tests.FileWriterUtilTest;
import fr.cnrs.mri.util.tests.TextUtilTest;
import fr.cnrs.mri.util.tests.TimeAndDateUtilTest;
import junit.framework.JUnit4TestAdapter;
import junit.framework.Test;
import junit.framework.TestSuite;

public class MRIUtilLibTests {

	public static Test suite() {
		TestSuite suite = new TestSuite("Test for mri-util-lib");
		//$JUnit-BEGIN$

		suite.addTest(new JUnit4TestAdapter(AbstractConfigurationTest.class));
		// logging
		suite.addTest(new JUnit4TestAdapter(LoggingUtilTest.class));
		// os
		suite.addTest(new JUnit4TestAdapter(MacProxyTest.class));
		suite.addTest(new JUnit4TestAdapter(OperatingSystemProxyTest.class));
		suite.addTest(new JUnit4TestAdapter(WindowProxyTest.class));
		// util
		suite.addTest(new JUnit4TestAdapter(AccessibilityProxyTest.class));
		suite.addTest(new JUnit4TestAdapter(DatabaseUtilTest.class));
		suite.addTest(new JUnit4TestAdapter(EncryptionUtilTest.class));
		suite.addTest(new JUnit4TestAdapter(FileUtilTest.class));
		suite.addTest(new JUnit4TestAdapter(FileWriterUtilTest.class));
		suite.addTest(new JUnit4TestAdapter(TextUtilTest.class));
		suite.addTest(new JUnit4TestAdapter(TimeAndDateUtilTest.class));
		//$JUnit-END$
		return suite;
	}

}

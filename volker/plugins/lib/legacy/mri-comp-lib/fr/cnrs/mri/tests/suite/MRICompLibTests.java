package fr.cnrs.mri.tests.suite;

import fr.cnrs.mri.dialog.tests.ModalDialogKillerTest;
import fr.cnrs.mri.fileList.tests.FolderOpenerProxyTest;
import fr.cnrs.mri.fileList.tests.ListEditorTest;
import fr.cnrs.mri.fileList.tests.MRIFolderOpenerTest;
import junit.framework.JUnit4TestAdapter;
import junit.framework.Test;
import junit.framework.TestSuite;

public class MRICompLibTests {

	public static Test suite() {
		TestSuite suite = new TestSuite("Test for mri-comp-lib");
		//$JUnit-BEGIN$
		// dialog
		suite.addTest(new JUnit4TestAdapter(ModalDialogKillerTest.class));
		// fileList
		suite.addTest(new JUnit4TestAdapter(FolderOpenerProxyTest.class));
		suite.addTest(new JUnit4TestAdapter(ListEditorTest.class));
		suite.addTest(new JUnit4TestAdapter(MRIFolderOpenerTest.class));
		//$JUnit-END$
		return suite;
	}
}
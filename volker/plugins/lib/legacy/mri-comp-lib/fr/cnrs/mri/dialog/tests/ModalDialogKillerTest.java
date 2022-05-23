package fr.cnrs.mri.dialog.tests;

import static org.junit.Assert.*;

import ij.gui.GenericDialog;
import ij.gui.WaitForUserDialog;
import java.awt.Dialog;
import java.awt.Frame;
import java.awt.KeyboardFocusManager;
import java.awt.Window;
import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import javax.swing.JOptionPane;
import org.junit.Test;
import fr.cnrs.mri.dialog.ModalDialogKiller;

public class ModalDialogKillerTest {

	@Test
	public void testModalDialogKiller() {
		ModalDialogKiller mdk = new ModalDialogKiller();
		assertFalse(mdk.isRunning());
	}

	@Test
	public void testStart() {
		ModalDialogKiller mdk = new ModalDialogKiller();
		assertFalse(mdk.isRunning());
		mdk.start();
		
		JOptionPane.showConfirmDialog(null, "test01");
		new WaitForUserDialog("test02").show();
		GenericDialog gd = new GenericDialog("test03");
		gd.showDialog();
		
		assertTrue(mdk.isRunning());
		KeyboardFocusManager keyboardFocusManager = KeyboardFocusManager.getCurrentKeyboardFocusManager();
		PropertyChangeListener[] listeners = keyboardFocusManager.getPropertyChangeListeners("activeWindow");
		assertTrue(listeners.length==1);
		assertTrue(listeners[0]==mdk);
		mdk.stop();
	}

	@Test
	public void testStop() {
		ModalDialogKiller mdk = new ModalDialogKiller();
		mdk.start();
		assertTrue(mdk.isRunning());
		mdk.stop();
		assertFalse(mdk.isRunning());
		KeyboardFocusManager keyboardFocusManager = KeyboardFocusManager.getCurrentKeyboardFocusManager();
		PropertyChangeListener[] listeners = keyboardFocusManager.getPropertyChangeListeners("activeWindow");
		assertTrue(listeners.length==0);
	}

	@Test
	public void testPropertyChange() {
		ModalDialogKiller mdk = new ModalDialogKiller();
		Window oldWin = new Window(null);
		Dialog newWin = new Dialog((Frame)null);
		newWin.setModal(true);
		PropertyChangeEvent event1 = new PropertyChangeEvent(this, "plumperquatsch", oldWin, newWin);
		PropertyChangeEvent event2 = new PropertyChangeEvent(this, "activeWindow", oldWin, newWin);
		mdk.propertyChange(event1);
		assertTrue(newWin.isModal());
		mdk.propertyChange(event2);
		assertFalse(newWin.isModal());
	}

	@Test
	public void testGetInstance() {
		assertNotNull(ModalDialogKiller.getInstance());
		assertEquals(ModalDialogKiller.getInstance(), ModalDialogKiller.getInstance());
	}

	@Test
	public void testIsRunning() {
		ModalDialogKiller mdk = new ModalDialogKiller();
		assertFalse(mdk.isRunning());
		mdk.start();
		assertTrue(mdk.isRunning());
		mdk.stop();
		assertFalse(mdk.isRunning());
	}

}

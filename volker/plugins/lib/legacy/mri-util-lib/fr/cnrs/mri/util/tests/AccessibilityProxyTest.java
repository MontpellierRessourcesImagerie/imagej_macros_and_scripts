package fr.cnrs.mri.util.tests;

import static org.junit.Assert.*;
import junit.framework.Assert;
import org.junit.Test;
import fr.cnrs.mri.util.AccessibilityProxy;
import fr.cnrs.mri.util.testData.AccessibilityProxyTestSuper;
import fr.cnrs.mri.util.testData.PrivateObject;
import fr.cnrs.mri.util.testData.SubSubclass;
import fr.cnrs.mri.util.testData.Subclass;
import fr.cnrs.mri.util.testData.WantToAccess;

public class AccessibilityProxyTest extends AccessibilityProxyTestSuper{

	@Test
	public void testCall() {
		AccessibilityProxy proxy = new AccessibilityProxy();
		String answer1 = (String)proxy.call(this, "hello1", new Object[0]);
		Assert.assertTrue(answer1.equals(this.hello1()));
		String answer2 = (String)proxy.call(this, "hello2", new Object[0]);
		Assert.assertTrue(answer2.equals("hello2"));
		Boolean answer3 = (Boolean)proxy.call(this, "answerTrue", new Object[0]);
		Assert.assertTrue(answer3);
		assertNull(proxy.call(this, "doSomething", new Object[0]));
	}
	
	@Test
	public void testExecuteSuperclassMethod() {
		Subclass wta = new Subclass();
		// call private getter
		Object[] params = {};
		String answer = (String) new AccessibilityProxy().executeSuperclassMethod(String.class, wta, "getPrivateName", params);
		Assert.assertEquals(WantToAccess.privateName, answer);
		// call private setter
		Object[] params2 = {"name"};
		answer = (String) new AccessibilityProxy().executeSuperclassMethod(null, wta, "setPrivateName", params2);
		Assert.assertNull(answer);
		answer = (String) new AccessibilityProxy().executeSuperclassMethod(String.class, wta, "getPrivateName", params);
		Assert.assertEquals("name",answer);
		// call not existing method
		answer = (String) new AccessibilityProxy().executeSuperclassMethod(String.class, wta, "doesNotExist", params);
		Assert.assertNull(answer);
		// if method exists in receiver.class it is called there
		answer = (String) new AccessibilityProxy().executeSuperclassMethod(null, this, "doSomething", params);
	}

	@Test
	public void testNewObject() {
		PrivateObject po = (PrivateObject) new AccessibilityProxy().newObject(PrivateObject.class);
		assertTrue(po.getName().length()>0);
	}

	@Test
	public void testGetSuperclassField() {
		Subclass wta = new Subclass();
		String answer = (String) new AccessibilityProxy().getSuperclassField(wta, "name");
		assertEquals(WantToAccess.privateName, answer);
	}

	@Test
	public void testSetSuperclassField() {
		Subclass wta = new Subclass();
		AccessibilityProxy AccessibilityProxy = new AccessibilityProxy();
		AccessibilityProxy.setSuperclassField(wta, "name", "changed");
		String answer = (String) new AccessibilityProxy().getSuperclassField(wta, "name");
		assertEquals("changed", answer);
	}

	@Test
	public void testGetField() {
		SubSubclass wta1 = new SubSubclass();
		Subclass wta2 = new Subclass();
		WantToAccess wta3 = new WantToAccess();
		String answer1 = (String) AccessibilityProxy.getField(wta1, "name");
		String answer2 = (String) AccessibilityProxy.getField(wta2, "name");
		String answer3 = (String) AccessibilityProxy.getField(wta3, "name");
		assertTrue(answer1.equals(answer2));
		assertTrue(answer2.equals(answer3));
		assertEquals(WantToAccess.privateName, answer1);
	}

	@Test
	public void testSetField() {
		SubSubclass wta1 = new SubSubclass();
		Subclass wta2 = new Subclass();
		WantToAccess wta3 = new WantToAccess();
		AccessibilityProxy.setField(wta1, "name", "changed");
		AccessibilityProxy.setField(wta2, "name", "changed");
		AccessibilityProxy.setField(wta3, "name", "changed");
		String answer1 = (String) AccessibilityProxy.getField(wta1, "name");
		String answer2 = (String) AccessibilityProxy.getField(wta2, "name");
		String answer3 = (String) AccessibilityProxy.getField(wta3, "name");
		assertTrue(answer1.equals(answer2));
		assertTrue(answer2.equals(answer3));
		assertEquals("changed", answer1);
	}

	@Test
	public void testExecute() {
		SubSubclass wta1 = new SubSubclass();
		Subclass wta2 = new Subclass();
		WantToAccess wta3 = new WantToAccess();
		Object[] params = {};
		String answer1 = (String) AccessibilityProxy.execute(String.class, wta1, "getPrivateName", params);
		String answer2 = (String) AccessibilityProxy.execute(String.class, wta2, "getPrivateName", params);
		String answer3 = (String) AccessibilityProxy.execute(String.class, wta3, "getPrivateName", params);
		assertTrue(answer1.equals(answer2));
		assertTrue(answer2.equals(answer3));
		assertEquals(WantToAccess.privateName, answer1);
	}
	
	@Test
	public void testCreateObject() {
		AccessibilityProxyTest test = (AccessibilityProxyTest) AccessibilityProxy.createObject(this.getClass().getName());
		assertEquals(this.hello1(), test.hello1());
	}
	private String hello1() {
		return "hello1";
	}

	public void doSomething() {
		hello1();
	}
	
	public boolean answerTrue() {
		return true;
	}
}

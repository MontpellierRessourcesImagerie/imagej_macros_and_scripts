package fr.cnrs.mri.util.tests;

import static org.junit.Assert.*;
import org.junit.Test;
import fr.cnrs.mri.util.EncryptionUtil;

public class EncryptionUtilTest {

	@Test
	public void testConstructor() {
		assertNotNull(new EncryptionUtil());
	}
	
	@Test
	public void testEncodeMD5() {
		assertEquals(EncryptionUtil.encodeMD5("test"), EncryptionUtil.encodeMD5("test"));
		assertFalse(EncryptionUtil.encodeMD5("test1").equals( EncryptionUtil.encodeMD5("test2")));
	}

}

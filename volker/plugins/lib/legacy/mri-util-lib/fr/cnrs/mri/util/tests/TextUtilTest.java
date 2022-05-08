package fr.cnrs.mri.util.tests;
import static org.junit.Assert.assertNotNull;
import junit.framework.Assert;
import org.junit.Test;
import fr.cnrs.mri.util.TextUtil;

public class TextUtilTest {

	@Test
	public void testConstructor() {
		assertNotNull(new TextUtil());
	}
	
	@Test
	public void testGetSingularOrPluralMessage() {
		Assert.assertTrue(TextUtil.getSingularOrPluralMessage(0, "% file copied", "file").equals("0 files copied"));
		Assert.assertTrue(TextUtil.getSingularOrPluralMessage(1, "% file copied", "file").equals("1 file copied"));
		Assert.assertTrue(TextUtil.getSingularOrPluralMessage(2, "% file copied", "file").equals("2 files copied"));
	}
	
	@Test
	public void testCopyWithoutTrailingDigits() {
		Assert.assertEquals("Hello", TextUtil.copyWithoutTrailingDigits("Hello"));
		Assert.assertEquals("Hello", TextUtil.copyWithoutTrailingDigits("Hello21"));
		Assert.assertEquals("r2d", TextUtil.copyWithoutTrailingDigits("r2d2"));
		Assert.assertEquals("New Folder", TextUtil.copyWithoutTrailingDigits("New Folder123"));
	}
	
	@Test
	public void testCopyWithoutSuffix() {
		Assert.assertEquals("New Folder", TextUtil.copyWithoutSuffix("New Folder", " (1)"));
		Assert.assertEquals("New Folder", TextUtil.copyWithoutSuffix("New Folder (1)", " (1)"));
	}
	
	@Test
	public void testZeroPaddedString() {
		Assert.assertEquals("3", TextUtil.zeroPaddedString("3", 1));
		Assert.assertEquals("03", TextUtil.zeroPaddedString("3", 2));
		Assert.assertEquals("003", TextUtil.zeroPaddedString("3", 3));
	}
}

package fr.cnrs.mri.util.tests;

import static org.junit.Assert.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Vector;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import fr.cnrs.mri.util.DatabaseUtil;

public class DatabaseUtilTest {

	@Before
	public void setUp() throws Exception {
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void testConstructor() {
		assertNotNull(new DatabaseUtil());
	}
	
	@Test
	public void testFlattenLines() {
		List<Vector<String>> lines = new ArrayList<Vector<String>>();
		Vector<String> line1 = new Vector<String>();
		line1.add("a");
		Vector<String> line2 = new Vector<String>();
		line2.add("b");
		lines.add(line1);
		lines.add(line2);
		String[] result = DatabaseUtil.flattenLines(lines);
		assertEquals("a", result[0]);
		assertEquals("b", result[1]);
	}
	
	@Test
	public void testFlattenLinesInteger() {
		ArrayList<Vector<Integer>> lines = new ArrayList<Vector<Integer>>();
		Vector<Integer> line1 = new Vector<Integer>();
		line1.add(6);
		Vector<Integer> line2 = new Vector<Integer>();
		line2.add(3);
		lines.add(line1);
		lines.add(line2);
		Integer[] result = DatabaseUtil.flattenLines(lines);
		assertEquals((Integer)6, result[0]);
		assertEquals((Integer)3, result[1]);
	}
}

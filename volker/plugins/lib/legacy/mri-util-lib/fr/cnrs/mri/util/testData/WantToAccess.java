package fr.cnrs.mri.util.testData;

public class WantToAccess {
	
	/*
	 * This one is public, so that tests can know the result
	 */
	public static String privateName = "geheim";

	private String name = privateName;
	
	@SuppressWarnings("unused")
	private String getPrivateName() {
		return name;
	}
	
	@SuppressWarnings("unused")
	private void setPrivateName(String name) {
		this.name = name;
	}
}

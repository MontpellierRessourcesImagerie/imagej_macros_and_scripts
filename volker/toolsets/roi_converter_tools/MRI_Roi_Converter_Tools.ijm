/**
  * MRI Roi Converter Tools
  * 
  * The Roi Converter Tools allow to transform the upper part of an area roi into a line-roi, 
  * to create a point-roi of the extrema of a line roi and to create vertical lines across the 
  * area of a mask from each point of a point roi.
  *
  * written 2011 by Volker Baecker (INSERM) at Montpellier RIO Imaging (www.mri.cnrs.fr)
*/

var helpURL = "http://dev.mri.cnrs.fr/wiki/imagej-macros/Roi_Converter_Tools"

var radius = 5;

macro "Unused Tool - C037" { }

macro "MRI Roi Converter Tools Action Tool -C000D0cD0dD1cD1dD53D54D63D64D97D98Da7Da8Dc5Dc6Dd5Dd6De9DeaDf9DfaCfffD00D01D02D03D04D05D06D07D08D09D0aD0bD0fD10D11D12D13D14D15D16D17D18D19D1eD1fD20D21D22D23D24D25D26D27D28D2eD2fD30D31D32D33D34D35D36D3aD3bD3dD3eD3fD40D41D42D43D44D49D4aD4dD4eD4fD50D51D52D57D58D59D5aD5dD5eD5fD60D61D62D65D66D67D68D69D6aD6dD6eD6fD70D71D72D73D76D77D78D79D7aD7cD7dD7eD7fD80D81D82D83D84D87D88D89D8cD8dD8eD8fD90D91D92D93D94D95D99D9cD9dD9eD9fDa0Da1Da2Da3Da4Da5Da9DacDadDaeDafDb0Db1Db2Db3Db4Db5Db8Db9DbbDbcDbdDbeDbfDc0Dc1Dc2Dc3Dc4Dc7Dc8DcbDccDcdDceDcfDd0Dd1Dd2Dd3Dd4Dd8DdbDdcDddDdeDdfDe0De1De2De3De4De5DebDecDedDeeDefDf0Df1Df2Df3Df4Df5Df6Df7DfbDfcDfdDfeDffCfddD5cD9bCf00D1aD1bD29D2aD2cD2dD38D39D3cD46D47D48D4bD4cD55D56D5bD6bD75D7bD85D86D8aD8bD96D9aDaaDb6Db7DbaDcaDdaDe7De8Df8CfffD2bD45Dc9Dd7De6CfeeD0eDa6CfeeD37D6cD74DabCfeeDd9" {
    run('URL...', 'url='+helpURL);
}

macro "Convert Roi To 1D Action Tool - C037T1d131T9d13DC555" {
    run("MRI Roi Converter");
}

macro "Convert Roi To Extrema Action Tool - C037T1d13XT9d13tC555" {
    run("MRI Extrema", radius);
}

macro 'Convert Roi To Extrema Action Tool Options' {
    Dialog.create("Convert Roi To 1D Options");
    Dialog.addNumber("radius", radius);
    Dialog.show();
    radius = Dialog.getNumber();
}

macro "Create Vertical Lines Action Tool - C037T1d13vT9d13lC555" {
	call("roi.RoiConverter.addVerticalLinesToRoiManager");
}

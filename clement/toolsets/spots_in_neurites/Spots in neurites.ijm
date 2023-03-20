
var dCmds = newMenu(
    "Spots in neurons Menu Tool",
    newArray(
        "About",
        "Tips", 
        "Thanks",
        "-",
        "Settings",
        "Clear Settings"
    )
);


macro "Spots in neurons Menu Tool - CaaaD51C777D61C333D71C444D81C999D91CeeeDa1CcccD42C000L5292C333Da2CcccD53CeeeD83C777D93C000Da3CcccDb3D94C000Da4CcccDb4C999D95C555Da5CaaaD86C555D96CeeeDa6C999D77C555D87CdddD68C000D78CdddD88CbbbD69C000D79CbbbD6cC444D7cCdddD8cC666D6dC000D7dC999D8dCbbbD6eC444D7eCdddD8e" {
    cmd = getArgument();
    if (cmd=="About")
        run("SIN About");
    else if (cmd=="Tips")
        run("SIN Tips");
    else if (cmd=="Settings")
        run("SIN Settings");
    else if (cmd=="Clear Settings")
        run("SIN Clear Settings");
    else if (cmd=="Thanks")
        run("SIN Thanks");
}


macro "Stack Focus MIP Action Tool - C000L1282D13D83D14L44b4D15D45Db5D16D46L76e6D17D47D77De7D18D48D78De8L1949D79De9D4aD7aDeaL4b7bDebD7cDecL7ded" {
    run("SIN Focus Detection MIP");
}


macro "Check MIP Action Tool - C000L11e1D12De2D13De3D14La4b4De4D15L95a5De5D16D96De6D17D87De7D18L3848D88De8D19L4959L7989De9D1aL5a7aDeaD1bL6b7bDebD1cD7cDecD1dDedL1eee" {
    run("SIN Check MIP");
}


macro "Segmentation Action Tool - C000Dd1L1232Dd2D33Lb3d3D34Db4L3565Db5L6676Db6D77Db7L7888CdddD98C888Da8C777Db8C555Dc8CdddDd8D89C777L99d9CdddDe9C000L0a2aC888D8aC777L9adaC888DeaC000L2b3bL6b7bC777L8bdbCcccDebC000L3c6cC888D8cC777L9cdcC888DecCdddD8dC777L9dddCdddDedC222D9eC555DaeC777DbeC888DceCdddDdeC000L8f9f" {
    run("SIN Segmentation");
}


macro "Check Segmentation Action Tool - C0f0La0b0Da1C000Dd1L1232C0f0L6272C4f4D92C0f0Da2C000Dd2D33C0f0L7383C3f3D93C000Lb3d3D34C0f0L8494C000Db4L3565Db5L6676Db6D77Db7L7888Lb8c8L0a2aL2b3bL6b8bL3c6cL9eaeL8f9f" {
    run("SIN Check Segmentation");
}


macro "Spots In Neurons Action Tool - C000Dd1L1232Dd2D33Lb3c3Cf00Dd3D34C000Db4L3555Cf00D65C000Db5L6676Db6D77Db7L7888L0a2aCf00D2bC000D3bL6b7bL3c5cCf00D6cC000D9eL8f9f" {
    run("SIN Spot Neurons");
}


macro "Check Spots Action Tool - C000Dd1L1232Dd2D33Lb3c3Cf00Dd3D34C000Db4L3555Cf00D65C000Db5L6676Db6D77Db7L7888C0f0Df8Le9f9C000L0a2aC0f0DbaDeaCf00D2bC000D3bL6b7bC0f0LbbebC000L3c5cCf00D6cC0f0LccdcDddC000D9eL8f9f" {
    run("SIN Check Spots");
}

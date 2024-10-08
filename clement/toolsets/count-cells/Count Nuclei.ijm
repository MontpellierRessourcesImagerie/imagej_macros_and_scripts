
macro "Count Nuclei Action Tool - Cd22L2141L1252L1353C8bdDa3C2adLb3c3C8bdDd3Cd22L1454C8bdD94C2adLa4d4C8bdDe4CeaaD15Cd22L2545CeaaD55C3adD95C2adLa5d5C3adDe5CeaaD26Cd66D36CeaaD46C5bdD96C2adLa6d6C5bdDe6CdefD97C3adDa7C2adLb7c7C3adDd7CdefDe7Cfa9D58Cf84D68Cf97D78CfeeD88CdefDa8C9ceLb8c8CdefDd8Cfa9D49Cf70L5979Cf84D89CfeeD99Cf72D4aCf70L5a7aCf71D8aCfcbD9aCf72D4bCf70L5b7bCf71D8bCfcbD9bCecfDcbCc7fLdbebCecfDfbCfa9D4cCf70L5c7cCf84D8cCfeeD9cCecfDbcCb5fLccfcC7e4D0dCbfaD1dCfa9D5dCf84D6dCf97D7dCfeeD8dCc7fDbdCb5fLcdfdC6e2L0e1eCbfaD2eCc7fDbeCb5fLcefeC6e2L0f1fC7e5D2fCecfDbfCb5fLcfff" {
    run("Count Nuclei");
}

macro "Make Points Selection Action Tool - C110Db1Db2D23L93d3D24Db4L0545Db5D26D27D78D79L5a9aD7bDdbD7cDdcLbdfdDdeDdf" {
    run("Points From Labels");
}

macro "Update Count Action Tool - CeeeD41CdddD51CeeeL8191C888D22C333D32C222L4252CeeeD62C222L8292C555Da2CcccDb2CeeeD23C222L3353CdddD83CbbbD93C555Da3C222Db3C999Dc3CbbbD24C222D34C333D44C222D54C999Db4C222Dc4CbbbDd4C333D25C777D35C999D55C777Dc5C333Dd5CcccD16C222D26CdddD36Dc6C222Dd6CcccDe6CbbbD17C222D27CeeeD37C222Dd7CbbbDe7D18C222D28CeeeD38C222Dd8CbbbDe8CdddD19C222D29CcccD39CdddDc9C222Dd9CcccDe9C333D2aC666D3aC999DaaC777DcaC222DdaCbbbD2bC222D3bC999D4bC333DabC444DbbC222DcbCaaaDdbC999D3cC222D4cC555D5cCbbbD6cCdddD7cC222LacccCeeeDdcCcccD4dC555D5dC222L6d7dCeeeL8d9dC222LadcdC888DddCeeeD6eCdddD7eDaeCeeeDbe" {
    run("Update CSV");
}

macro "Switch Mode Action Tool - CdddD53CaaaD63C888L7383CaaaD93CdddDa3CcccD34C444D44C000D54C444D64CaaaL7484C444D94C000Da4C444Db4CcccDc4C888D25C000L3545C888D55Da5C000Lb5c5C888Dd5C666D16C000L2636C444D46C999L7686C444Db6C000Lc6d6C666De6C888D07C000L1737CaaaD47C999D67C000L7787C999D97CaaaDb7C000Lc7e7C999Df7D08C000L1838CaaaD48C999D68C000L7888C999D98CaaaDb8C000Lc8e8C888Df8C666D19C000L2939C444D49C999L7989C444Db9C000Lc9d9C666De9C888D2aC000L3a4aC888D5aDaaC000LbacaC888DdaCcccD3bC444D4bC000D5bC444D6bCaaaL7b8bC444D9bC000DabC444DbbCcccDcbCdddD5cCaaaD6cC888L7c8cCaaaD9cCdddDac" {
    Stack.getDisplayMode(mode);

    if (mode == "composite") {
        Stack.setDisplayMode("color");
    }
    else {
        Stack.setDisplayMode("composite");
    }
}

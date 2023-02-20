
var dCmds = newMenu(
    "Spots in neurons Menu Tool",
    newArray(
        "About",
        "Tips", 
        "Settings",
        "-",
        "Thanks"
    )
);


macro "Spots in neurons Menu Tool - C037T0b11DT7b09eTcb09v" {
    cmd = getArgument();
    if (cmd=="About")
        run("SIN About");
    else if (cmd=="Tips")
        run("SIN Tips");
    else if (cmd=="Settings")
        run("SIN Settings");
    else if (cmd=="Thanks")
        run("SIN Thanks");
}

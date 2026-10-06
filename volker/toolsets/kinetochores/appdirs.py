from ij import IJ

def user_data_dir(appName):
    applicationName = appName.replace(' ', '_')
    userDataDir = IJ.getDirectory("plugins")  
    userDataDir = IJ.addSeparator(userDataDir) + applicationName
    return userDataDir
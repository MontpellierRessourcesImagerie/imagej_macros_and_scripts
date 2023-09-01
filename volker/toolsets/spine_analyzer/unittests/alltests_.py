import unittest
import sys
import fr.cnrs.mri.cialib.unittests.segmentationtest as segmentationtest
import fr.cnrs.mri.cialib.unittests.stackutilstest as stackutilstest
import fr.cnrs.mri.cialib.unittests.neuronstest as neuronstest

suites = []
suites.append(unittest.defaultTestLoader.loadTestsFromModule(segmentationtest))
suites.append(unittest.defaultTestLoader.loadTestsFromModule(stackutilstest))
suites.append(unittest.defaultTestLoader.loadTestsFromModule(neuronstest))


print(suites)
allTests = unittest.TestSuite()
def main(): 
    runner = unittest.TextTestRunner(sys.stdout, verbosity=2)
    for suite in suites:
        allTests.addTests(suite)
    runner.run(allTests)



if __name__ == "__main__":
    main()
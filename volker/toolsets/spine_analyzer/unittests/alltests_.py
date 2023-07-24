import unittest
import sys
import fr.cnrs.mri.cialib.unittests.segmentationtest as segmentationtest
import fr.cnrs.mri.cialib.unittests.hyperstackutilstest as hyperstackutilstest
import fr.cnrs.mri.cialib.unittests.neuronstest as neuronstest

suites = []
suites.append(unittest.defaultTestLoader.loadTestsFromModule(segmentationtest))
suites.append(unittest.defaultTestLoader.loadTestsFromModule(hyperstackutilstest))
suites.append(unittest.defaultTestLoader.loadTestsFromModule(neuronstest))


print(suites)

def main(): 
    runner = unittest.TextTestRunner(sys.stdout, verbosity=2)
    for suite in suites:
        runner.run(suite)



if __name__ == "__main__":
    main()
import unittest
import sys
from ij import IJ


class DendritesTest(unittest.TestCase):


    def setUp(self):
        unittest.TestCase.setUp(self)
        IJ.run("Close All");


    def tearDown(self):
        unittest.TestCase.tearDown(self)
        IJ.run("Close All");
        
        
    def testConstructor(self):
        pass
        
        
def suite():
    suite = unittest.TestSuite()

    suite.addTest(DendritesTest('testConstructor'))
    return suite



def main(): 
    runner = unittest.TextTestRunner(sys.stdout, verbosity=2)
    runner.run(suite())



if __name__ == "__main__":
    main()
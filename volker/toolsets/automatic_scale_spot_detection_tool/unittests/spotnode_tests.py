import unittest, math, sys, pprint
from fr.cnrs.mri.datastructures.spotnode import SpotNode

class SpodNodeTest(unittest.TestCase):
	def testConstructor(self):
		spot = SpotNode(1, 10, 11, 2, 5)
		self.assertEquals(spot.x, 10)
		self.assertEquals(spot.y, 11)
		self.assertEquals(spot.z, 2)
		self.assertEquals(spot.radius, 5)
		self.assertEquals(spot.parent is None, True)
		self.assertEquals(len(spot.children), 0)
		self.assertEquals(math.isnan(spot.value), True)
		spot2 = SpotNode(2, 20, 30, 2, 10, -1.822)
		self.assertEquals(spot2.value, -1.822)

	def testIsRoot(self):
		root = SpotNode(1, 400, 400, 4, 566)
		child1 = SpotNode(2, 410, 420, 3, 25)
		child2 = SpotNode(3, 300, 300, 3, 30)
		root.addChild(child1)
		root.addChild(child2)
		self.assertEquals(root.isRoot(), True)
		self.assertEquals(child1.isRoot(), False)
		self.assertEquals(child2.isRoot(), False)
		
	def testIncludes(self):
		includingSpot = SpotNode(1, 50, 50, 2, 10)
		includedSpot = SpotNode(2, 45, 43, 1, 5)
		notIncludedSpot = SpotNode(3, 39, 39, 1, 6)
		self.assertEquals(includingSpot.includes(includedSpot), True)
		self.assertEquals(includingSpot.includes(notIncludedSpot), False)

	def testAddChild(self):
		root = SpotNode(1, 400, 400, 4, 566)
		child1 = SpotNode(2, 410, 420, 3, 25)
		child2 = SpotNode(3, 300, 300, 3, 30)
		grandChild1 = SpotNode(4, 412, 418, 2, 10)
		grandChild2 = SpotNode(5, 290, 305, 2, 10)
		grandGrandChild1 = SpotNode(6, 410, 415, 1, 5)
		grandGrandChild2 = SpotNode(7, 292, 300, 1, 5)
		
		root.addChild(child1)
		root.addChild(child2)
		root.addChild(grandChild1)
		root.addChild(grandChild2)
		root.addChild(grandGrandChild1)
		root.addChild(grandGrandChild2)
		
		self.assertEquals(len(root.children), 2)
		self.assertEquals(len(child1.children), 1)
		self.assertEquals(len(child2.children), 1)
		self.assertEquals(len(grandChild1.children), 1)
		self.assertEquals(len(grandChild2.children), 1)

	def testAsList(self):
		root = SpotNode(1, 400, 400, 4, 566)
		child1 = SpotNode(2, 410, 420, 3, 25)
		child2 = SpotNode(3, 300, 300, 3, 30)
		grandChild1 = SpotNode(4, 412, 418, 2, 10)
		grandChild2 = SpotNode(5, 290, 305, 2, 10)
		grandGrandChild1 = SpotNode(6, 410, 415, 1, 5)
		grandGrandChild2 = SpotNode(7, 292, 300, 1, 5)
		
		root.addChild(child1)
		root.addChild(child2)
		root.addChild(grandChild1)
		root.addChild(grandChild2)
		root.addChild(grandGrandChild1)
		root.addChild(grandGrandChild2)

		spotList = root.asList()
		
		self.assertEquals(len(spotList), 2)
		self.assertEquals(len(spotList[1]), 4)

	def testGetIsolatedSpots(self):
		root = SpotNode(1, 400, 400, 4, 566)
		child1 = SpotNode(2, 410, 420, 3, 25)
		child2 = SpotNode(3, 300, 300, 3, 30)
		grandChild1 = SpotNode(4, 412, 418, 2, 10)
		grandChild2 = SpotNode(5, 290, 305, 2, 10)
		grandGrandChild1 = SpotNode(6, 410, 415, 1, 5)
		grandGrandChild2 = SpotNode(7, 292, 300, 1, 5)

		isolated1 = SpotNode(8, 200, 200, 2, 5)

		root.addChild(child1)
		root.addChild(child2)
		root.addChild(grandChild1)
		root.addChild(grandChild2)
		root.addChild(isolated1)
		root.addChild(grandGrandChild1)
		root.addChild(grandGrandChild2)

		isolatedSpots = root.getIsolatedSpots()
		self.assertEquals(isolatedSpots[0].spotID == isolated1.spotID, True)

	def testRemove(self):
		root = SpotNode(1, 400, 400, 4, 566)
		child1 = SpotNode(2, 410, 420, 3, 25)
		child2 = SpotNode(3, 300, 300, 3, 30)
		grandChild1 = SpotNode(4, 412, 418, 2, 10)
		grandChild2 = SpotNode(5, 290, 305, 2, 10)
		grandGrandChild1 = SpotNode(6, 410, 415, 1, 5)
		grandGrandChild2 = SpotNode(7, 292, 300, 1, 5)
		
		root.addChild(child1)
		root.addChild(child2)
		root.addChild(grandChild1)
		root.addChild(grandChild2)
		root.addChild(grandGrandChild1)
		root.addChild(grandGrandChild2)

		child1.remove()
		self.assertEquals(len(root.children), 2)
		self.assertEquals(grandChild1 in root.children, True)
		self.assertEquals(len(root.flatten()), 6) 
		self.assertEquals(not child1.parent, True)

	def testGetSpot(self):
		root = SpotNode(1, 400, 400, 4, 566)
		child1 = SpotNode(2, 410, 420, 3, 25)
		child2 = SpotNode(3, 300, 300, 3, 30)
		grandChild1 = SpotNode(4, 412, 418, 2, 10)
		grandChild2 = SpotNode(5, 290, 305, 2, 10)
		grandGrandChild1 = SpotNode(6, 410, 415, 1, 5)
		grandGrandChild2 = SpotNode(7, 292, 300, 1, 5)

		root.addChild(child1)
		root.addChild(child2)
		root.addChild(grandChild1)
		root.addChild(grandChild2)
		root.addChild(grandGrandChild1)
		root.addChild(grandGrandChild2)

		spot4 = root.getSpot(4)
		spotNone = root.getSpot(100000)

		self.assertEquals(spot4 is grandChild1, True)
		self.assertEquals(spotNone is None, True)

	def testSortingOfNodes(self):
		root = SpotNode(1, 400, 400, 4, 566)
		node1 = SpotNode(181, 69.5, 194.5, 6.0, 5.5)
		node2 = SpotNode(150, 68.0, 192.0, 5.0, 5.0)
		node3 = SpotNode(120, 66.0, 192.0, 4.0, 4.0)
		node4 = SpotNode(89, 65.5, 193.5, 3.0, 3.5)
		node5 = SpotNode(54, 64.0, 194.0, 2.0, 3.0)
		node6 = SpotNode(12, 64.5, 194.5, 1.0, 2.5)
		root.addChild(node1)
		root.addChild(node2)
		root.addChild(node3)
		root.addChild(node4)
		root.addChild(node5)
		root.addChild(node6)

		self.assertEquals(len(root.children), 2)
		
def suite():
	suite = unittest.TestSuite()

	suite.addTest(SpodNodeTest('testConstructor'))
	suite.addTest(SpodNodeTest('testIsRoot'))
	suite.addTest(SpodNodeTest('testIncludes'))
	suite.addTest(SpodNodeTest('testAddChild'))
	suite.addTest(SpodNodeTest('testAsList'))
	suite.addTest(SpodNodeTest('testGetIsolatedSpots'))
	suite.addTest(SpodNodeTest('testRemove'))
	suite.addTest(SpodNodeTest('testGetSpot'))
	suite.addTest(SpodNodeTest('testSortingOfNodes'))
	return suite

runner = unittest.TextTestRunner(sys.stdout, verbosity=1)
runner.run(suite())


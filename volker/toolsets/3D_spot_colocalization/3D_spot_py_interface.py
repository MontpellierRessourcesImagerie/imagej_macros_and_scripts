from ij import IJ
from ijpb.fiji.IPythonProxy import IPythonProxy

def init():

	p.run("from napari_j.bridge import Bridge")
	p.run("print(viewer)")

	p.run("bridge = Bridge(viewer)")
	p.run("print(type(bridge))")

	p.run("a = 3")
	p.run("print(a)")


def disconnect():
	p.disconnect()

def sendActiveImage():
	p.run("bridge.getActiveImageFromIJ()")

def sendPoints():
	if(len(args) >= 1):
		print(args[0].split("=")[1])
		p.run("bridge.displayPoints(\""+args[0].split("=")[1]+"\")")
		#p.run("bridge.displayPoints('"+args[0].split("=")[1]+"')")
	else:
		p.run("bridge.displayPoints()")

	if(len(args) >= 2):
		p.run("bridge.displayPoints(\""+args[1].split("=")[1]+"\")")
		#p.run("bridge.displayPoints('"+args[1].split("=")[1]+"')")
	

def sendLines():
	if(len(args) >= 1):
		p.run("bridge.getPairs(\""+args[0].split("=")[1]+"\")")
	else:
		p.run("bridge.getPairs()")


def main(action, args = None):
	init()
	if action == "sendActiveImage":
		sendActiveImage()
	elif action == "sendPoints":
		sendPoints()
	elif action == "sendLines":
		sendLines()
	else:
		p.run("print('Undefined action <"+str(action)+">'")
	disconnect()


p = IPythonProxy()
# p.run("bridge = Bridge(viewer)")
# sendActiveImage()
# sendPoints()
# sendLines()
# disconnect()

if 'getArgument' in globals():
	parameter = getArgument()
	args = parameter.split(",")
	action = args[0].split("=")[1]
	args.pop(0)
main(action, args)

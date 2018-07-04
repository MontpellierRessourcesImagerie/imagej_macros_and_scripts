import ColorQuantizerUtil

numberOfColors = 16
colorSpace = "HSB"
method = "Wu" 

def run():
	global numberOfColors, colorSpace, method
	if method == 'Histogram':
		ColorQuantizerUtil.quantize(numberOfColors, colorSpace)
	if method == 'Median Cut':
		ColorQuantizerUtil.quantizeMedianCut(numberOfColors, colorSpace)
	if method == 'Wu':
		ColorQuantizerUtil.quantizeWu(numberOfColors, colorSpace)

if 'getArgument' in globals():
  parameter = getArgument()
  args = parameter.split(",")
  arg1 = args[0]
  arg2 = args[1]
  arg3 = args[2]
  val1 = arg1.split("=")
  val2 = arg2.split("=")
  val3 = arg3.split("=")
  numberOfColors = int(val1[1])
  colorSpace = int(val2[1])
  method = val3[1] 
run()
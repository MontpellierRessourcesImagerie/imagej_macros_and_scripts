import numpy as np
import pandas as pd
from pprint import pprint
import matplotlib.pyplot as plt
import os
import sys

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                                   #
#   Function seeking sign switchings in derivate to locate extremums                #
#   Returns a dictionary with the 2 maximums and the lowest minimum                 #
#                                                                                   #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

def seekExtremums(data, derivate):
    k = 0
    # We search for sign switchings, we are not interested in 0 (constant) pieces.
    while derivate[k] == 0.0:
        k += 1
    
    last = 'POS' if derivate[0] > 0 else 'NEG'
    minimums = []
    maximums = []

    for i in range(k, len(derivate)):
        if derivate[i] == 0.0:
            continue
        current = 'POS' if derivate[i] > 0 else 'NEG'

        if last != current:
            if last == 'POS':
                maximums.append((i, data[i]))
            else:
                minimums.append((i, data[i]))
        
        last = current

    minimums.sort(key=lambda a: a[1])
    maximums.sort(key=lambda a: a[1])

    minimums = minimums[0:1]
    maximums = maximums[-2:]

    return {'minimums': minimums, 'maximums': maximums}


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                                   #
#   Function smoothing a discrete curve by averaging with neighbours                #
#   'side_range' is the distance on the left and on the right to which the          #
#   neighbours will be fetched                                                      #
#                                                                                   #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

def smoothCurve(curve, side_range):
    points = []

    for i in range(0, len(curve)):
        start = i - side_range
        end = i + side_range
        

        if (start < 0) or (end >= len(curve)):
            points.append(curve['Mean'][i])
            continue
        
        accumulator = 0
        for j in range(start, end+1):
            accumulator += curve['Mean'][j]
        
        div = 2 * side_range + 1
        accumulator /= div

        points.append(accumulator)
    
    return points


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                                   #
#  Processes the derivative of a discretised function stored in a list.             #
#  The last point is set to 0 (considered as leading to a constant function)        #
#                                                                                   #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

def derivate(points):
    derivative = []
    for i in range(0, len(points)):
        if (i == len(points)-1):
            continue
        derivative.append(points[i+1]-points[i])
    derivative.append(0)
    return derivative


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                                   #
#  Determines the first and last slice to be used during the segmentation phase     #
#                                                                                   #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

def findAcceptedRange(values, extremums, tolerance):
    absoluteMax = np.max([l[1] for l in extremums['maximums']])
    absoluteMin = extremums['minimums'][0][1]
    distance = absoluteMax - absoluteMin
    
    print("Distance: ", distance)

    upperBoundary = absoluteMin + tolerance * distance
    middle = extremums['minimums'][0][0]
    start = middle
    end = middle

    while (start >= 0) and (values[start] < upperBoundary):
        start -= 1

    while (end < len(values)) and (values[end] < upperBoundary):
        end += 1

    return {'start': start, 'end': end}


######################################################################################
##                >>>  MAIN  <<<                                                    ##
######################################################################################

def build_extremum_curves():

    outputFilePath = "/home/benedetti/Bureau/output.txt"
    output = open(outputFilePath, 'w')

    for i in range(0, 32):
        print("- - - - - - - - - - - - - - - - - - - - - - - - -")
        path = f"/home/benedetti/Bureau/CSVs/auxin-1-frame-{str(i).rjust(4, '0')}.csv"
        
        print("Current: ", path)

        if not os.path.exists(path):
            print("The path doesn't exist")
            continue

        curve = pd.read_csv(path)
        plt.rc('font', size=6) 

        # Conserve only y axis, smooth to remove noise and normalize
        points = smoothCurve(curve, 2)
        points = [p / np.max(points) for p in points]
        plt.plot(points, lw=1, label="data")

        # Derivative of previous points (function)
        der = derivate(points)
        plt.plot(der, lw=0.3, label="derivative")

        # Find extremums from sign variations in the derivative
        extremums = seekExtremums(points, der)

        plt.scatter(
            x=[l[0] for l in extremums['minimums']], 
            y=[l[1] for l in extremums['minimums']],
            color='green',
            marker='^')

        plt.scatter(
            x=[l[0] for l in extremums['maximums']], 
            y=[l[1] for l in extremums['maximums']],
            color='red',
            marker='v')

        acceptedRange = findAcceptedRange(points, extremums, 0.15)

        plt.axhline(y=0, color='black', lw=1)
        plt.axvline(x=acceptedRange['start'], color='green', lw=1, ls=':', label='start')
        plt.axvline(x=acceptedRange['end'], color='red', lw=1, ls=':', label='end')

        plt.legend()
        plt.tight_layout()

        for key, item in acceptedRange.items():
            output.write(f"{str(key)}:{str(item)}\n")

        # plt.show()
        plt.savefig(f"/home/benedetti/Bureau/auxin-1-curves/auxin-{str(i).rjust(4, '0')}.png", dpi=200)
        plt.clf()

    output.close()


def launchProcedure(imgPath):
    print("Processing: " + imgPath)
    pass


def main():
    if len(sys.argv) <= 1:
        print("This script takes the path of a folder containing .tiff")
        return -1

    pathOfImages = sys.argv[1]

    for imgPath in sorted(os.listdir(pathOfImages)):
        launchProcedure(os.path.join(pathOfImages, imgPath))
    
    return 0;

 # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
 # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

main()


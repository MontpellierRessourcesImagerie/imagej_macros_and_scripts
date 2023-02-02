from __future__ import division
from  ij.gui import Plot
from org.apache.commons.math3.stat.correlation import PearsonsCorrelation
import math

def main():
    tensinOverTime =  [227.0179, 212.4615, 205.2333, 213.3256, 246.1128, 425.2077, 253.7026, 213.1487, 210.9000, 342.0641, 217.3282, 441.9974, 321.7128, 315.6333, 331.4205, 326.6718, 259.8820, 213.6744, 271.4949, 219.6308, 268.7436, 226.2051, 391.6743, 341.6461, 236.5436, 208.5179, 215.6718, 206.9538, 214.3308, 205.1513, 238.2051, 222.1077, 212.3128, 212.7462, 209.9282, 204.5205, 206.7410, 219.4769, 211.6231, 242.1667, 247.2205, 226.9641, 221.7846, 223.3026, 223.7846, 228.9923]
    adhesionOverTime = [3570.7393, 3652.5569, 3694.8225, 3736.6016, 3733.9392, 3715.6863, 3658.1121, 3657.2671, 3665.9968, 3648.4097, 3649.3567, 3735.9104, 3736.8064, 3654.4255, 3654.7839, 3671.2705, 3646.0544, 3655.0657, 3657.1904, 3707.6479, 3625.2417, 3779.2256, 3753.8816, 3762.2273, 3710.1057, 3717.6064, 3734.6560, 3745.4080, 3634.8928, 3621.4785, 3657.1392, 3700.7104, 3687.5264, 3712.1536, 3786.5471, 3837.3376, 3869.4399, 3840.5889, 3883.3665, 3917.4656, 3967.5137, 4020.6335, 4046.5408, 4019.1487, 3911.5776, 3771.0337]
    
    n = len(adhesionOverTime)
    assert(len(tensinOverTime)==n)
    
    maxLag = int(math.floor(n / 2))
    correlationByLag = xCorrelate(tensinOverTime, adhesionOverTime, maxLag)
    plot = Plot("cross-correlation", "t", "cc")
    plot.add("separated bar", range(-maxLag, maxLag+1), correlationByLag)
    plot.show()
    
       
def xCorrelate(a, b, maxLag):
        correlator = PearsonsCorrelation()
        lags = range(-maxLag, maxLag+1)
        xCorr = [0] * len(lags)
        index = 0
        for lag in lags:
            if lag < 0:
                data = a[0:lag]
                window = b[-lag:]
            if lag == 0:
                data = a
                window = b
            if lag > 0:
                data = a[lag:]
                window = b[0:-lag]
            xCorr[index] = correlator.correlation(data, window)
            index = index + 1
        return xCorr

main()

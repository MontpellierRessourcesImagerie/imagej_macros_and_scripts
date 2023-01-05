from ij.process import LUT
import random

def createLUT():
    r = [random.randint(-128, 127) for i in range(0, 256)]
    g = [random.randint(-128, 127) for i in range(0, 256)]
    b = [random.randint(-128, 127) for i in range(0, 256)]
    r[0] = g[0] = b[0] = 0
    lut = LUT(r, g, b)
    return lut

def randomLUT(img):
    if img is not None:
        img.setLut(createLUT())


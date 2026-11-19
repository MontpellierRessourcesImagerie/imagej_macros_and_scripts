# Unit tests for the kinetochore analysis steps.
#
# Runs inside Fiji (Jython) via the bridge:
#   uv run python scripts/fiji_bridge.py run-script --file volker/toolsets/kinetochores/test_kinetochores.py
#
# Segmentation is faked with deterministic synthetic images so that the shared
# steps (background subtraction, control image) and both measurement approaches
# are exercised with hand-computable expected values.

import math

from java.awt import Color
from ij import IJ
from ij import ImagePlus
from ij import ImageStack
from ij.measure import ResultsTable
from ij.process import FloatProcessor
from ij.process import ByteProcessor
from ij.process import ShortProcessor

from fr.cnrs.mri.cialib.kinetochores import OverlapKinetochoreAnalyzer
from fr.cnrs.mri.cialib.kinetochores import DilatedKinetochoreAnalyzer
from fr.cnrs.mri.cialib.kinetochores import ImageTool

OUT = "/tmp/opencode/test_kinetochores_results.txt"

W = 64
H = 64

results = []
failures = 0


def check(condition, message):
    global failures
    results.append(("PASS" if condition else "FAIL") + " " + message)
    if not condition:
        failures += 1


def close(a, b, tol=1e-4):
    return abs(float(a) - float(b)) <= tol


# ---------------------------------------------------------------- fixtures

def fillRectShort(proc, x0, y0, w, h, value):
    for x in range(x0, x0 + w):
        for y in range(y0, y0 + h):
            proc.set(x, y, value)


def makeSyntheticImage():
    """Stack with 2 channels, 1 slice (16-bit like real data):
    ch1 (signal + cells): bg 30; cell1 110 (kt1 220); cell2 90 (kt2 180)
    ch2 (kinetochores):   bg 10; kt1/kt2 255
    cell1: x,y in [10,16)  label 1   kt1: x,y in [11,13)  (2x2)
    cell2: x,y in [40,44)  label 2   kt2: x,y in [41,43)  (2x2)
    """
    sig = ShortProcessor(W, H)
    fillRectShort(sig, 0, 0, W, H, 30)
    fillRectShort(sig, 10, 10, 6, 6, 110)
    fillRectShort(sig, 11, 11, 2, 2, 220)
    fillRectShort(sig, 40, 40, 4, 4, 90)
    fillRectShort(sig, 41, 41, 2, 2, 180)
    ktch = ShortProcessor(W, H)
    fillRectShort(ktch, 0, 0, W, H, 10)
    fillRectShort(ktch, 11, 11, 2, 2, 255)
    fillRectShort(ktch, 41, 41, 2, 2, 255)
    stack = ImageStack(W, H)
    stack.addSlice("signal", sig)
    stack.addSlice("kinetochores", ktch)
    imp = ImagePlus("synthetic", stack)
    imp.setDimensions(2, 1, 1)
    imp.setOpenAsHyperStack(True)
    return imp


def makeLabels():
    lab = ShortProcessor(W, H)
    for x in range(10, 16):
        for y in range(10, 16):
            lab.set(x, y, 1)
    for x in range(40, 44):
        for y in range(40, 44):
            lab.set(x, y, 2)
    return ImagePlus("cell labels", lab)


def makeKtMask(empty=False):
    m = ByteProcessor(W, H)
    if not empty:
        for x in range(11, 13):
            for y in range(11, 13):
                m.set(x, y, 255)
        for x in range(41, 43):
            for y in range(41, 43):
                m.set(x, y, 255)
    return ImagePlus("kt mask", m)


class FakeCellSegmenter(object):

    def __init__(self, labels):
        self.labels = labels

    def run(self, image):
        pass


class FakeSpotSegmenter(object):

    def __init__(self, masks):
        self.masks = list(masks)
        self.mask = None

    def run(self, image):
        self.mask = self.masks.pop(0)


def countForeground(mask):
    proc = mask.getProcessor()
    count = 0
    for y in range(mask.getHeight()):
        for x in range(mask.getWidth()):
            if proc.get(x, y) != 0:
                count += 1
    return count


def findRow(table, label):
    for row in range(table.getCounter()):
        if str(table.getLabel(row)) == str(label):
            return row
    return -1


def findSliceWith(image, x, y, value):
    """Return the first stack slice whose pixel value at (x, y) equals `value`."""
    for i in range(1, image.getStackSize() + 1):
        proc = image.getStack().getProcessor(i)
        if close(proc.getf(x, y), value):
            return proc
    return None


def runDilated(radius, threshold, masks=None):
    imp = makeSyntheticImage()
    if masks is None:
        masks = [makeKtMask(), makeKtMask()]
    analyzer = DilatedKinetochoreAnalyzer(FakeCellSegmenter(makeLabels()),
                                          FakeSpotSegmenter(masks), imp)
    analyzer.kinetochoreDilationRadius = radius
    analyzer.signalThreshold = threshold
    analyzer.table = ResultsTable()
    analyzer.run()
    return analyzer


def popStdDev(values):
    n = len(values)
    if n < 1:
        return 0.0
    mean = sum(values) / n
    return math.sqrt(sum((v - mean) ** 2 for v in values) / n)


def sampleStdDev(values):
    n = len(values)
    if n < 2:
        return 0.0
    mean = sum(values) / n
    return math.sqrt(sum((v - mean) ** 2 for v in values) / (n - 1))


def median(values):
    s = sorted(values)
    n = len(s)
    if n % 2 == 1:
        return s[(n - 1) // 2]
    return (s[n // 2 - 1] + s[n // 2]) / 2.0


def mode(values):
    return max(set(values), key=values.count)


def checkRowBasics(table, row, label, pixels, mean, intDen=None, rawIntDen=None, maxV=None, minV=None):
    check(close(table.getValue("Pixels", row), pixels), "  %s Pixels=%s" % (label, table.getValue("Pixels", row)))
    check(close(table.getValue("Area", row), pixels), "  %s Area=%s" % (label, table.getValue("Area", row)))
    check(close(table.getValue("Mean", row), mean), "  %s Mean=%s" % (label, table.getValue("Mean", row)))
    if intDen is not None:
        check(close(table.getValue("IntDen", row), intDen), "  %s IntDen=%s" % (label, table.getValue("IntDen", row)))
    if rawIntDen is not None:
        check(close(table.getValue("RawIntDen", row), rawIntDen), "  %s RawIntDen=%s" % (label, table.getValue("RawIntDen", row)))
    if maxV is not None:
        check(close(table.getValue("Max", row), maxV), "  %s Max=%s" % (label, table.getValue("Max", row)))
    if minV is not None:
        check(close(table.getValue("Min", row), minV), "  %s Min=%s" % (label, table.getValue("Min", row)))
    check(close(table.getValue("Median", row), mean), "  %s Median=%s" % (label, table.getValue("Median", row)))
    check(close(table.getValue("Mode", row), mean), "  %s Mode=%s" % (label, table.getValue("Mode", row)))
    check(table.getValue("StdDev", row) == 0 or close(table.getValue("StdDev", row), 0),
          "  %s StdDev=%s" % (label, table.getValue("StdDev", row)))


# ---------------------------------------------------------------- tests

def testThresholdMask():
    fp = FloatProcessor(5, 1)
    fp.putPixelValue(0, 0, -5.0)
    fp.putPixelValue(1, 0, 0.0)
    fp.putPixelValue(2, 0, 3.0)
    fp.putPixelValue(3, 0, 100.0)
    fp.putPixelValue(4, 0, 255.0)
    imp = ImagePlus("t1", fp)
    tool = ImageTool(imp)
    m0 = tool.getThresholdMask(imp, 0)
    v0 = [m0.getProcessor().get(x, 0) for x in range(5)]
    check(v0 == [0, 255, 255, 255, 255], "T1a threshold 0 excludes negatives: %s" % v0)
    m1 = tool.getThresholdMask(imp, 1)
    v1 = [m1.getProcessor().get(x, 0) for x in range(5)]
    check(v1 == [0, 0, 255, 255, 255], "T1b threshold 1 excludes zeros: %s" % v1)
    m100 = tool.getThresholdMask(imp, 100)
    v100 = [m100.getProcessor().get(x, 0) for x in range(5)]
    check(v100 == [0, 0, 0, 255, 255], "T1c threshold 100 keeps >=100: %s" % v100)


def testDilate():
    imp = makeSyntheticImage()
    tool = ImageTool(imp)
    mask = makeKtMask()
    d0 = tool.dilate(mask, 0)
    check(countForeground(d0) == countForeground(mask), "T2a radius 0 is identity (%d px)" % countForeground(d0))
    d1 = tool.dilate(mask, 1)
    c1 = countForeground(d1)
    check(c1 > countForeground(mask), "T2b radius 1 expands (%d px)" % c1)
    check(d1.getProcessor().get(11, 11) == 255, "T2c dilated keeps original pixels")
    # a single pixel dilated by radius 1 should be a small cross/square
    single = ByteProcessor(W, H)
    single.set(W / 2, H / 2, 255)
    singleImp = ImagePlus("single", single)
    dSingle = tool.dilate(singleImp, 1)
    cSingle = countForeground(dSingle)
    check(cSingle in (5, 9), "T2d single pixel dilated by 1 -> 5 or 9 px (got %d)" % cSingle)


def testOverlapPipeline():
    imp = makeSyntheticImage()
    analyzer = OverlapKinetochoreAnalyzer(FakeCellSegmenter(makeLabels()),
                                          FakeSpotSegmenter([makeKtMask(), makeKtMask()]), imp)
    analyzer.table = ResultsTable()
    analyzer.run()
    t = analyzer.table
    check(t.getCounter() == 2, "T3a two rows (got %d)" % t.getCounter())
    row1 = findRow(t, 1)
    row2 = findRow(t, 2)
    check(row1 >= 0 and row2 >= 0, "T3b rows for labels 1 and 2")
    expected = ["Pixels", "Area", "IntDen", "RawIntDen",
                "Max", "Mean", "StdDev", "Median", "Min", "Mode", "image"]
    missingColumns = [h for h in expected if t.getColumnIndex(h) < 0]
    check(len(missingColumns) == 0, "T3c all value columns present (missing: %s)" % missingColumns)
    check(t.getColumnIndex("Cell") < 0, "T3c2 Cell column removed")
    if row1 >= 0:
        checkRowBasics(t, row1, "cell1", 4, 110.0, intDen=440.0, rawIntDen=440.0, maxV=110.0, minV=110.0)
    if row2 >= 0:
        checkRowBasics(t, row2, "cell2", 4, 90.0, intDen=360.0, rawIntDen=360.0, maxV=90.0, minV=90.0)
    # background subtraction: signal image values
    sig = analyzer.signal
    check(sig.getTitle() == "signal with background removed", "T3d signal title")
    check(close(sig.getProcessor().getf(11, 11), 110.0), "T3e kt1 value=110 got %s" % sig.getProcessor().getf(11, 11))
    check(close(sig.getProcessor().getf(14, 14), 0.0), "T3f cell1 rest=0 got %s" % sig.getProcessor().getf(14, 14))
    check(close(sig.getProcessor().getf(41, 41), 90.0), "T3g kt2 value=90 got %s" % sig.getProcessor().getf(41, 41))
    check(close(sig.getProcessor().getf(2, 2), 30.0), "T3h outside=30 got %s" % sig.getProcessor().getf(2, 2))
    check(analyzer.signal is not None, "T3i2 signal image exists")
    check(analyzer.controlImage is not None, "T3i control image created")
    if analyzer.controlImage is not None:
        overlay = analyzer.controlImage.getOverlay()
        names = []
        colors = []
        if overlay is not None:
            for roiIndex in range(overlay.size()):
                roi = overlay.get(roiIndex)
                names.append(str(roi.getName()))
                colors.append(roi.getStrokeColor())
        check(overlay is not None and overlay.size() >= 2,
              "T3j control overlay has kinetochore + signal ROI (size=%s)" % (overlay.size() if overlay else None))
        check("kinetochores" in names, "T3k1 overlay names include kinetochores: %s" % names)
        check("signal" in names, "T3k2 overlay names include signal: %s" % names)
        redIdx = names.index("kinetochores") if "kinetochores" in names else -1
        greenIdx = names.index("signal") if "signal" in names else -1
        if redIdx >= 0:
            check(colors[redIdx] == Color.RED, "T3k3 kinetochores ROI stroke red (got %s)" % colors[redIdx])
        if greenIdx >= 0:
            check(colors[greenIdx] == Color.GREEN, "T3k4 signal ROI stroke green (got %s)" % colors[greenIdx])
        # (The channel count of the control image is not asserted here: a synthetic
        # 2-slice stack is not a hyperstack for ImageJ, so ZProjector collapses it to
        # one channel. Real Bio-Formats CZI inputs are hyperstacks and the control
        # image then has the expected 3 channels.)


def testDilatedRadiusZeroThresholds():
    a = runDilated(0, 0)
    t = a.table
    check(t.getCounter() == 2, "T4a radius0/threshold0 two rows")
    row1 = findRow(t, 1)
    row2 = findRow(t, 2)
    if row1 >= 0:
        checkRowBasics(t, row1, "cell1 t0", 4, 110.0, intDen=440.0, rawIntDen=440.0, maxV=110.0, minV=110.0)
    if row2 >= 0:
        checkRowBasics(t, row2, "cell2 t0", 4, 90.0, intDen=360.0, rawIntDen=360.0, maxV=90.0, minV=90.0)

    a = runDilated(0, 55)
    t = a.table
    check(t.getValue("Mean", findRow(t, 1)) == 110.0, "T4b threshold55 cell1 mean 110")
    check(t.getValue("Mean", findRow(t, 2)) == 90.0, "T4c threshold55 cell2 mean 90")

    a = runDilated(0, 100)
    t = a.table
    check(close(t.getValue("Pixels", findRow(t, 1)), 4), "T4d threshold100 cell1 keeps 4 px")
    check(close(t.getValue("Mean", findRow(t, 1)), 110.0), "T4e threshold100 cell1 mean 110")
    check(close(t.getValue("Pixels", findRow(t, 2)), 0), "T4f threshold100 cell2 zero pixels")
    check(close(t.getValue("Mean", findRow(t, 2)), 0), "T4g threshold100 cell2 zero mean")

    a = runDilated(0, 120)
    t = a.table
    # Discriminator for the threshold being applied to the *corrected* signal:
    # raw kt1 = 220, corrected kt1 = 110. If the threshold were read from the
    # raw image, 120 would keep the 4 kt1 pixels; with the corrected signal it
    # drops them. (This check is the regression guard for the semantics.)
    check(close(t.getValue("Pixels", findRow(t, 1)), 0), "T4h threshold120 cell1 zero pixels (raw 220 would keep, corrected 110 drops)")
    check(close(t.getValue("Pixels", findRow(t, 2)), 0), "T4i threshold120 cell2 zero pixels")

    a = runDilated(0, 150)
    t = a.table
    check(close(t.getValue("Pixels", findRow(t, 1)), 0), "T4l threshold150 cell1 zero pixels (between corrected 110 and raw 220)")
    check(close(t.getValue("Pixels", findRow(t, 2)), 0), "T4m threshold150 cell2 zero pixels (raw 180 would keep)")

    a = runDilated(0, 360)
    t = a.table
    check(close(t.getValue("Pixels", findRow(t, 1)), 0), "T4j threshold360 cell1 zero pixels")
    check(close(t.getValue("Pixels", findRow(t, 2)), 0), "T4k threshold360 cell2 zero pixels")


def testDilatedRadiusOneIndependentRecomputation():
    a = runDilated(1, 0)
    t = a.table
    mask = a.dilatedKtCells
    sig = a.signal
    byLabel = {1: [], 2: []}
    for y in range(H):
        for x in range(W):
            label = mask.getProcessor().get(x, y)
            if label in byLabel:
                byLabel[label].append(sig.getProcessor().getf(x, y))
    for label in (1, 2):
        values = byLabel[label]
        n = len(values)
        check(n > 0, "T5a cell%d has measured pixels (%d, vs 4 kt pixels)" % (label, n))
        if n < 1:
            continue
        mean = sum(values) / n
        row = findRow(t, label)
        check(close(t.getValue("Pixels", row), n), "T5b cell%d Pixels=%s expect %d" % (label, t.getValue("Pixels", row), n))
        check(close(t.getValue("Mean", row), mean), "T5c cell%d Mean=%s expect %s" % (label, t.getValue("Mean", row), mean))
        check(close(t.getValue("RawIntDen", row), sum(values)), "T5d cell%d RawIntDen=%s expect %s" % (label, t.getValue("RawIntDen", row), sum(values)))
        check(close(t.getValue("Min", row), min(values)), "T5e cell%d Min=%s expect %s" % (label, t.getValue("Min", row), min(values)))
        check(close(t.getValue("Max", row), max(values)), "T5f cell%d Max=%s expect %s" % (label, t.getValue("Max", row), max(values)))
        check(close(t.getValue("Median", row), median(values)), "T5g cell%d Median=%s expect %s" % (label, t.getValue("Median", row), median(values)))
        check(close(t.getValue("Mode", row), mode(values)), "T5h cell%d Mode=%s expect %s" % (label, t.getValue("Mode", row), mode(values)))
        tableStd = t.getValue("StdDev", row)
        check(close(tableStd, popStdDev(values)) or close(tableStd, sampleStdDev(values)),
              "T5i cell%d StdDev=%s expect pop=%s sample=%s" % (label, tableStd, popStdDev(values), sampleStdDev(values)))
    # the dilated zone must be strictly larger than the 4px kinetochore and stay inside cell1 (36 px)
    row1 = findRow(t, 1)
    pixels1 = t.getValue("Pixels", row1)
    check(pixels1 > 4, "T5j dilated zone of cell1 larger than kinetochores (%s px)" % pixels1)
    check(pixels1 <= 36, "T5k dilated zone of cell1 stays inside the cell (%s px)" % pixels1)
    check(a.controlImage.getOverlay() is not None and a.controlImage.getOverlay().size() >= 1,
          "T5l control image overlay present")


def testControlImageSignalReplacement():
    """The control image signal channel must show the background-corrected signal.

    Tested on a deterministic 2-channel stand-in (channel 1 = raw signal
    placeholder, channel 2 = kinetochores placeholder): after the replacement,
    channel 1 must carry the corrected signal values and channel 2 must be
    unchanged. (A real pipeline control image cannot be built in-memory as a
    hyperstack - ImageJ only marks Bio-Formats-opened files as such - so the
    step is tested in isolation.)
    """
    imp = makeSyntheticImage()
    analyzer = OverlapKinetochoreAnalyzer(FakeCellSegmenter(makeLabels()),
                                          FakeSpotSegmenter([makeKtMask(), makeKtMask()]), imp)
    analyzer.table = ResultsTable()
    analyzer.run()

    # stand-in control image: ch1 raw signal placeholder (100), ch2 kt (200)
    s1 = ShortProcessor(W, H)
    s2 = ShortProcessor(W, H)
    for x in range(W):
        for y in range(H):
            s1.set(x, y, 100)
            s2.set(x, y, 200)
    stack = ImageStack(W, H)
    stack.addSlice("ch1 raw", s1)
    stack.addSlice("ch2 kt", s2)
    standIn = ImagePlus("stand-in", stack)
    standIn.setDimensions(2, 1, 1)
    analyzer.controlImage = standIn
    analyzer.replaceSignalWithBackgroundCorrectedSignal()

    ch1 = standIn.getStack().getProcessor(1)
    ch2 = standIn.getStack().getProcessor(2)
    sig = analyzer.signal.getProcessor()
    check(close(ch1.getf(11, 11), 110.0), "T7a control ch1 kt1 corrected=110 got %s" % ch1.getf(11, 11))
    check(close(ch1.getf(14, 14), 0.0), "T7b control ch1 cell1 rest=0 got %s" % ch1.getf(14, 14))
    check(close(ch1.getf(2, 2), sig.getf(2, 2)), "T7c control ch1 outside=signal value got %s" % ch1.getf(2, 2))
    check(close(ch1.getf(42, 42), sig.getf(42, 42)), "T7d control ch1 cell2 rest=signal value")
    check(ch2.get(5, 5) == 200, "T7e control ch2 untouched got %s" % ch2.get(5, 5))


def testEmptyKinetochores():
    emptyMasks = [makeKtMask(empty=True), makeKtMask(empty=True)]
    imp = makeSyntheticImage()
    a1 = OverlapKinetochoreAnalyzer(FakeCellSegmenter(makeLabels()),
                                    FakeSpotSegmenter(list(emptyMasks)), imp)
    a1.table = ResultsTable()
    a1.run()
    t = a1.table
    check(t.getCounter() == 1, "T6a overlap: single zero row (got %d)" % t.getCounter())
    check(close(t.getValue("Pixels", 0), 0), "T6b overlap: Pixels 0")
    check(close(t.getValue("Mean", 0), 0), "T6c overlap: Mean 0")

    a2 = runDilated(3, 0, masks=list(emptyMasks))
    t = a2.table
    check(t.getCounter() == 1, "T6d dilated: single zero row (got %d)" % t.getCounter())
    check(close(t.getValue("Pixels", 0), 0), "T6e dilated: Pixels 0")
    check(close(t.getValue("Mean", 0), 0), "T6f dilated: Mean 0")
    check(a2.dilatedKtCells is None, "T6g dilated: no measured-zones image")


# ---------------------------------------------------------------- runner

try:
    testThresholdMask()
    testDilate()
    testOverlapPipeline()
    testDilatedRadiusZeroThresholds()
    testDilatedRadiusOneIndependentRecomputation()
    testControlImageSignalReplacement()
    testEmptyKinetochores()
except:
    import traceback
    results.append("FATAL " + traceback.format_exc().replace("\n", " | "))

with open(OUT, "w") as f:
    f.write("kinetochore unit tests\n")
    f.write("passed: %d, failed: %d\n" % (len(results) - failures, failures))
    for line in results:
        f.write(line + "\n")
    f.write("DONE\n")

print("wrote %s (%d checks, %d failures)" % (OUT, len(results), failures))

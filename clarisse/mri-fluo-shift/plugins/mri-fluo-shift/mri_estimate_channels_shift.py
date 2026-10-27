# Script permettant d'estimer le shift entre différents channels à partir d'une image.
# Le résultat est sauvegardé au format JSON pour être réutilisé
import math
import json
import os
from ij.gui import GenericDialog
from ij import IJ
from ij.plugin import (
	ZProjector,
	Duplicator
)
from ij.plugin.filter import (
	MaximumFinder,
	GaussianBlur,
	BackgroundSubtracter
)


def ask_settings(n_channels):
	gd = GenericDialog("Channels shifting")
	
	gd.addStringField("Microscope", "Upright 4")
	
	gd.addStringField("Objective", "40x")
	
	for i in range(1, n_channels+1):
		txt = "C"+str(i)
		if i == 1:
			txt += " (ref)"
		gd.addStringField(txt, "")
		
	gd.addNumericField("Num. beads", 2)
	
	gd.addDirectoryField("Output folder", "")
		
	gd.showDialog()
	
	return {
		"microscope": gd.getNextString(),
		"objective" : gd.getNextString(),
		"channels"  : [gd.getNextString() for i in range(n_channels)],
		"n_beads"   : int(gd.getNextNumber()),
		"output"    : gd.getNextString()
	}


def extract_ref_points(img, ch_index, n_beads):
	ch = Duplicator().run(img, ch_index+1, ch_index+1, 1, 1, 1, 1)
	prc = ch.getProcessor()
	
	BackgroundSubtracter().rollingBallBackground(prc, 50, False, False, True, True, True)
	
	GaussianBlur().blurGaussian(prc, 1.0)
	
	stats = prc.getStats()
	m = stats.mean
	candidates = MaximumFinder().getMaxima(prc, m, True, True)
	
	maximas = []
	for x, y in zip(candidates.xpoints, candidates.ypoints):
		maximas.append((prc.get(x, y), x, y))
	
	ch.close()
	if len(maximas) < n_beads:
		return None
	
	maximas = sorted(maximas)
	maximas = [(x, y) for _, x, y in maximas[-n_beads:]]
	return maximas
	
	
def distance(p1, p2):
	acc = 0.0
	for c1, c2 in zip(p1, p2):
		acc += (c1-c2)*(c1-c2)
	return math.sqrt(acc)
	
	
def closest(pt, cloud):
	dist = float("inf")
	best = None
	for candidate in cloud:
		d = distance(candidate, pt)
		if d < dist:
			dist = d
			best = candidate
	return best
	
	
def estimate_shift(img, ch_list, index, ref):
	moving_points = extract_ref_points(img, index, len(ref))
	if moving_points is None:
		return None
	
	points_pairs = []
	for ref_pt in ref:
		other = closest(ref_pt, moving_points)
		points_pairs.append((ref_pt, other))
		
	acc = [0.0 for _ in range(len(moving_points[0]))]
	
	for fixed, moving in points_pairs:
		for i in range(len(fixed)):
			acc[i] += fixed[i] - moving[i]
			
	for i in range(len(acc)):
		acc[i] /= len(acc)
	
	return acc
	
	
def write_as_json(folder, machine, shifts):
	output_path = os.path.join(folder, machine + ".json")
	with open(output_path, 'w') as fp:
		json.dump(shifts, fp, indent=2)
	

def main():
	img = IJ.getImage()
	
	nc = img.getNChannels()
	if nc < 2:
		print("At least two channels are required")
		return
		
	nz = img.getNSlices()
	if (nz > 1):
		tmp = ZProjector.run(img, "max")
		img.close()
		img = tmp
		
	settings = ask_settings(nc)
	ref = extract_ref_points(img, 0, settings['n_beads'])
	if ref is None:
		print("Failed to find beads")
		return
	
	shifts = {
		"microscope": settings['microscope'],
		"objective": settings['objective'],
		"shifts": {}
	}
	
	for ch_idx in range(nc):
		shift = estimate_shift(img, settings['channels'], ch_idx, ref)
		if shift is None:
			print("Failed to find ref points for: " + settings['channels'][ch_idx])
			return
		ch_name = settings['channels'][ch_idx]
		shifts['shifts'][ch_name] = shift
	
	write_as_json(
		settings["output"], 
		settings['microscope'] + " (" + settings['objective'] + ")", 
		shifts
	)
	
main()
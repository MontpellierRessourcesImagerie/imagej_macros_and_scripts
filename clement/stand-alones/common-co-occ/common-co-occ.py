import tifffile as tiff
import numpy as np
import itertools
import os
from scipy.ndimage import label, distance_transform_edt
from skimage.segmentation import watershed
from skimage.measure import regionprops
import pandas as pd
import tkinter as tk
from tkinter import filedialog
from termcolor import cprint

def get_combinations(N):
	results = []
	for k in range(1, N+1):
		results.extend(itertools.combinations(range(N), k))
	return results

def as_key(target, positivity):
	k = "C" + str(target+1)
	if len(positivity) == 0:
		return k
	k += ("-" + "".join([str(i+1) for i in sorted(list(positivity))]))
	return k

def get_permutations(n_channels):
	combinations = get_combinations(n_channels)
	permutations = []
	for combi in combinations:
		for tgt_channel in combi:
			positivity = set(combi).difference([tgt_channel])
			key = as_key(tgt_channel, positivity)
			permutations.append((key, tgt_channel, positivity))
	return sorted(permutations)

def get_images_pool(input_dir):
	content = os.listdir(input_dir)
	n_channels = -1
	found = []
	for item in content:
		im_path = os.path.join(input_dir, item)
		if not os.path.isdir(im_path):
			continue
		channels = sorted([i for i in os.listdir(im_path) if i.endswith(".tif")])
		if n_channels == -1:
			n_channels = len(channels)
		elif len(channels) == n_channels:
			found.append(item)
	return n_channels, found

def sanity_check(im_dir):
	content = sorted(os.listdir(im_dir))
	for i in range(1, len(content)+1):
		tgt_path = os.path.join(im_dir, "c"+str(i)+".tif")
		if not os.path.isfile(tgt_path):
			return False
	return True

def load_image(im_dir, n_channels):
	data = []
	for i in range(1, n_channels+1):
		full_path = os.path.join(im_dir, "c"+str(i)+".tif")
		print("  Loading " + full_path)
		img = tiff.imread(full_path)
		data.append(img)
	return data

def build_positivity_mask(ch_data, sides):
	basis = np.ones_like(ch_data[0])
	for ch_index in sides:
		basis *= (ch_data[ch_index] > 0).astype(np.uint8)
	return basis

def remove_labels(image, labels_to_remove, fill_value=0):
    mask = np.isin(image, labels_to_remove)
    result = image.copy()
    result[mask] = fill_value
    tiff.imwrite("/tmp/mask.tif", mask)
    return result

def _get_labeling(mask, im_dir, rank, sphericity=(0.6, 1.3), euler=(1, 5), volume=(80, 1500)):
	labeled = distance_transform_edt(mask)
	labeled /= np.max(labeled)
	labeled = 1.0 - labeled
	labeled = watershed(labeled, mask=ch_data[target], watershed_line=True).astype(np.uint16)
	all_props = regionprops(labeled)
	to_be_removed = []
	total = len(all_props)
	counter = [0, 0, 0, 0]

	for props in all_props:
		if props['euler_number'] < euler[0] or props['euler_number'] > euler[1]:
			to_be_removed.append(props['label'])
			counter[0] += 1
			continue
		if props['num_pixels'] < volume[0] or props['num_pixels'] > volume[1]:
			to_be_removed.append(props['label'])
			counter[1] += 1
			continue
		if props['axis_major_length'] < 1e-3 or props['axis_minor_length'] < 1e-3:
			to_be_removed.append(props['label'])
			counter[2] += 1
			continue
		r = props['axis_minor_length'] / props['axis_major_length']
		if r < sphericity[0] or r > sphericity[1]:
			to_be_removed.append(props['label'])
			counter[3] += 1

	print(f"  Passed from {total} to {total-len(to_be_removed)} objects in C{rank+1} ({counter})")
	to_be_removed = np.array([int(i) for i in to_be_removed])
	to_be_removed = to_be_removed.astype(np.uint16)
	
	labeled = remove_labels(
		labeled, 
		to_be_removed
	)
	tiff.imwrite(os.path.join(im_dir, f"C{rank+1}-lbl.tif"), labeled)
	return labeled

def get_labeling(mask, im_dir, rank):
	labeled, _ = label(mask)
	tiff.imwrite(os.path.join(im_dir, f"C{rank+1}-lbl.tif"), labeled)
	return labeled

def count_positives(spots, positivity_mask):
	all_props = regionprops(spots, positivity_mask)
	counter = 0
	for props in all_props:
		if props['intensity_max'] > 0:
			counter += 1
	return counter

def make_ratios(results):
	normalized = {r: c.copy() for r, c in results.items()}
	for image, counts in results.items():
		for combination, count in counts.items():
			if count == 0:
				continue
			ref = combination.split('-')[0]
			denom = counts[ref]
			if denom == 0:
				continue
			normalized[image][combination] = round(count / denom, 3)
	return normalized

def dict_to_csv(data_dict, csv_path):
    rows = []
    for source, props in data_dict.items():
        row = {'source': source}
        row.update(props)
        rows.append(row)

    df = pd.DataFrame(rows)

    cols = ['source'] + [c for c in df.columns if c != 'source']
    df = df[cols]

    df.to_csv(csv_path, index=False)
    return df

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

def run(input_dir):
	n_channels, im_pool = get_images_pool(input_dir)
	permutations = get_permutations(n_channels)
	results = {}

	for img_name in im_pool:
		im_dir = os.path.join(input_dir, img_name)
		if not sanity_check(im_dir):
			continue
		cprint("Working on: " + img_name, color='green', attrs=['bold'])

		ch_data = load_image(im_dir, n_channels)
		results[img_name] = {}
		labeled_targets = {}

		for key, target, sides in permutations:
			positivity_mask = build_positivity_mask(ch_data, sides)
			if target in labeled_targets:
				labeled = labeled_targets[target]
			else:
				labeled = get_labeling(ch_data[target], im_dir, target)
				labeled_targets[target] = labeled
			results[img_name][key] = count_positives(labeled, positivity_mask)

	dict_to_csv(results, os.path.join(input_dir, "results.csv"))
	cprint("DONE!", color='green', attrs=['bold'])

def run_on_folder():
	folder_selected = filedialog.askdirectory()
	if folder_selected:
		root.destroy()
		run(folder_selected)

if __name__ == "__main__":
	root = tk.Tk()
	root.title("Select Folder")
	root.geometry("300x100")

	# Add a button
	btn = tk.Button(root, text="Choose Folder", command=run_on_folder)
	btn.pack(expand=True)

	# Start the GUI event loop
	root.mainloop()
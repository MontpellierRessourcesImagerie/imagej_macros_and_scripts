import json
import csv
import os

images_folder = "/media/clement/5B0AAEC37149070F/debug-celia/CC399-240725-dNC+-PURO/NEW JOINT DECONVOLUTION"
extension     = ".czi"

# SETTINGS
json_path  = os.path.join(images_folder, "spots", "results.json")
csv_folder = os.path.join(images_folder, "labeled-stacks")
output_csv = os.path.join(images_folder, 'merged_output.csv')

# LOAD JSON
with open(json_path) as f:
    data = json.load(f)

# Guess dyes (assuming all entries have same keys)
first_entry = next(iter(data.values()))
dye_names = [k for k in first_entry.keys() if not k.startswith('#')]
coocc_name = [k for k in first_entry.keys() if '#' in k][0]

print("Detected dyes:", dye_names)
print("Detected co-occ field:", coocc_name)

# OPEN OUTPUT
with open(output_csv, 'w', newline='') as out_f:
    writer = csv.writer(out_f)
    # HEADER
    writer.writerow(['Source', 'Volume', 'Cell ID', dye_names[0], dye_names[1], '#co-occs'])

    # PROCESS EACH SOURCE
    for source_name, channels in data.items():
        csv_file = os.path.join(csv_folder, source_name.replace(extension, '.csv'))
        if not os.path.exists(csv_file):
            print(f"WARNING: CSV for {source_name} not found. Skipping.")
            continue

        # LOAD VOLUMES
        id_to_volume = {}
        with open(csv_file, 'r') as csv_f:
            reader = csv.reader(csv_f)
            header = next(reader)
            for row in reader:
                cid, vol = row
                id_to_volume[cid.strip()] = vol.strip()

        # MERGE BY CELL ID
        all_ids = set(channels[dye_names[0]].keys())
        for cid in sorted(all_ids, key=int):
            volume = id_to_volume.get(cid, '')
            dye1_val = channels[dye_names[0]].get(cid, '')
            dye2_val = channels[dye_names[1]].get(cid, '')
            coocc_val = channels[coocc_name].get(cid, '')

            writer.writerow([source_name, volume, cid, dye1_val, dye2_val, coocc_val])

print("✅ Merging done. Output saved to", output_csv)

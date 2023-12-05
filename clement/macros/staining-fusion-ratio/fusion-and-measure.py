import os, re
from ij import IJ, ImagePlus

###########################  SETTINGS  ###########################

source_directory = "/home/benedetti/Documents/projects/16-masks-combination/2023_09_25_10_16_37--CD31 Lyve1 a-SMA"
destination_directory = ""
reference_channel = 1
interest_channels = [1, 3]
expectedNChannels = 4

##################################################################

def acquire_settings():
    pass


def probe_sources():
    files = [f for f in os.listdir(source_directory) if os.path.isfile(os.path.join(source_directory, f))]
    families = {}
    for f in files:
        bare_name = re.sub(r'\d', '_', f)
        families.setdefault(bare_name, []).append(f)
    clean_families = {key: sorted(item) for key, item in families.items() if len(item) == expectedNChannels}
    return clean_families


def create_masks(family):
    pass


def main():
    families = probe_sources()
    for family in families:
        masks = create_masks(family)

main()
import os
import sys
from pprint import pprint
import json
import string
import numpy as np


settings = {
    'JSONs': [],
    'output': "./aggregate.csv",
    'stat': 'med'
}


def setState(arg):
    if arg == "-json":
        return 'JSON'
    elif arg == "-output":
        return 'OUT'
    elif arg == "-stat":
        return 'STAT'
    else:
        return None


def actionJSON(arg):
    arg = arg.replace("\"", "").replace("'", "")
    if arg.endswith(".json") and os.path.isfile(os.path.abspath(arg)):
        settings['JSONs'].append(arg)


def actionOUT(arg):
    arg = arg.replace("\"", "").replace("'", "")
    if arg.endswith(".csv"):
        settings['output'] = arg


def actionSTAT(arg):
    arg = arg.replace("\"", "").replace("'", "")
    if arg in ['min', 'max', 'Q1', 'med', 'Q3', 'avg', 'area']:
        settings['stat'] = arg


def parseArguments(argv):
    state = ""
    for arg in argv:
        if arg.startswith("-"):
            state = setState(arg)
        else:
            if state == 'JSON':
                actionJSON(arg)
            elif state == 'OUT':
                actionOUT(arg)
            elif state == 'STAT':
                actionSTAT(arg)


def main():
    if len(sys.argv) <= 1:
        print("Usage: ")
        print("python3 ./aggregateJSON.py -json some/path/firstJson.json some/other/second.json -output path/of/output.csv -stat Q1")
        print("    -json: Add as many JSON as you want after this tag.")
        print("    -output: Path (name included) of the CSV that will be produced.")
        print("    -stat: The stat to extract for each cell (one of: min, max, Q1, med, Q3, avg, area).")
        return 0
    
    parseArguments(sys.argv)
    pprint(settings)

    alphabet = list(string.ascii_uppercase) + list(string.ascii_lowercase)

    extraction = []

    for jsonPath, serie in zip(settings['JSONs'], alphabet):
        with open(jsonPath, 'r') as f:
            stats = json.loads(f.read())

        for lbl, frames in stats.items():
            current = []
            current.append(f"{serie}_{lbl}")
            for frame in frames:
                current.append(frame[settings['stat']])
            extraction.append(current)

    extraction = np.array(extraction).T.tolist()
    
    with open(settings['output'], 'w') as f:
        for l in extraction:
            line = ", ".join([str(i) for i in l]) + '\n'
            f.write(line)

    return 0


main()
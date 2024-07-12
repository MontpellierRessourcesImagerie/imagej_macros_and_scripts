import os
import sys
from pprint import pprint
import json
import string
import numpy as np

# Check documentation: rule94.com > Seg'N'Track > Aggregate JSONs

## @brief Settings used aggregate JSONs
settings = {
    'directory': None, # If used, allows to aggregate all the JSONs contained in a folder (skip the 'JSONs' key if set).
    'JSONs': [], # List of absolute paths to an arbitrary number of JSONs files.
    'output': "./aggregate.csv", # Where the output will be generated.
    'stat': 'med' # Unique statistic to extract from all the JSONs (one of: min, max, Q1, med, Q3, avg, area).
}

## @brief Changes the state of the state-machine used to parse the command line.
def setState(arg):
    if arg == "-jsons":
        return 'JSON'
    elif arg == "-output":
        return 'OUT'
    elif arg == "-stat":
        return 'STAT'
    elif arg == "-dir":
        return 'DIRECTORY'
    else:
        return None

## @brief Action to perform when the command line state machine is set to read JSONs paths
def actionJSON(arg):
    arg = arg.replace("\"", "").replace("'", "")
    if arg.endswith(".json") and os.path.isfile(os.path.abspath(arg)):
        settings['JSONs'].append(arg)

## @brief Action to perform when the command line state machine is set to read a directory path.
def actionDIRECTORY(arg):
    if os.path.isdir(arg):
        settings['directory'] = arg

## @brief Action to perform when the command line state machine is set to read an output path.
def actionOUT(arg):
    arg = arg.replace("\"", "").replace("'", "")
    if arg.endswith(".csv"):
        settings['output'] = arg

## @brief Action to perform when the command line state machine is set to read which statistic the user is interested in.
def actionSTAT(arg):
    arg = arg.replace("\"", "").replace("'", "")
    if arg in ['min', 'max', 'Q1', 'med', 'Q3', 'avg', 'area']:
        settings['stat'] = arg

## @brief Function triggering the correct action depending on the current state of the state machine.
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
            elif state == 'DIRECTORY':
                actionDIRECTORY(arg)

## @brief Function fetching all the JSONs present in a folder if the corresponding option is being used.
def expandArguments():
    if settings['directory'] is None:
        return
    
    settings['JSONs'] = [os.path.join(settings['directory'], c) for c in sorted(os.listdir(settings['directory'])) if c.endswith('.json')]


def main():
    if (len(settings['JSONs']) == 0) and (settings['directory'] is None) and (len(sys.argv) <= 1):
        print("Usage: ")
        print("python3 ./aggregateJSON.py -jsons some/path/firstJson.json some/other/second.json -output path/of/output.csv -stat Q1")
        print("    -jsons:  Add as many JSON as you want after this tag.")
        print("    -output: Path (name included) of the CSV that will be produced.")
        print("    -stat:   The stat to extract for each cell (one of: min, max, Q1, med, Q3, avg, area).")
        print("    -dir:    Can't be used if \"-jsons\" is set. Aggregates all JSON files present in the provided directory.")
        return 0
    
    else:
        if len(sys.argv) > 1:
            parseArguments(sys.argv)

        expandArguments()
        pprint(settings)

        extraction = []

        for serieIndex, jsonPath in enumerate(settings['JSONs']):
            with open(jsonPath, 'r') as f:
                stats = json.loads(f.read())

            for lbl, frames in stats.items():
                current = []
                current.append(f"{str(serieIndex+1).zfill(4)}_{lbl}")
                for frame in frames:
                    current.append(frame[settings['stat']])
                extraction.append(current)

        extraction = np.array(extraction).T.tolist()
        
        with open(settings['output'], 'w') as f:
            for l in extraction:
                line = ",".join([str(i) for i in l]) + '\n'
                f.write(line)

        return 0


main()
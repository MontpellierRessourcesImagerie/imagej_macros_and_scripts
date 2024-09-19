import tkinter as tk
from tkinter import filedialog
import json
from urllib.parse import unquote
from urllib.parse import quote
import os


root = tk.Tk()
root.withdraw()

# file_path = filedialog.askopenfilename()
# images_path = filedialog.askdirectory()

file_path = "/home/baecker/Documents/mri/in/2007-horizontal-growth-of-trees/qPathborders3/QuPath borders20240913/project.qpproj"
images_path = "/home/baecker/Documents/mri/in/2007-horizontal-growth-of-trees/2"
with open(file_path) as json_file:
    data = json.load(json_file)

for image in data['images']:
    uri = image['serverBuilder']['builder']['uri']
    uri = unquote(uri)
    file = os.path.basename(uri)
    newURI = os.path.join(images_path, file)
    if not os.path.exists(newURI):
        print("image " + newURI + " not found")
    newURI = quote(newURI)
    randName = image['randomizedName']
    image['serverBuilder']['builder']['uri'] = newURI
    image['randomizedName'] = randName
folder = os.path.dirname(file_path)
parts =  os.path.splitext(os.path.basename(file_path))
newfile = parts[0] + "-update" + parts[1]
newPath = os.path.join(folder, newfile)
with open(newPath, 'w') as f:
    json.dump(data, f)
print("Finished replacing paths")


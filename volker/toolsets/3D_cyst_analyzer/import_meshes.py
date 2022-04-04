import tkinter as tk
import os
from tkinter.filedialog import askdirectory
import pymeshlab
import numpy as np

root = tk.Tk()
root.withdraw()
path = askdirectory(title='Select Folder')
dirs = [os.path.join(path, folder) for folder in os.listdir(path) if os.path.isdir(os.path.join(path, folder))]
dirs.sort()

ms = pymeshlab.MeshSet()
for folder in dirs:
    file = os.path.join(folder, 'T_1.ply')
    ms.load_new_mesh(file)


for i in range(0, len(ms)):
    m = ms[i]
    v_matrix = m.vertex_matrix()
    f_matrix = m.face_matrix()
    viewer.add_surface((v_matrix, f_matrix, np.linspace(1, 1, len(v_matrix))), name='cell '+str(i+1))

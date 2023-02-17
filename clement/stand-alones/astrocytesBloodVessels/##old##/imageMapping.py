
# resolution: (width,  height)
def generateMappingForImage(mesh, resolution):
    """Associates each vertex of a mesh to some pixel coordinates in an image of the specified resolution."""

    vertices = mesh.vertex_matrix()
    mapping  = np.zeros((len(vertices), 2))

    for i, v in enumerate(vertices):
        rho   = np.linalg.norm(v)
        theta = np.arccos(v[2] / rho) # [0, pi]
        phi   = np.arctan2(v[1], v[0]) # ]-pi, pi]

        column = int((theta / np.pi) * resolution[0])
        line   = int(((phi + np.pi) / (2 * np.pi)) * resolution[1])

        mapping[i] = (column, line)
    
    return mapping
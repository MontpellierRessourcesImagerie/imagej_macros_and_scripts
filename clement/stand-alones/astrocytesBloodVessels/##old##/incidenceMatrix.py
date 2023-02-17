
def sumOfFirstIntegers(n):
    return int((n * (n+1))/2)


def fillCell(face, table):
    pairs = [(0, 1), (0, 2), (1, 2)]
    for i1, i2 in pairs:
        p1 = face[i1]
        p2 = face[i2]

        major = sumOfFirstIntegers(max(p1, p2))
        minor = min(p1, p2)
        table[major + minor] = 1
        

class IncidenceMatrix(object):

    def internalDataLength(self):
        return sumOfFirstIntegers(len(self.points))


    def __init__(self, pts, fcs):
        self.points        = pts
        self.faces         = fcs
        # - - - - - - - - - - - -
        self.connection    = None
        self.participation = None
        self.e0            = None
        self.e1            = None

        self.buildDataStructures()


    def buildDataStructures(self):

        self.connection = np.zeros(self.internalDataLength(), dtype=np.uint8)
        self.fillTable(1)

        self.participation = [[] for i in range(len(self.points))]
        self.buildParticipation()

        self.e0 = np.zeros((self.getNumberOfEdges(), len(self.points)), dtype=np.uint8)
        self.fillE0()

        self.e1 = np.zeros((len(self.faces), self.getNumberOfEdges()), dtype=np.uint8)
        self.fillE1()

        print("Initialization done.")

    
    def fillTable(self, nbThreads):
        print("Processing raw incidence map...")
        for face in self.faces:
            fillCell(face, self.connection)
    

    def buildParticipation(self):
        print("Processing participation map...")
        for idxFace, face in enumerate(self.faces):
            for vertex in face:
                self.participation[vertex].append(idxFace)
    

    def fillE1(self):
        print("Processing E1...")
        nn = np.nonzero(self.e0)
        d = defaultdict(list)

        edgesIdcs = nn[0]
        vrtcsIdcs = nn[1]

        for i in range(0, len(edgesIdcs), 2):
            t = (edgesIdcs[i], vrtcsIdcs[i], vrtcsIdcs[i+1])
            d[vrtcsIdcs[i]].append(t)
            d[vrtcsIdcs[i+1]].append(t)

        # d[vertex index]  =>  (edge index, v1 index, v2 index)

        for faceIdx, face in enumerate(self.faces):
            for vertex in face:
                for idx, v1, v2 in d[vertex]:
                    if (v1 in face) and (v2 in face):
                        self.e1[faceIdx, idx] = 1
    

    def fillE0(self):
        print("Processing E0...")
        current = 0 # Increments for each edge
        for row in range(len(self.points)):
            for column in range(row):
                if self.get(row, column) == 1:
                    self.e0[current, row] = 1
                    self.e0[current, column] = 1
                    current += 1


    # Only individual edges are counted. (3, 8) and (8, 3) count only as one edge.
    def getNumberOfEdges(self):
        return np.count_nonzero(self.connection)

    
    def get(self, row, column):
        if column > row:
            row, column = column, row
        return self.connection[sumOfFirstIntegers(row) + column]

    
    def set(self, row, column, val):
        if column > row:
            row, column = column, row
        self.connection[sumOfFirstIntegers(row) + column] = val
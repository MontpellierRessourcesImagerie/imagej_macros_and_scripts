import matplotlib.pyplot as plt
import math

def distance(p1, p2):
    return math.sqrt(pow(p1[0] - p2[0], 2) + pow(p1[1] - p2[1], 2))


def derivateCurve(curve):
    return [p2-p1 for p1, p2 in zip(curve, curve[1:]+[curve[-1]])]


def sameSign(a, b):
    return a*b >= 0.0

def variations(der):

    # Dérivée négative => Fonction décroissante
    # Dérivée positive => Fonction croissante
    # Negatif -> positif => Minimum
    # Positif -> negatif => Maximum

    variations = {
        'maximums': [],
        'minimums': []
    }

    for i in range(0, len(der)-1):
        if der[i] < 0 and der[i+1] > 0:
            variations['minimums'].append(i+1)
        
        if der[i] > 0 and der[i+1] < 0:
            variations['maximums'].append(i+1)
    
    return variations


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


data = {
    'points': [(38, 36), (42, 31), (48, 28), (54, 27), (61, 27), (67, 29), (71, 31), (75, 35), (76, 27), (80, 24), (87, 21), (94, 21), (99, 24), (103, 29), (104, 35), (103, 42), (100, 46), (95, 50), (88, 51), (83, 49), (81, 47), (78, 55), (76, 61), (72, 66), (68, 69), (62, 71), (55, 72), (48, 70), (42, 67), (37, 63), (35, 56), (33, 51), (34, 43), (36, 38)],
    'ang1': 7,
    'ang2': 20
}

def rotateData(size):
    global data
    
    return {
        'points': data['points'][-size:] + data['points'][:-size],
        'ang1': (data['ang1'] + size) % len(data['points']),
        'ang2': (data['ang2'] + size) % len(data['points'])
    }

minDistance = 99999 # Remplacer par la taille de la diagonale de l'image.
couple = (None, None)
itert = -1
collec = None

for i in range(len(data['points'])):
    rd = rotateData(i) # 34 = tour complet

    dst = [distance(rd['points'][0], p) for p in rd['points']]
    der = derivateCurve(dst)
    vrs = variations(der)

    plt.plot(dst, color='blue')
    plt.plot(der, color='orange')

    for m in vrs['minimums']:
        plt.axvline(x=m, color='yellow')
        if (len(vrs['minimums']) == 1) and (dst[m] < minDistance):
            minDistance = dst[m]
            # couple = (i, m-i)
            couple = (0, m)
            itert = i
            collec = rd['points'].copy()
    
    for m in vrs['maximums']:
        plt.axvline(x=m, color='purple')

    # plt.axvline(x=rd['ang1'], color='green')
    # plt.axvline(x=rd['ang2'], color='red')
    plt.axhline(y=0, color='black')

    plt.savefig(f"/home/benedetti/Bureau/distplot/plot_dist_{str(i).zfill(2)}.png")
    plt.clf()
    plt.close()

print("Min: ", minDistance)
print("Couple: ", couple)
print("Iter: ", itert)
print("Collec: ", collec)

# La courbe originale représente la distance d'un point à chaque autre en s'incluant dans le loop (en position 0).
# Quand p0 est proche du point anguleux, deux minimums peuvent apparaitre à chause du symétrique de p0 par le point anguleux.
# -> On utilise donc pas les séquences qui contiennent plusieurs minimums.

# Repartir sur un shrinking contour.
# Les points ne seront placés ni sur une ellipse ni sur les coins du rectangle, mais en utilisant un point à 99% de la distance du centroid.
# Le centroid sera le centre de tous les pixels blancs résultants de la segmentation primaire.
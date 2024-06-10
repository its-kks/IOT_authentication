from sklearn.neighbors import NearestNeighbors
import numpy as np

# Example data
X = np.array([[0, 0], [1, 1], [2, 2]])

# Initialize NearestNeighbors object without specifying radius
neigh = NearestNeighbors(n_neighbors=4, algorithm='kd_tree')

# Fit the data
neigh.fit(X)

# Find the nearest neighbors for each point
distances, indices = neigh.kneighbors(X)

print("Indices of nearest neighbors:", indices)
print("Distances to nearest neighbors:", distances)

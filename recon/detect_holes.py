import json, numpy as np, open3d as o3d
from pathlib import Path
poses = json.loads(Path("data/maison/processed/transforms.json").read_text())
cams = [np.array(f["transform_matrix"]) for f in poses["frames"]]
pcd = o3d.io.read_point_cloud("exports/pcd/point_cloud.ply")
points = np.asarray(pcd.points)
voxel_size = 0.10
vg = o3d.geometry.VoxelGrid.create_from_point_cloud(pcd, voxel_size=voxel_size)
from collections import defaultdict
minb = vg.get_min_bound(); density = defaultdict(int); seen = defaultdict(int)
for p in points:
    vidx = tuple(((p - minb)/voxel_size).astype(int)); density[vidx]+=1
sampled = points[np.random.choice(points.shape[0], min(30000, points.shape[0]), replace=False)]
for _ in cams:
    for p in sampled:
        vidx = tuple(((p - minb)/voxel_size).astype(int)); seen[vidx]+=1
S_min, D_min = 3, 5
pts, cols = [], []
for vox in vg.get_voxels():
    vidx = tuple(vox.grid_index)
    hole = (seen.get(vidx,0) < S_min) or (density.get(vidx,0) < D_min)
    c = [1,0,0] if hole else [0.6,0.6,0.6]
    pts.append(vg.get_voxel_center_coordinate(vox.grid_index)); cols.append(c)
pc = o3d.geometry.PointCloud(o3d.utility.Vector3dVector(np.array(pts)))
pc.colors = o3d.utility.Vector3dVector(np.array(cols))
o3d.io.write_point_cloud("exports/coverage_holes.ply", pc)
print("Export -> exports/coverage_holes.ply")

# house3d (V1 MVP)
- App Android (MapLibre par défaut, ARCore, OpenCV)
- Scripts Nerfstudio/COLMAP + détection des trous
- Viewer Web minimal
- GitHub Actions → APK auto

## CI
À chaque push sur `main`, GitHub Actions build les APK (maplibre + gmaps).

## Reconstruction
./recon/build_initial.sh data/maison/images data/maison/processed
python3 recon/detect_holes.py

# house3d (V1 MVP)

- App Android (MapLibre par défaut, ARCore, OpenCV 4.9)
- Scripts reconstruction (Nerfstudio/COLMAP) + détection des trous
- Viewer Web (static)
- CI GitHub Actions : build APK + déploiement GitHub Pages (auto)

## Android CI
L’APK est construit à chaque *push* (Java 17 via actions/setup-java).  
Voir onglet **Actions**.

## Viewer Web
Déployé automatiquement sur **GitHub Pages** depuis `viewer/web/`.  
URL : https://cheynier.github.io/house3d/ (après le premier push).
# house3d
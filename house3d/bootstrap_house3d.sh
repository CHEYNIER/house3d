# Ajout message de fin
echo "✅ Squelette house3d généré."
#!/usr/bin/env bash
set -e

# Racine
mkdir -p house3d
cd house3d

cat > .gitignore <<'EOF'
.gradle/
**/build/
local.properties
.cxx/
captures/
.externalNativeBuild/
.DS_Store
.idea/
*.iml
node_modules/
dist/
EOF

cat > LICENSE <<'EOF'
Apache License 2.0
Copyright (c) 2025
http://www.apache.org/licenses/LICENSE-2.0
EOF

cat > README.md <<'EOF'
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
EOF

# -------- Android app --------
mkdir -p capture-mobile/android-app
cd capture-mobile/android-app

cat > settings.gradle <<'EOF'
pluginManagement { repositories { gradlePluginPortal(); google(); mavenCentral() } }
dependencyResolutionManagement {
  repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
  repositories { google(); mavenCentral() }
}
rootProject.name = "android-app"
include(":app")
EOF

cat > build.gradle <<'EOF'
plugins {
  id 'com.android.application' version '8.4.2' apply false
  id 'org.jetbrains.kotlin.android' version '1.9.24' apply false
}
EOF

mkdir -p app/src/main/java/com/house3d
mkdir -p app/src/main/res/layout

cat > app/build.gradle <<'EOF'
plugins { id 'com.android.application'; id 'org.jetbrains.kotlin.android' }

android {
  namespace 'com.house3d'
  compileSdk 34
  defaultConfig { applicationId "com.house3d"; minSdk 24; targetSdk 34; versionCode 1; versionName "0.1.0" }
  buildTypes {
    release { minifyEnabled false; proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro' }
    debug { }
  }
  flavorDimensions "maps"
  productFlavors {
    maplibre { dimension "maps"; applicationIdSuffix ".oss"; resValue "string", "maps_provider", "maplibre" }
    gmaps    { dimension "maps"; applicationIdSuffix ".gmaps"; resValue "string", "maps_provider", "gmaps" }
  }
  buildFeatures { viewBinding true }
  compileOptions { sourceCompatibility JavaVersion.VERSION_17; targetCompatibility JavaVersion.VERSION_17 }
  kotlinOptions { jvmTarget = '17' }
}
repositories { google(); mavenCentral() }
dependencies {
  implementation 'com.google.ar:core:1.45.0'         // ARCore (pose/plan) — guidage  
  implementation 'org.opencv:opencv:4.9.0'           // OpenCV 4.9 via Maven Central  
  implementation "androidx.camera:camera-core:1.3.4"
  implementation "androidx.camera:camera-camera2:1.3.4"
  implementation "androidx.camera:camera-lifecycle:1.3.4"
  implementation "androidx.camera:camera-view:1.3.4"
  maplibreImplementation 'org.maplibre.gl:android-sdk:11.8.0'  // MapLibre Quickstart   
  gmapsImplementation    'com.google.android.gms:play-services-maps:18.2.0'  // Google Maps (option) 
}
EOF

cat > app/proguard-rules.pro <<'EOF'
# (vide)
EOF

cat > app/src/main/AndroidManifest.xml <<'EOF'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <uses-permission android:name="android.permission.CAMERA"/>
  <uses-permission android:name="android.permission.INTERNET"/>
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
  <application android:label="House3D" android:allowBackup="true" android:supportsRtl="true">
    <activity android:name="com.house3d.MapActivity" android:exported="true">
      <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
      </intent-filter>
    </activity>
  </application>
</manifest>
EOF

cat > app/src/main/res/layout/activity_map.xml <<'EOF'
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:maplibre="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent" android:layout_height="match_parent">

    <org.maplibre.android.maps.MapView
        android:id="@+id/mapView"
        android:layout_width="match_parent" android:layout_height="match_parent"
        maplibre:maplibre_uiAttribution="true"
        maplibre:maplibre_uiLogo="true" />

    <TextView
        android:id="@+id/guidanceBanner"
        android:layout_width="match_parent" android:layout_height="wrap_content"
        android:layout_gravity="top" android:padding="12dp"
        android:background="#CC000000" android:textColor="#FFFFFF"
        android:text="Va au marqueur, garde ~3 m et tourne 10°"/>

    <Button
        android:id="@+id/btnCapture"
        android:layout_width="wrap_content" android:layout_height="wrap_content"
        android:layout_gravity="bottom|center_horizontal" android:layout_margin="16dp"
        android:text="Valider la photo"/>
</FrameLayout>
EOF

cat > app/src/main/java/com/house3d/MapActivity.kt <<'EOF'
package com.house3d

import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import org.maplibre.android.MapLibre
import org.maplibre.android.camera.CameraPosition
import org.maplibre.android.geometry.LatLng
import org.maplibre.android.maps.MapView
import org.maplibre.android.maps.Style

class MapActivity: AppCompatActivity() {
    private lateinit var mapView: MapView
    private lateinit var banner: TextView
    private lateinit var btnCapture: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        MapLibre.getInstance(this)
        setContentView(R.layout.activity_map)

        mapView = findViewById(R.id.mapView)
        banner  = findViewById(R.id.guidanceBanner)
        btnCapture = findViewById(R.id.btnCapture)

        mapView.onCreate(savedInstanceState)
        mapView.getMapAsync { map ->
            map.setStyle(Style.Builder().fromUri("https://demotiles.maplibre.org/style.json")) {
                map.cameraPosition = CameraPosition.Builder()
                    .target(LatLng(45.1234, 5.1234)).zoom(18.5).build()
                banner.text = "Va au marqueur, garde ~3 m et tourne 10°"
            }
        }

        btnCapture.setOnClickListener {
            // TODO: brancher GuidanceArCore + BlurUtils
            banner.text = "Capture validée (démo)."
        }
    }

    override fun onStart() { super.onStart(); mapView.onStart() }
    override fun onResume() { super.onResume(); mapView.onResume() }
    override fun onPause() { mapView.onPause(); super.onPause() }
    override fun onStop() { mapView.onStop(); super.onStop() }
    override fun onLowMemory() { super.onLowMemory(); mapView.onLowMemory() }
    override fun onDestroy() { mapView.onDestroy(); super.onDestroy() }
    override fun onSaveInstanceState(outState: Bundle) { super.onSaveInstanceState(outState); mapView.onSaveInstanceState(outState) }
}
EOF

cat > app/src/main/java/com/house3d/GuidanceArCore.kt <<'EOF'
package com.house3d
import com.google.ar.core.Frame
object GuidanceArCore {
    data class Advice(val message: String, val ok: Boolean)
    fun evaluate(frame: Frame?, targetLat: Double, targetLng: Double): Advice {
        // TODO: calcul d'angle/distance en réel via la pose ARCore
        return Advice("Avance 1.2 m et tourne 8° à droite", ok = false)
    }
}
EOF

cat > app/src/main/java/com/house3d/BlurUtils.kt <<'EOF'
package com.house3d
import org.opencv.core.CvType
import org.opencv.core.Mat
import org.opencv.core.MatOfDouble
import org.opencv.imgproc.Imgproc
import org.opencv.core.Core
object BlurUtils {
    fun isBlurry(bgr: Mat, threshold: Double = 100.0): Boolean {
        val gray = Mat()
        Imgproc.cvtColor(bgr, gray, Imgproc.COLOR_BGR2GRAY)
        val lap = Mat()
        Imgproc.Laplacian(gray, lap, CvType.CV_64F)
        val mu = MatOfDouble()
        val sigma = MatOfDouble()
        Core.meanStdDev(lap, mu, sigma)
        val variance = sigma.get(0,0)[0] * sigma.get(0,0)[0]
        return variance < threshold
    }
}
EOF

cd ../../..

# -------- Recon scripts --------
mkdir -p recon
cat > recon/build_initial.sh <<'EOF'
#!/usr/bin/env bash
set -e
DATA="$1"; OUT="$2"
if [ -z "$DATA" ] || [ -z "$OUT" ]; then
  echo "Usage: $0 <data_images_dir> <output_processed_dir>"; exit 1
fi
ns-process-data images --data "$DATA" --output-dir "$OUT"
ns-train splatfacto --data "$OUT"
EOF
chmod +x recon/build_initial.sh

cat > recon/resume_update.sh <<'EOF'
#!/usr/bin/env bash
set -e
OUT="$1"; CKPT="$2"
if [ -z "$OUT" ] || [ -z "$CKPT" ]; then
  echo "Usage: $0 <processed_dir> <checkpoint_dir>"; exit 1
fi
ns-train splatfacto --data "$OUT" --load-dir "$CKPT"
EOF
chmod +x recon/resume_update.sh

cat > recon/detect_holes.py <<'EOF'
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
EOF

# -------- Viewer web --------
mkdir -p viewer/web
cat > viewer/web/index.html <<'EOF'
<!doctype html>
<html lang="fr"><head>
<meta charset="utf-8"/><title>House3D Viewer (V1)</title>
<style>html,body,#app{height:100%;margin:0} #panel{position:absolute;top:8px;left:8px;background:#0008;color:#fff;padding:8px;border-radius:6px}</style>
</head><body>
<div id="app"></div>
<div id="panel"><h3>House3D Viewer</h3><p>Chargez votre <code>.splat</code> et <code>coverage_holes.ply</code>.</p></div>
</body></html>
EOF

# -------- GitHub Actions (APK) --------
mkdir -p .github/workflows
cat > .github/workflows/android.yml <<'EOF'
name: Android CI
on:
  push: { branches: [ main ] }
  pull_request:
  workflow_dispatch:
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with: { distribution: 'temurin', java-version: '17' }   # AGP récent => Java 17  
      - name: Setup Gradle
        uses: gradle/actions/setup-gradle@v3
      - name: Build APKs (maplibre + gmaps)
        working-directory: capture-mobile/android-app
        run: |
          chmod +x ./gradlew || true
          ./gradlew assembleMaplibreDebug assembleGmapsDebug
      - name: Upload APKs
        uses: actions/upload-artifact@v4
        with: { name: APKs, path: capture-mobile/android-app/app/build/outputs/apk/**/**.apk }
EOF


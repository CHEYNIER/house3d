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
            // TODO: brancher GuidanceArCore + BlurUtils sur la capture réelle
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

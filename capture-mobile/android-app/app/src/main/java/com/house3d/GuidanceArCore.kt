package com.house3d
import com.google.ar.core.Frame
object GuidanceArCore {
    data class Advice(val message: String, val ok: Boolean)
    fun evaluate(frame: Frame?, targetLat: Double, targetLng: Double): Advice {
        // TODO: calcul d'angle/distance via la pose ARCore
        return Advice("Avance 1.2 m et tourne 8° à droite", ok = false)
    }
}

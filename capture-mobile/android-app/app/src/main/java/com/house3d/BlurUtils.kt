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

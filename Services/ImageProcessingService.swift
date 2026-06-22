import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

final class ImageProcessingService {
    private let context = CIContext()

    func applyBinarization(to image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }

        // Convertir a escala de grises
        let grayscale = ciImage.applyingFilter("CIColorControls", parameters: [
            kCIInputSaturationKey: 0.0,
            kCIInputContrastKey: 1.1
        ])

        // Binarización: umbral alto para B/N de alto contraste
        let threshold = CIFilter.colorThreshold()
        threshold.inputImage = grayscale
        threshold.threshold = 0.5

        // Invertir: documento (papel) blanco, fondo negro
        guard let thresholdOutput = threshold.outputImage else { return image }
        let inverted = thresholdOutput.applyingFilter("CIColorInvert")

        guard
            let cgImage = context.createCGImage(inverted, from: inverted.extent)
        else { return image }

        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}

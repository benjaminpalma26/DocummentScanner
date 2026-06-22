import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

final class ImageProcessingService {
    private let context = CIContext()

    func applyBinarization(to image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }

        // Escala de grises
        let grayscale = ciImage.applyingFilter("CIColorControls", parameters: [
            kCIInputSaturationKey: 0.0
        ])

        // Niveles: aclarar sombras suaves, oscurecer fondos sin destruir el texto
        let levels = grayscale.applyingFilter("CIColorControls", parameters: [
            kCIInputBrightnessKey: 0.05,
            kCIInputContrastKey: 1.6
        ])

        // Nitidez para que el texto sea más legible
        let sharp = levels.applyingFilter("CISharpenLuminance", parameters: [
            kCIInputSharpnessKey: 0.6,
            kCIInputRadiusKey: 1.5
        ])

        guard let cgImage = context.createCGImage(sharp, from: sharp.extent) else { return image }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}

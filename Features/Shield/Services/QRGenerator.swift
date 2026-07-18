import CoreImage.CIFilterBuiltins
import SwiftUI

enum QRGenerator {
  static func generate(from payload: String, correctionLevel: String = "M", scale: CGFloat = 10)
    -> UIImage?
  {
    // 1. Convert payload to Data
    let data = Data(payload.utf8)

    // 2. Generate QR
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    filter.message = data
    filter.setValue(correctionLevel, forKey: "inputCorrectionLevel")

    if let outputImage = filter.outputImage {
      // 3. Scale up to avoid pixelation
      // Using affine transform for sharp edges (better than resizing UIImage later)
      let transform = CGAffineTransform(scaleX: scale, y: scale)
      let scaledImage = outputImage.transformed(by: transform)

      // 4. Render to UIImage
      if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
        return UIImage(cgImage: cgImage)
      }
    }

    return nil
  }
}

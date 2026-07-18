import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI
import UIKit

/// Renders a "QR Art" image using CoreImage filters.
/// Designed for offline, instant usage (<200ms) with no external dependencies.
enum QRArtRenderer {

  private static let context = CIContext()

  enum Theme: String, CaseIterable, Identifiable {
    case cloud = "Cloud"  // Original Pastel
    case ocean = "Ocean"  // Blue/Teal
    case sunset = "Sunset"  // Red/Orange
    case forest = "Forest"  // Green/Nature
    case mono = "Mono"  // Grayscaleish

    var id: String { rawValue }
  }

  /// Generates an "OptionA" QR Art image:
  /// - High contrast QR modules (Dark)
  /// - Artistic, wallpaper-like background (Light/Pastel)
  /// - Preserves finders and timing patterns by keeping them sharp
  /// - Softens the look of the data modules slightly against the background
  static func renderOptionA(
    qr: UIImage, theme: Theme = .cloud, canvasSize: CGSize = CGSize(width: 1024, height: 2048)
  )
    -> UIImage?
  {
    // 1. Convert Input QR to CIImage
    guard let ciQR = CIImage(image: qr) else { return nil }

    // 2. Prepare Geometry
    // Scale QR to fit nicely within the width of the canvas (leaving some margin)
    let targetQRWidth = canvasSize.width * 0.85
    let scale = targetQRWidth / ciQR.extent.width
    let scaledQR = ciQR.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

    // Center the QR on the canvas
    // Canvas is defined by an extent rect (0, 0, width, height) usually.
    // We'll compose everything into this canvas rect.
    let qrOriginX = (canvasSize.width - scaledQR.extent.width) / 2.0
    let qrOriginY = (canvasSize.height - scaledQR.extent.height) / 2.0
    let positionedQR = scaledQR.transformed(
      by: CGAffineTransform(translationX: qrOriginX, y: qrOriginY))

    // 3. Generate "Wallpaper" Background
    // A pleasant, light, ambient background.
    // We use RandomGenerator -> Smooth -> ColorMatrix for a pastel cloud look.
    guard let background = generateArtBackground(size: canvasSize, theme: theme) else { return nil }

    // 4. Create the composite
    // Strategy:
    // - Invert QR (Black code becomes White, White bg becomes Black)
    // - Mask to Alpha (White -> Opaque, Black -> Transparent)
    // - Result: The "Code" is opaque white, "Background" is transparent.
    // - We want "Code" to be DARK (so invert again? or just use Multiply?)

    // Better Strategy for "Dark Code on Light Art":
    // Input QR: Black Text, White BG.
    // We want: Black Text -> Kept (or Darkened). White BG -> Replace with Art.

    // Filter: BlendWithMask
    // InputImage: The "Dark Code" layer (solid dark color or gradient)
    // BackgroundImage: The "Art" layer
    // MaskImage: The QR code (where Black = show Dark, White = show Art)
    // Note: CIBlendWithMask uses the Mask's RED channel.
    // If QR is standard (Black=0, White=1):
    // White (1.0) -> Shows InputImage (Foreground)?? No, usually White reveals Foreground.
    // Let's verify standard behavior: Dest * (1-Mask) + Source * Mask.
    // If Mask=1 (White), we see Source (InputImage).
    // If Mask=0 (Black), we see Dest (BackgroundImage).

    // Our QR: Black(0) is the DATA. White(1) is the GAP.
    // We want DATA to be the Dark Foreground.
    // We want GAPS to be the Art Background.
    // So where QR is Black(0), we want Foreground. -> Wait, 0 shows Background.
    // Currently: Black(0) -> Shows Background. White(1) -> Shows Foreground.
    // Result: Data(Black) shows Art. Gaps(White) show Foreground. -> INVERTED of what we want.

    // Fix: Invert the QR first so Data is White(1).
    let invertFilter = CIFilter.colorInvert()
    invertFilter.inputImage = positionedQR
    guard let invertedQR = invertFilter.outputImage else { return nil }

    // Now Data is White(1) -> Shows Foreground (Dark Color).
    // Gaps are Black(0) -> Show Background (Art).

    // Define Foreground (The "Dots" color)
    // A very dark, slightly tinted color looks premium.
    let darkColor: CIColor
    switch theme {
    case .cloud, .ocean:
      darkColor = CIColor(red: 0.1, green: 0.15, blue: 0.25, alpha: 1.0)  // Dark Blue
    case .sunset:
      darkColor = CIColor(red: 0.25, green: 0.1, blue: 0.1, alpha: 1.0)  // Dark Red
    case .forest:
      darkColor = CIColor(red: 0.1, green: 0.2, blue: 0.1, alpha: 1.0)  // Dark Green
    case .mono:
      darkColor = CIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)  // Dark Gray
    }

    let foregroundImage = CIImage(color: darkColor)

    // Blend
    let blendFilter = CIFilter.blendWithMask()
    blendFilter.backgroundImage = background
    blendFilter.inputImage = foregroundImage
    blendFilter.maskImage = invertedQR

    guard let composite = blendFilter.outputImage else { return nil }

    // 5. Crop to Canvas Size
    let finalImage = composite.cropped(to: CGRect(origin: .zero, size: canvasSize))

    // 6. Output
    if let cgImage = context.createCGImage(finalImage, from: finalImage.extent) {
      return UIImage(cgImage: cgImage)
    }

    return nil
  }

  // MARK: - Helpers

  private static func generateArtBackground(size: CGSize, theme: Theme) -> CIImage? {
    // 1. Noise
    let noise = CIFilter.randomGenerator()
    guard let rawNoise = noise.outputImage else { return nil }

    // 2. Crop to strict size to avoid infinite extent issues in subsequent filters
    let croppedNoise = rawNoise.cropped(to: CGRect(origin: .zero, size: size))

    // 3. Matrix to make it soft/pastel (remove harsh saturation)
    // Vectors to mix channels into a lighter, softer palette
    let matrix = CIFilter.colorMatrix()
    matrix.inputImage = croppedNoise

    switch theme {
    case .cloud:
      // Original Pastel (Pink/Blue/Violet)
      matrix.rVector = CIVector(x: 0.8, y: 0.1, z: 0.1, w: 0)
      matrix.gVector = CIVector(x: 0.1, y: 0.8, z: 0.1, w: 0)
      matrix.bVector = CIVector(x: 0.1, y: 0.1, z: 0.9, w: 0)
      matrix.biasVector = CIVector(x: 0.3, y: 0.3, z: 0.4, w: 0)

    case .ocean:
      // Teal/Blue/Cyan
      matrix.rVector = CIVector(x: 0.1, y: 0.2, z: 0.7, w: 0)
      matrix.gVector = CIVector(x: 0.1, y: 0.8, z: 0.5, w: 0)
      matrix.bVector = CIVector(x: 0.1, y: 0.1, z: 0.9, w: 0)
      matrix.biasVector = CIVector(x: 0.1, y: 0.3, z: 0.5, w: 0)

    case .sunset:
      // Orange/Pink/Yellow
      matrix.rVector = CIVector(x: 0.9, y: 0.2, z: 0.1, w: 0)
      matrix.gVector = CIVector(x: 0.4, y: 0.6, z: 0.1, w: 0)
      matrix.bVector = CIVector(x: 0.8, y: 0.1, z: 0.1, w: 0)
      matrix.biasVector = CIVector(x: 0.4, y: 0.2, z: 0.1, w: 0)

    case .forest:
      // Green/Mint/Earth
      matrix.rVector = CIVector(x: 0.1, y: 0.5, z: 0.1, w: 0)
      matrix.gVector = CIVector(x: 0.2, y: 0.8, z: 0.2, w: 0)
      matrix.bVector = CIVector(x: 0.3, y: 0.3, z: 0.3, w: 0)
      matrix.biasVector = CIVector(x: 0.2, y: 0.4, z: 0.2, w: 0)

    case .mono:
      // Grayscale
      matrix.rVector = CIVector(x: 0.33, y: 0.33, z: 0.33, w: 0)
      matrix.gVector = CIVector(x: 0.33, y: 0.33, z: 0.33, w: 0)
      matrix.bVector = CIVector(x: 0.33, y: 0.33, z: 0.33, w: 0)
      matrix.biasVector = CIVector(x: 0.4, y: 0.4, z: 0.4, w: 0)
    }

    guard let softNoise = matrix.outputImage else { return nil }

    // 4. Heavy Blur to create the "Cloud/Wallpaper" look
    let blur = CIFilter.gaussianBlur()
    blur.inputImage = softNoise
    // Large radius for smooth gradients
    blur.radius = Float(min(size.width, size.height) * 0.15)

    guard let blurred = blur.outputImage else { return nil }

    // 5. Crop again after blur to ensure clean edges (blur expands extent)
    return blurred.cropped(to: CGRect(origin: .zero, size: size))
  }
}

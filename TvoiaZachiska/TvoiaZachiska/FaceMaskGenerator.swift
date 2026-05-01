import Foundation
import UIKit
import Vision

/// Builds an RGBA alpha mask used by OpenAI's images/edits API to lock the face region.
/// Convention: transparent pixels are editable; opaque pixels are preserved.
enum FaceMaskGenerator {

    /// Returns a PNG mask the same dimensions as `image`, with the detected face oval
    /// painted opaque (preserved) and everything else transparent (editable).
    /// Returns nil if no face is detected.
    static func generateFaceMaskPNG(for image: UIImage) async -> Data? {
        guard let cg = image.cgImage else { return nil }

        let face: VNFaceObservation? = await withCheckedContinuation { cont in
            let request = VNDetectFaceRectanglesRequest { req, _ in
                let result = (req.results as? [VNFaceObservation])?
                    .max(by: { $0.boundingBox.area < $1.boundingBox.area })
                cont.resume(returning: result)
            }
            request.revision = VNDetectFaceRectanglesRequestRevision3
            let handler = VNImageRequestHandler(cgImage: cg, orientation: .up)
            do {
                try handler.perform([request])
            } catch {
                cont.resume(returning: nil)
            }
        }

        guard let face else { return nil }

        let w = CGFloat(cg.width)
        let h = CGFloat(cg.height)

        // VNFaceObservation.boundingBox is normalized, origin bottom-left
        let bbox = face.boundingBox
        let faceRect = CGRect(
            x: bbox.minX * w,
            y: (1 - bbox.maxY) * h,
            width: bbox.width * w,
            height: bbox.height * h
        )

        // Inset slightly so the model has soft edges around the face — otherwise
        // a hard mask boundary leaves visible seams along the hairline.
        let insetFactor: CGFloat = 0.06
        let insetX = faceRect.width * insetFactor
        let insetY = faceRect.height * insetFactor
        let preserveRect = faceRect.insetBy(dx: insetX, dy: insetY)

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: w, height: h), format: format)
        let mask = renderer.image { ctx in
            let cgCtx = ctx.cgContext
            cgCtx.clear(CGRect(x: 0, y: 0, width: w, height: h))
            cgCtx.setFillColor(UIColor.white.cgColor)
            cgCtx.fillEllipse(in: preserveRect)
        }
        return mask.pngData()
    }
}

private extension CGRect {
    var area: CGFloat { width * height }
}

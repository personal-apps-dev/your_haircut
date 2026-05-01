import SwiftUI
import UIKit

/// Wraps `UIImagePickerController` so SwiftUI can present the camera or photo library.
struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    @Binding var image: UIImage?
    var onDismiss: () -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        if sourceType == .camera, UIImagePickerController.isCameraDeviceAvailable(.front) {
            picker.cameraDevice = .front
        }
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if var img = info[.originalImage] as? UIImage {
                // UIImagePickerController returns front-camera selfies mirrored
                // (matching what the user saw in the live preview). For a try-on
                // app we want the photo to look like the actual person, so flip back.
                if picker.sourceType == .camera, picker.cameraDevice == .front {
                    img = Self.unmirror(img)
                }
                parent.image = img
            }
            parent.onDismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onDismiss()
        }

        /// Returns a non-mirrored version of `image` with EXIF orientation baked in.
        private static func unmirror(_ image: UIImage) -> UIImage {
            // 1. Bake any EXIF orientation into the raw pixels so subsequent
            //    drawing ignores the orientation flag.
            let baked: UIImage = {
                if image.imageOrientation == .up { return image }
                let f = UIGraphicsImageRendererFormat()
                f.scale = image.scale
                return UIGraphicsImageRenderer(size: image.size, format: f).image { _ in
                    image.draw(at: .zero)
                }
            }()

            // 2. Horizontally flip the pixel data.
            let f = UIGraphicsImageRendererFormat()
            f.scale = baked.scale
            return UIGraphicsImageRenderer(size: baked.size, format: f).image { ctx in
                let c = ctx.cgContext
                c.translateBy(x: baked.size.width, y: 0)
                c.scaleBy(x: -1, y: 1)
                baked.draw(in: CGRect(origin: .zero, size: baked.size))
            }
        }
    }
}

import Foundation
import UIKit

// MARK: - Errors

enum OpenAIError: LocalizedError {
    case missingApiKey
    case invalidImage
    case requestFailed(Int, String)
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingApiKey:               return "OpenAI ключ не встановлено. Додай його в Налаштуваннях."
        case .invalidImage:                return "Не вдалося обробити зображення."
        case .requestFailed(let s, let m): return "Помилка OpenAI (\(s)): \(m)"
        case .decodingFailed(let m):       return "Не вдалося розшифрувати відповідь: \(m)"
        }
    }
}

// MARK: - Client

final class OpenAIClient {
    private let apiKey: String
    private let endpoint = URL(string: "https://api.openai.com/v1/images/edits")!

    init(apiKey: String) { self.apiKey = apiKey }

    /// Edits the user's photo, replacing only the hairstyle. Returns the edited image.
    /// Uses `input_fidelity: high` and a face-locked alpha mask so the original face,
    /// expression, and identity are preserved across the edit.
    /// Costs roughly $0.08-0.10 (medium quality + high fidelity, 1024×1024) per call.
    func editHairstyle(image: UIImage, hairstyle: HairstyleItem) async throws -> UIImage {
        let prepped = Self.squareCrop(image, side: 1024)
        guard let png = prepped.pngData() else {
            throw OpenAIError.invalidImage
        }

        // Detect the face on the cropped image so the mask aligns with what we send.
        let maskData = await FaceMaskGenerator.generateFaceMaskPNG(for: prepped)

        let prompt = Self.buildPrompt(for: hairstyle, hasMask: maskData != nil)
        let boundary = "----TZBoundary\(UUID().uuidString)"

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 180

        var parts: [(name: String, filename: String?, contentType: String?, data: Data)] = [
            ("model",          nil,         nil,         "gpt-image-1".data(using: .utf8)!),
            ("prompt",         nil,         nil,         prompt.data(using: .utf8)!),
            ("size",           nil,         nil,         "1024x1024".data(using: .utf8)!),
            ("n",              nil,         nil,         "1".data(using: .utf8)!),
            ("quality",        nil,         nil,         "medium".data(using: .utf8)!),
            ("input_fidelity", nil,         nil,         "high".data(using: .utf8)!),
            ("image",          "input.png", "image/png", png),
        ]
        if let maskData {
            parts.append(("mask", "mask.png", "image/png", maskData))
        }
        request.httpBody = Self.multipartBody(boundary: boundary, parts: parts)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw OpenAIError.requestFailed(0, "no response")
        }

        if http.statusCode != 200 {
            let msg = Self.extractErrorMessage(from: data) ?? "HTTP \(http.statusCode)"
            throw OpenAIError.requestFailed(http.statusCode, msg)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let arr = json["data"] as? [[String: Any]],
              let first = arr.first,
              let b64 = first["b64_json"] as? String,
              let imgData = Data(base64Encoded: b64),
              let result = UIImage(data: imgData) else {
            throw OpenAIError.decodingFailed("missing b64_json")
        }
        return result
    }

    // MARK: - Prompt construction

    private static func buildPrompt(for hairstyle: HairstyleItem, hasMask: Bool) -> String {
        let styleDesc = englishDescription(for: hairstyle.shape)
        let lengthDesc = englishLength(for: hairstyle.length)
        let colorDesc = englishColor(hex: hairstyle.hue)

        if hasMask {
            // The mask already locks the face — keep the prompt focused on the new hair
            // and on blending it cleanly with what's preserved.
            return """
            Replace the hair on this person with: \(styleDesc), \(lengthDesc), \(colorDesc).

            Photorealistic. Natural individual strands. Realistic hairline that sits naturally on the head.
            Match the original photo's lighting direction, color temperature, and shadows.
            Blend seamlessly with the preserved face — no visible seams along the forehead, temples, or jaw.
            Do NOT alter facial features, skin, eyes, or expression. Keep clothing and background unchanged where possible.
            """
        }

        return """
        Photorealistic photo edit. Change ONLY the hairstyle of the person in this photo to: \
        \(styleDesc), \(lengthDesc), \(colorDesc).

        Critical preservation requirements:
        - Keep the EXACT SAME face: same skin tone, eye color, eyebrows, nose, mouth, expression, jawline, ears, neck.
        - Keep the EXACT SAME identity — the result must be recognizable as the same person.
        - Keep the EXACT SAME lighting, background, clothing, and pose.
        - The result must look like the SAME person photographed in the SAME setting, with only the hair changed.
        - Hair must be photorealistic — natural strands, realistic shading, NOT illustrated, NOT cartoon, NOT painted.
        - Hair should fit naturally on the head, with believable hairline and volume.
        """
    }

    private static func englishDescription(for shape: HairShape) -> String {
        switch shape {
        case .bald:          return "completely bald, smoothly shaved head, no hair"
        case .buzzZero:      return "buzz cut #0, very short shaved hair"
        case .buzz:          return "short buzz cut"
        case .crew:          return "classic crew cut, short on top, tapered sides"
        case .crop:          return "textured French crop with short fringe"
        case .ivy:           return "Ivy League cut, side-parted, neat"
        case .caesar:        return "Caesar cut with short forward fringe"
        case .pixie:         return "classic pixie cut, very short"
        case .pixieFringe:   return "pixie cut with side-swept fringe"
        case .bixie:         return "bixie cut (between bob and pixie), choppy ends"
        case .bob:           return "textured bob, chin-length, modern"
        case .bluntBob:      return "blunt straight bob with sharp ends"
        case .aBob:          return "A-line bob (longer in front, shorter in back)"
        case .frenchBob:     return "French bob with full bangs"
        case .lob:           return "long bob (lob), shoulder-length"
        case .curlyLob:      return "curly long bob with defined curls"
        case .fringe:        return "medium-length hair with straight blunt bangs"
        case .shag:          return "shag haircut with choppy layers and bangs"
        case .layered:       return "medium-length hair with feathered face-framing layers"
        case .wavyBob:       return "wavy bob with soft body and movement"
        case .longLayers:    return "long hair with face-framing layers"
        case .longWavy:      return "long flowing hair with loose beach waves"
        case .longStraight:  return "long sleek straight hair"
        case .longCurly:     return "long defined spiral curls"
        case .bun:           return "low elegant bun updo at the nape"
        case .ponytail:      return "high sleek ponytail"
        case .fringeM:       return "men's fringe hairstyle, hair forward"
        case .slick:         return "men's slicked-back hair with shine"
        case .pomp:          return "men's pompadour with volume on top"
        case .quiff:         return "modern men's quiff with height in front"
        case .tousled:       return "tousled medium-length men's hair, casual"
        case .curtain:       return "curtain hairstyle with middle part, framing the face"
        case .longFlow:      return "long flowing men's hair, past shoulders"
        case .manBun:        return "man bun, hair pulled back into a knot"
        case .longWavyM:     return "shoulder-length wavy men's hair"
        }
    }

    private static func englishLength(for length: HairLength) -> String {
        switch length {
        case .bald:   return "shaved"
        case .short:  return "short"
        case .medium: return "medium-length"
        case .long:   return "long"
        }
    }

    private static func englishColor(hex: String) -> String {
        let clean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted).lowercased()
        guard clean.count == 6,
              let r = Int(clean.prefix(2), radix: 16),
              let g = Int(clean.dropFirst(2).prefix(2), radix: 16),
              let b = Int(clean.dropFirst(4).prefix(2), radix: 16) else {
            return "natural hair color"
        }
        let lum = (r + g + b) / 3
        switch lum {
        case 0..<25:    return "jet black"
        case 25..<55:   return "very dark brown, almost black"
        case 55..<90:   return "rich dark brown"
        case 90..<125:  return "warm medium brown"
        case 125..<160: return "honey brown / caramel brown"
        default:        return "light brown / dirty blonde"
        }
    }

    // MARK: - HTTP helpers

    private static func multipartBody(
        boundary: String,
        parts: [(name: String, filename: String?, contentType: String?, data: Data)]
    ) -> Data {
        var body = Data()
        let lineBreak = "\r\n"
        for part in parts {
            body.append("--\(boundary)\(lineBreak)".data(using: .utf8)!)
            if let filename = part.filename {
                body.append("Content-Disposition: form-data; name=\"\(part.name)\"; filename=\"\(filename)\"\(lineBreak)".data(using: .utf8)!)
                body.append("Content-Type: \(part.contentType ?? "application/octet-stream")\(lineBreak)\(lineBreak)".data(using: .utf8)!)
            } else {
                body.append("Content-Disposition: form-data; name=\"\(part.name)\"\(lineBreak)\(lineBreak)".data(using: .utf8)!)
            }
            body.append(part.data)
            body.append(lineBreak.data(using: .utf8)!)
        }
        body.append("--\(boundary)--\(lineBreak)".data(using: .utf8)!)
        return body
    }

    private static func extractErrorMessage(from data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let err = json["error"] as? [String: Any],
              let msg = err["message"] as? String else { return nil }
        return msg
    }

    /// Center-crops + scales the image to a square at the given side length.
    private static func squareCrop(_ image: UIImage, side: CGFloat) -> UIImage {
        let size = image.size
        let s = min(size.width, size.height)
        let cropRect = CGRect(
            x: (size.width - s) / 2,
            y: (size.height - s) / 2,
            width: s, height: s
        )

        // Use a renderer to get a CGImage in the right orientation
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let cropped = UIGraphicsImageRenderer(size: CGSize(width: s, height: s), format: format).image { _ in
            image.draw(at: CGPoint(x: -cropRect.origin.x, y: -cropRect.origin.y))
        }

        if s == side { return cropped }
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: side, height: side), format: format)
        return renderer.image { _ in
            cropped.draw(in: CGRect(x: 0, y: 0, width: side, height: side))
        }
    }
}

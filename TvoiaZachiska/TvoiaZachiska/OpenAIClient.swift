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

    /// Edits the user's photo, replacing only the SHAPE of the hairstyle.
    /// Output aspect ratio matches the input so BEFORE/AFTER align in the slider view.
    /// Costs roughly $0.08-0.12 per call.
    func editHairstyle(image: UIImage, hairstyle: HairstyleItem) async throws -> UIImage {
        let normalized = Self.normalizeOrientation(image)
        let resized = Self.resize(normalized, maxEdge: 1536)
        guard let png = resized.pngData() else {
            throw OpenAIError.invalidImage
        }

        let outputSize = Self.outputSize(for: resized)
        let prompt = Self.buildPrompt(for: hairstyle)
        let boundary = "----TZBoundary\(UUID().uuidString)"

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 180

        request.httpBody = Self.multipartBody(boundary: boundary, parts: [
            ("model",          nil,         nil,         "gpt-image-1".data(using: .utf8)!),
            ("prompt",         nil,         nil,         prompt.data(using: .utf8)!),
            ("size",           nil,         nil,         outputSize.data(using: .utf8)!),
            ("n",              nil,         nil,         "1".data(using: .utf8)!),
            ("quality",        nil,         nil,         "medium".data(using: .utf8)!),
            ("input_fidelity", nil,         nil,         "high".data(using: .utf8)!),
            ("image",          "input.png", "image/png", png),
        ])

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

    private static func buildPrompt(for hairstyle: HairstyleItem) -> String {
        let styleDesc = englishDescription(for: hairstyle.shape)
        let lengthDesc = englishLength(for: hairstyle.length)

        return """
        Photorealistic photo edit. Change ONLY the SHAPE of this person's hair to: \
        \(styleDesc), \(lengthDesc).

        HAIR COLOR — DO NOT CHANGE:
        - Keep the person's existing natural hair color from the original photo EXACTLY as it is.
        - Do NOT lighten, darken, or recolor the hair.
        - The new haircut must be the same hair color as in the original.

        IDENTITY — DO NOT CHANGE:
        - Keep the EXACT SAME face: same skin tone, eye color, eyebrows, nose, mouth, expression, jawline, ears, neck.
        - The result must be 100% recognizable as the SAME person — not a different person.
        - Keep the same head angle, head size, and head position within the frame.

        SCENE — DO NOT CHANGE:
        - Keep the EXACT SAME background, lighting, color temperature, shadows, clothing, and pose.
        - Keep the SAME framing and composition (do not zoom in, do not crop, do not reposition the head).

        Style:
        - Photorealistic. Natural individual strands. Believable hairline.
        - Looks like a real photograph of the same person, just with a different haircut shape.
        - NOT cartoon, NOT illustrated, NOT painted, NOT stylized.
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

    // MARK: - Image helpers

    /// Maps the image's aspect ratio to one of gpt-image-1's supported output sizes.
    private static func outputSize(for image: UIImage) -> String {
        let aspect = image.size.width / max(image.size.height, 1)
        if aspect < 0.85 { return "1024x1536" }     // portrait
        if aspect > 1.15 { return "1536x1024" }     // landscape
        return "1024x1024"                           // square-ish
    }

    /// Bakes the EXIF orientation into the pixel data so the upload isn't rotated.
    private static func normalizeOrientation(_ image: UIImage) -> UIImage {
        if image.imageOrientation == .up { return image }
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        return UIGraphicsImageRenderer(size: image.size, format: format).image { _ in
            image.draw(at: .zero)
        }
    }

    /// Downscales so the longer edge ≤ maxEdge while preserving aspect.
    private static func resize(_ image: UIImage, maxEdge: CGFloat) -> UIImage {
        let w = image.size.width
        let h = image.size.height
        let longEdge = max(w, h)
        if longEdge <= maxEdge { return image }
        let scale = maxEdge / longEdge
        let newSize = CGSize(width: floor(w * scale), height: floor(h * scale))
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

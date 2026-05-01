import Foundation
import UIKit

// MARK: - Errors

enum AnthropicError: LocalizedError {
    case missingApiKey
    case invalidImage
    case requestFailed(Int, String)
    case decodingFailed(String)
    case refusal(String)

    var errorDescription: String? {
        switch self {
        case .missingApiKey:           return "API ключ не встановлено. Додай його в Налаштуваннях."
        case .invalidImage:            return "Не вдалося обробити зображення."
        case .requestFailed(let s, let m): return "Помилка API (\(s)): \(m)"
        case .decodingFailed(let m):   return "Не вдалося розшифрувати відповідь: \(m)"
        case .refusal(let m):          return "Claude відмовив у відповіді: \(m)"
        }
    }
}

// MARK: - Result model

struct HairAnalysisResult: Codable, Equatable {
    let faceShape: String        // oval | round | square | heart | long
    let hairType: String
    let skinTone: String
    let matchScore: Int          // 0..100
    let matchLabel: String
    let breakdown: [BreakdownItem]
    let tips: [String]

    struct BreakdownItem: Codable, Equatable {
        let label: String
        let value: Int
        let note: String
    }
}

// MARK: - Client

final class AnthropicClient {
    private let apiKey: String
    private let model = "claude-opus-4-7"
    private let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!

    init(apiKey: String) { self.apiKey = apiKey }

    func analyzeHairstyle(image: UIImage, hairstyle: HairstyleItem) async throws -> HairAnalysisResult {
        let resized = Self.resize(image, maxDimension: 1024)
        guard let jpeg = resized.jpegData(compressionQuality: 0.85) else {
            throw AnthropicError.invalidImage
        }
        let base64 = jpeg.base64EncodedString()

        let prompt = """
        Проаналізуй це фото обличчя та оціни, як підійде зачіска \"\(hairstyle.name)\" \
        (довжина: \(hairstyle.length.rawValue), стиль: \(hairstyle.vibe)).

        Поверни JSON з такими полями:
        - faceShape: форма обличчя (одне з: oval, round, square, heart, long)
        - hairType: короткий опис типу волосся українською (1-3 слова)
        - skinTone: тон шкіри українською (1-3 слова)
        - matchScore: загальна оцінка сумісності (число 0-100)
        - matchLabel: фраза до 3 слів про рівень сумісності українською
        - breakdown: масив з 4 об'єктів (Форма обличчя, Тип волосся, Стиль, Догляд) — \
        кожен з полями label (українською), value (0-100), note (одне коротке речення українською)
        - tips: масив з 3 практичних порад українською (по одному реченню кожна)

        Відповідай українською. Будь чесним — якщо зачіска не підходить, дай нижчий бал.
        """

        let schema: [String: Any] = [
            "type": "object",
            "properties": [
                "faceShape": ["type": "string", "enum": ["oval", "round", "square", "heart", "long"]],
                "hairType": ["type": "string"],
                "skinTone": ["type": "string"],
                "matchScore": ["type": "integer"],
                "matchLabel": ["type": "string"],
                "breakdown": [
                    "type": "array",
                    "items": [
                        "type": "object",
                        "properties": [
                            "label": ["type": "string"],
                            "value": ["type": "integer"],
                            "note": ["type": "string"]
                        ],
                        "required": ["label", "value", "note"],
                        "additionalProperties": false
                    ]
                ],
                "tips": ["type": "array", "items": ["type": "string"]]
            ],
            "required": ["faceShape", "hairType", "skinTone", "matchScore", "matchLabel", "breakdown", "tips"],
            "additionalProperties": false
        ]

        let body: [String: Any] = [
            "model": model,
            "max_tokens": 4096,
            "messages": [[
                "role": "user",
                "content": [
                    [
                        "type": "image",
                        "source": [
                            "type": "base64",
                            "media_type": "image/jpeg",
                            "data": base64
                        ]
                    ],
                    [
                        "type": "text",
                        "text": prompt
                    ]
                ]
            ]],
            "output_config": [
                "format": [
                    "type": "json_schema",
                    "schema": schema
                ]
            ]
        ]

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.timeoutInterval = 90
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw AnthropicError.requestFailed(0, "no response")
        }

        if http.statusCode != 200 {
            let msg = Self.extractErrorMessage(from: data) ?? "HTTP \(http.statusCode)"
            throw AnthropicError.requestFailed(http.statusCode, msg)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw AnthropicError.decodingFailed("not JSON")
        }

        // Stop reason check
        if let stop = json["stop_reason"] as? String, stop == "refusal" {
            throw AnthropicError.refusal("Claude refused")
        }

        guard let content = json["content"] as? [[String: Any]] else {
            throw AnthropicError.decodingFailed("missing content")
        }

        // First text block contains the structured JSON.
        for block in content {
            guard (block["type"] as? String) == "text",
                  let text = block["text"] as? String,
                  let textData = text.data(using: .utf8) else { continue }
            do {
                return try JSONDecoder().decode(HairAnalysisResult.self, from: textData)
            } catch {
                throw AnthropicError.decodingFailed(error.localizedDescription)
            }
        }

        throw AnthropicError.decodingFailed("no text block in content")
    }

    // MARK: - Helpers

    private static func extractErrorMessage(from data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let err = json["error"] as? [String: Any],
              let msg = err["message"] as? String else { return nil }
        return msg
    }

    private static func resize(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let longEdge = max(size.width, size.height)
        guard longEdge > maxDimension else { return image }
        let scale = maxDimension / longEdge
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

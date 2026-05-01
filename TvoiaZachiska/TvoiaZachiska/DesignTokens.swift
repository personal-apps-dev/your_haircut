import SwiftUI

// MARK: - Color tokens

extension Color {
    static let tzBg             = Color(hex: "FAFAF8")
    static let tzSurface        = Color.white
    static let tzSurfaceMuted   = Color(hex: "F4F2EE")
    static let tzInk            = Color(hex: "0F0F0E")
    static let tzInkSoft        = Color(hex: "1F1F1D")
    static let tzMuted          = Color(hex: "78766F")
    static let tzMutedSoft      = Color(hex: "A8A59C")
    static let tzHairline       = Color(hex: "0F0F0E").opacity(0.08)
    static let tzHairlineStrong = Color(hex: "0F0F0E").opacity(0.14)
    static let tzPos            = Color(hex: "3F8159")
    static let tzWarn           = Color(hex: "B98C2D")
    static let tzRed            = Color(hex: "CC4444")

    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch h.count {
        case 3:  (a,r,g,b) = (255, (int>>8)*17, (int>>4 & 0xF)*17, (int & 0xF)*17)
        case 6:  (a,r,g,b) = (255, int>>16, int>>8 & 0xFF, int & 0xFF)
        case 8:  (a,r,g,b) = (int>>24, int>>16 & 0xFF, int>>8 & 0xFF, int & 0xFF)
        default: (a,r,g,b) = (255,0,0,0)
        }
        self.init(.sRGB,
                  red: Double(r)/255,
                  green: Double(g)/255,
                  blue: Double(b)/255,
                  opacity: Double(a)/255)
    }
}

// MARK: - Font tokens

extension Font {
    // Serif (Georgia is pre-installed on iOS, close to Instrument Serif)
    static func tzSerif(_ size: CGFloat, italic: Bool = false) -> Font {
        italic
            ? .custom("Georgia-Italic", size: size)
            : .custom("Georgia", size: size)
    }
    // Sans = system (SF Pro)
    static func tzSans(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }
}

// MARK: - CGFloat constants

extension CGFloat {
    static let radiusSmall:  CGFloat = 12
    static let radiusMed:    CGFloat = 18
    static let radiusLarge:  CGFloat = 24
    static let radiusXL:     CGFloat = 28
    static let radiusPill:   CGFloat = 100
}

// MARK: - View modifiers helpers

extension View {
    func tzShadowCard() -> some View {
        self.shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
}

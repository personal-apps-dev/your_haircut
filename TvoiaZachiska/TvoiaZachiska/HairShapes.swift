import SwiftUI

// MARK: - HairGlyphView
// Renders a schematic portrait with a hairstyle silhouette.
// Viewport: 120 × 140 pts (scaled to fill whatever size is given).

struct HairGlyphView: View {
    let style: HairstyleItem
    var isDark: Bool = false

    var body: some View {
        Canvas { ctx, size in
            let sx = size.width / 120
            let sy = size.height / 140
            ctx.concatenate(CGAffineTransform(scaleX: sx, y: sy))
            drawGlyph(ctx, shape: style.shape, hairHex: style.hue, isDark: isDark)
        }
    }
}

// MARK: - FaceCanvasView
// Larger portrait (200 × 240) used in Preview and Result screens.

struct FaceCanvasView: View {
    var hairHex: String = "2A1F18"
    var isDark: Bool = false

    var body: some View {
        Canvas { ctx, size in
            let sx = size.width / 200
            let sy = size.height / 240
            ctx.concatenate(CGAffineTransform(scaleX: sx, y: sy))
            drawFace(ctx, hairHex: hairHex, isDark: isDark)
        }
    }
}

// MARK: - Drawing helpers

private func drawGlyph(_ ctx: GraphicsContext, shape: HairShape, hairHex: String, isDark: Bool) {
    let bg = isDark ? Color(hex: "1A1A18") : Color(hex: "F4F2EE")
    let shoulderColor = isDark ? Color(hex: "28231F") : Color(hex: "D4CDC0")
    let neckColor = isDark ? Color(hex: "3F352C") : Color(hex: "C9A380")
    let skinColor = isDark ? Color(hex: "5C4A3D") : Color(hex: "E8D5C0")
    let hairColor = Color(hex: hairHex)
    let inkColor  = Color(hex: "0F0F0E")
    let mouthColor = Color(hex: "8B5A4D")

    // Background
    ctx.fill(Path(CGRect(x: 0, y: 0, width: 120, height: 140)), with: .color(bg))

    // Shoulders
    var sp = Path()
    sp.move(to: pt(10, 140)); sp.addQuadCurve(to: pt(38, 105), control: pt(10, 110))
    sp.addLine(to: pt(82, 105)); sp.addQuadCurve(to: pt(110, 140), control: pt(110, 110))
    sp.closeSubpath()
    ctx.fill(sp, with: .color(shoulderColor))

    // Neck
    ctx.fill(Path(CGRect(x: 52, y: 92, width: 16, height: 18)), with: .color(neckColor))

    // Face
    ctx.fill(Path(ellipseIn: CGRect(x: 38, y: 37, width: 44, height: 56)), with: .color(skinColor))

    // Bald scalp
    if shape == .bald {
        let baldColor = isDark ? Color(hex: "574638") : Color(hex: "D9C2A8")
        ctx.fill(Path(ellipseIn: CGRect(x: 38, y: 28, width: 44, height: 44)), with: .color(baldColor))
    }

    // Hair shape
    if let hairPath = buildHairPath(shape: shape, bg: bg) {
        ctx.fill(hairPath, with: .color(hairColor))
    }

    // Curly dots overlay
    if let dots = buildCurlyDots(shape: shape) {
        ctx.fill(dots, with: .color(hairColor))
    }

    // Eyes
    ctx.fill(Path(ellipseIn: CGRect(x: 49.4, y: 65.8, width: 3.2, height: 4.4)), with: .color(inkColor))
    ctx.fill(Path(ellipseIn: CGRect(x: 67.4, y: 65.8, width: 3.2, height: 4.4)), with: .color(inkColor))

    // Mouth
    var mouth = Path()
    mouth.move(to: pt(55, 82)); mouth.addQuadCurve(to: pt(65, 82), control: pt(60, 85))
    ctx.stroke(mouth, with: .color(mouthColor), lineWidth: 1.4 / (120.0 / 120.0))

    // Curtain parting lines
    if shape == .curtain {
        var part = Path()
        part.move(to: pt(58, 30)); part.addLine(to: pt(58, 60))
        ctx.stroke(part, with: .color(bg), lineWidth: 2)
        var part2 = Path()
        part2.move(to: pt(62, 30)); part2.addLine(to: pt(62, 60))
        ctx.stroke(part2, with: .color(bg), lineWidth: 2)
    }

    // Tousled accent lines
    if shape == .tousled {
        for (start, end) in [(pt(44,38), pt(52,28)), (pt(60,24), pt(64,32)), (pt(76,30), pt(72,38))] {
            var lp = Path(); lp.move(to: start); lp.addLine(to: end)
            ctx.stroke(lp, with: .color(hairColor), lineWidth: 3)
        }
    }

    // Layered accent
    if shape == .layered {
        let segs: [(CGPoint, CGPoint, CGPoint)] = [
            (pt(30, 84), pt(36, 90), pt(28, 96)),
            (pt(92, 84), pt(86, 90), pt(94, 96)),
        ]
        for (a, b, c) in segs {
            var lp = Path(); lp.move(to: a); lp.addLine(to: b); lp.addLine(to: c)
            ctx.stroke(lp, with: .color(hairColor.opacity(0.7)), lineWidth: 3)
        }
    }
}

private func drawFace(_ ctx: GraphicsContext, hairHex: String, isDark: Bool) {
    let bg = isDark ? Color(hex: "1A1A18") : Color(hex: "EFEAE2")
    let shoulderColor = isDark ? Color(hex: "2A2522") : Color(hex: "3A332C")
    let neckShadow = isDark ? Color(hex: "4A3E35") : Color(hex: "D4BCA0")
    let skinColor   = isDark ? Color(hex: "7A5E4A") : Color(hex: "E8D5C0")
    let hairColor   = Color(hex: hairHex)
    let inkColor    = Color(hex: "0F0F0E")
    let mouthColor  = Color(hex: "8B5A4D")
    let lipColor    = Color(hex: "8B5A4D")

    // Background gradient simulation
    var grad = Path(); grad.addRect(CGRect(x: 0, y: 0, width: 200, height: 240))
    ctx.fill(grad, with: .color(bg))

    // Shoulders
    var sp = Path()
    sp.move(to: pt(30,240)); sp.addQuadCurve(to: pt(70,170), control: pt(30,180))
    sp.addLine(to: pt(130,170)); sp.addQuadCurve(to: pt(170,240), control: pt(170,180))
    sp.closeSubpath()
    ctx.fill(sp, with: .color(shoulderColor))

    // Neck
    ctx.fill(Path(CGRect(x: 86, y: 155, width: 28, height: 25)), with: .color(neckShadow))

    // Face
    ctx.fill(Path(ellipseIn: CGRect(x: 58, y: 63, width: 84, height: 104)), with: .color(skinColor))

    // Hair back
    var hb = Path()
    hb.move(to: pt(55,100)); hb.addQuadCurve(to: pt(100,50), control: pt(50,60))
    hb.addQuadCurve(to: pt(145,100), control: pt(150,60))
    hb.addLine(to: pt(145,145)); hb.addQuadCurve(to: pt(130,110), control: pt(130,130))
    hb.addQuadCurve(to: pt(70,110), control: pt(100,95))
    hb.addQuadCurve(to: pt(55,145), control: pt(70,130))
    hb.closeSubpath()
    ctx.fill(hb, with: .color(hairColor))

    // Hair front / fringe
    var hf = Path()
    hf.move(to: pt(65,95)); hf.addQuadCurve(to: pt(100,68), control: pt(80,70))
    hf.addQuadCurve(to: pt(135,95), control: pt(120,70))
    hf.addQuadCurve(to: pt(115,92), control: pt(125,90))
    hf.addQuadCurve(to: pt(85,92), control: pt(100,88))
    hf.addQuadCurve(to: pt(65,95), control: pt(75,90))
    ctx.fill(hf, with: .color(hairColor))

    // Eyes
    ctx.fill(Path(ellipseIn: CGRect(x: 83.5, y: 114.5, width: 5, height: 7)), with: .color(inkColor))
    ctx.fill(Path(ellipseIn: CGRect(x: 111.5, y: 114.5, width: 5, height: 7)), with: .color(inkColor))

    // Nose hint
    var nose = Path()
    nose.move(to: pt(95,138)); nose.addQuadCurve(to: pt(105,138), control: pt(100,142))
    ctx.stroke(nose, with: .color(neckShadow), lineWidth: 1.5)

    // Mouth
    var mo = Path()
    mo.move(to: pt(93,145)); mo.addQuadCurve(to: pt(107,145), control: pt(100,149))
    ctx.stroke(mo, with: .color(lipColor), lineWidth: 2)
}

// MARK: - Hair path builder (120×140 viewport)

private func buildHairPath(shape: HairShape, bg: Color) -> Path? {
    switch shape {
    case .bald:
        return nil
    case .buzzZero:
        return p("M40 56 Q 40 42, 60 40 Q 80 42, 80 56 Q 78 50, 70 51 Q 60 49, 50 51 Q 42 50, 40 56 Z")
    case .buzz:
        return p("M38 56 Q 38 40, 60 38 Q 82 40, 82 56 Q 78 51, 70 52 Q 60 50, 50 52 Q 42 51, 38 56 Z")
    case .crew:
        return p("M38 54 Q 38 38, 60 36 Q 82 38, 82 54 Q 78 47, 70 48 Q 60 46, 50 48 Q 42 47, 38 54 Z")
    case .caesar:
        return p("M38 60 Q 38 38, 60 36 Q 82 38, 82 60 L 82 58 Q 75 56, 60 56 Q 45 56, 38 58 Z")
    case .crop:
        return p("M37 58 Q 36 36, 60 33 Q 84 36, 83 58 Q 78 50, 72 52 Q 65 47, 50 50 Q 44 49, 37 58 Z")
    case .ivy:
        return p("M37 58 Q 36 36, 60 33 Q 84 36, 83 58 L 80 56 Q 70 50, 56 53 Q 48 51, 37 58 Z")
    case .pixie:
        return p("M37 60 Q 35 33, 60 30 Q 84 33, 83 60 Q 78 50, 72 53 Q 60 46, 48 53 Q 42 51, 37 60 Z")
    case .pixieFringe:
        var pth = p("M37 60 Q 35 33, 60 30 Q 84 33, 83 60 L 81 56 Q 65 52, 50 56 Q 42 53, 37 60 Z")
        pth.addPath(p("M44 47 Q 50 60, 60 60 Q 70 60, 76 47 Q 70 52, 60 52 Q 50 52, 44 47 Z"))
        return pth
    case .bixie:
        return p("M36 64 Q 33 32, 60 29 Q 87 32, 84 64 L 86 78 Q 76 72, 76 65 Q 60 58, 44 65 Q 44 72, 34 78 Z")
    case .bob:
        return p("M36 60 Q 32 32, 60 28 Q 88 32, 84 60 L 86 88 Q 76 76, 78 65 Q 60 56, 42 65 Q 44 76, 34 88 Z")
    case .bluntBob:
        return p("M34 60 Q 30 30, 60 26 Q 90 30, 86 60 L 88 92 L 32 92 Z")
    case .aBob:
        return p("M36 60 Q 32 32, 60 28 Q 88 32, 84 60 L 96 96 L 24 96 Z")
    case .frenchBob:
        var pth = p("M34 62 Q 30 32, 60 28 Q 90 32, 86 62 L 88 86 Q 76 80, 78 70 Q 60 60, 42 70 Q 44 80, 32 86 Z")
        pth.addPath(p("M40 50 Q 50 64, 60 64 Q 70 64, 80 50 Q 72 56, 60 57 Q 48 56, 40 50 Z"))
        return pth
    case .lob:
        return p("M34 60 Q 30 32, 60 28 Q 90 32, 86 60 L 90 110 Q 76 96, 78 70 Q 60 60, 42 70 Q 44 96, 30 110 Z")
    case .curlyLob:
        var pth = p("M30 60 Q 28 28, 60 24 Q 92 28, 90 60 L 94 110 Q 80 100, 80 70 Q 60 60, 40 70 Q 40 100, 26 110 Z")
        for c in [(28.0,72.0),(36.0,86.0),(26.0,98.0),(92.0,72.0),(84.0,86.0),(94.0,98.0)] {
            pth.addEllipse(in: CGRect(x: c.0-6, y: c.1-6, width: 12, height: 12))
        }
        return pth
    case .fringe:
        var pth = p("M34 60 Q 30 32, 60 28 Q 90 32, 86 60 L 90 100 Q 76 92, 78 68 Q 60 58, 42 68 Q 44 92, 30 100 Z")
        pth.addPath(p("M40 48 Q 50 66, 60 66 Q 70 66, 80 48 Q 72 58, 60 59 Q 48 58, 40 48 Z"))
        return pth
    case .shag:
        var pth = p("M32 60 Q 30 30, 60 26 Q 90 30, 88 60 L 92 108 Q 78 96, 80 70 Q 60 60, 40 70 Q 42 96, 28 108 Z")
        pth.addPath(p("M42 50 Q 50 64, 60 64 Q 70 64, 78 50 L 75 62 L 70 56 L 64 64 L 56 64 L 50 56 L 45 62 Z"))
        return pth
    case .layered:
        return p("M32 60 Q 30 30, 60 26 Q 90 30, 88 60 L 92 110 Q 78 98, 80 70 Q 60 60, 40 70 Q 42 98, 28 110 Z")
    case .wavyBob:
        return p("M32 60 Q 30 30, 60 26 Q 90 30, 88 60 Q 86 70, 92 78 Q 84 84, 88 96 Q 76 90, 78 70 Q 60 60, 42 70 Q 44 90, 32 96 Q 36 84, 28 78 Q 34 70, 32 60 Z")
    case .longLayers:
        return p("M30 60 Q 28 28, 60 24 Q 92 28, 90 60 L 96 132 Q 78 110, 80 70 Q 60 60, 40 70 Q 42 110, 24 132 Z")
    case .longWavy:
        var pth = p("M28 60 Q 26 26, 60 22 Q 94 26, 92 60 L 100 130 Q 80 116, 82 70 Q 60 60, 38 70 Q 40 116, 20 130 Z")
        for seg in [(22.0,100.0,30.0,108.0,24.0,116.0),(98.0,100.0,90.0,108.0,96.0,116.0)] {
            var lp = Path()
            lp.move(to: pt(seg.0, seg.1))
            lp.addQuadCurve(to: pt(seg.4, seg.5), control: pt(seg.2, seg.3))
            pth.addPath(lp)
        }
        return pth
    case .longStraight:
        return p("M30 60 Q 28 28, 60 24 Q 92 28, 90 60 L 92 134 L 28 134 Z")
    case .longCurly:
        var pth = p("M26 60 Q 24 26, 60 22 Q 96 26, 94 60 L 102 128 Q 80 116, 82 70 Q 60 60, 38 70 Q 40 116, 18 128 Z")
        for c in [(20.0,80.0),(16.0,96.0),(22.0,112.0),(14.0,124.0),(100.0,80.0),(104.0,96.0),(98.0,112.0),(106.0,124.0),(28.0,128.0),(92.0,128.0)] {
            pth.addEllipse(in: CGRect(x: c.0-7, y: c.1-7, width: 14, height: 14))
        }
        return pth
    case .bun:
        var pth = p("M32 60 Q 30 30, 60 26 Q 90 30, 88 60 L 92 100 Q 78 90, 80 70 Q 60 60, 40 70 Q 42 90, 28 100 Z")
        pth.addEllipse(in: CGRect(x: 46, y: 8, width: 28, height: 28))
        return pth
    case .ponytail:
        var pth = p("M32 60 Q 30 30, 60 26 Q 90 30, 88 60 L 92 96 Q 78 88, 80 70 Q 60 60, 40 70 Q 42 88, 28 96 Z")
        pth.addPath(p("M82 50 Q 110 70, 100 130 Q 92 130, 90 110 Q 88 90, 78 65 Z"))
        return pth
    case .fringeM:
        return p("M36 56 Q 35 33, 60 30 Q 85 33, 84 56 L 84 60 Q 65 60, 40 64 Z")
    case .slick:
        return p("M36 54 Q 60 28, 86 56 L 88 64 Q 76 56, 60 56 Q 44 56, 36 64 Z")
    case .pomp:
        return p("M36 56 Q 36 30, 60 22 Q 84 30, 84 56 Q 76 50, 60 50 Q 44 50, 36 56 Z")
    case .quiff:
        return p("M36 58 Q 30 28, 56 22 Q 78 18, 84 56 Q 76 50, 60 50 Q 44 50, 36 58 Z")
    case .tousled:
        return p("M34 58 Q 32 30, 60 26 Q 88 30, 86 58 L 88 70 Q 76 64, 78 60 Q 60 52, 42 60 Q 44 64, 32 70 Z")
    case .curtain:
        return p("M34 58 Q 32 30, 60 26 Q 88 30, 86 58 L 86 70 Q 76 60, 60 60 Q 44 60, 34 70 Z")
    case .longFlow:
        return p("M30 60 Q 28 28, 60 24 Q 92 28, 90 60 L 96 120 Q 80 108, 82 70 Q 60 60, 38 70 Q 40 108, 24 120 Z")
    case .manBun:
        var pth = p("M34 56 Q 32 32, 60 28 Q 88 32, 86 56 L 88 70 Q 76 64, 78 62 Q 60 54, 42 62 Q 44 64, 32 70 Z")
        pth.addEllipse(in: CGRect(x: 48, y: 10, width: 24, height: 24))
        return pth
    case .longWavyM:
        return p("M32 58 Q 30 30, 60 26 Q 90 30, 88 58 L 94 110 Q 78 100, 80 68 Q 60 58, 40 68 Q 42 100, 26 110 Z")
    }
}

private func buildCurlyDots(shape: HairShape) -> Path? { nil }

// MARK: - Tiny SVG-like path DSL

private func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }

// Parse "M x y Q cx cy, x y L x y Z" style strings
private func p(_ d: String) -> Path {
    var path = Path()
    var tokens = tokenize(d)
    var idx = 0

    func next() -> Double? {
        while idx < tokens.count, tokens[idx] == "," || tokens[idx] == "" { idx += 1 }
        guard idx < tokens.count, let v = Double(tokens[idx]) else { return nil }
        idx += 1
        return v
    }

    func nextPt() -> CGPoint? {
        guard let x = next(), let y = next() else { return nil }
        return CGPoint(x: x, y: y)
    }

    while idx < tokens.count {
        let tok = tokens[idx]
        if tok.isEmpty || tok == "," { idx += 1; continue }
        if let _ = Double(tok) {
            // bare number after implicit command — shouldn't happen in our data
            idx += 1; continue
        }
        idx += 1
        switch tok {
        case "M":
            if let p0 = nextPt() { path.move(to: p0) }
        case "L":
            if let p0 = nextPt() { path.addLine(to: p0) }
        case "Q":
            if let c = nextPt(), let e = nextPt() { path.addQuadCurve(to: e, control: c) }
        case "Z":
            path.closeSubpath()
        default:
            break
        }
    }
    return path
}

private func tokenize(_ d: String) -> [String] {
    // Insert spaces before letters, split on whitespace/comma
    var s = ""
    for ch in d {
        if ch.isLetter { s += " \(ch) " }
        else if ch == "," { s += " , " }
        else { s.append(ch) }
    }
    return s.components(separatedBy: .whitespaces).filter { !$0.isEmpty || $0 == "," }
}

import SwiftUI
import PhotosUI

// MARK: - 05 Capture

struct CaptureView: View {
    @EnvironmentObject var appState: AppState
    @State private var shooting = false
    @State private var flash = false
    @State private var showPicker = false
    @State private var selectedItem: PhotosPickerItem? = nil

    var body: some View {
        ZStack {
            // Dark viewfinder
            Color(hex: "0A0A09").ignoresSafeArea()
            RadialGradient(
                colors: [Color(hex: "2C2620"), Color(hex: "0A0A09")],
                center: .init(x: 0.5, y: 0.4), startRadius: 10, endRadius: 300
            ).ignoresSafeArea()

            // Face guide
            GeometryReader { geo in
                ZStack {
                    FaceCanvasView(hairHex: "3D2B1F", isDark: true)
                        .frame(width: 240, height: 300)
                        .clipShape(Ellipse())
                        .opacity(shooting ? 1 : 0.85)
                        .animation(.easeOut(duration: 0.2), value: shooting)
                        .position(x: geo.size.width / 2, y: geo.size.height * 0.42)

                    // Oval guide
                    Ellipse()
                        .stroke(Color.white.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [6, 8]))
                        .frame(width: 200, height: 270)
                        .position(x: geo.size.width / 2, y: geo.size.height * 0.42)

                    // Corner brackets
                    ForEach(corners, id: \.0) { (x, y, rot) in
                        CornerBracket()
                            .stroke(Color.white.opacity(0.85), lineWidth: 2)
                            .frame(width: 30, height: 30)
                            .rotationEffect(.degrees(rot))
                            .position(x: geo.size.width / 2 + x, y: geo.size.height * 0.42 + y)
                    }
                }
            }

            VStack(spacing: 0) {
                // Top controls
                HStack {
                    Button { appState.back() } label: {
                        Circle().fill(Color.white.opacity(0.18))
                            .frame(width: 40, height: 40)
                            .overlay(TZIcon("xmark", size: 18, color: .white))
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()

                    Text("Тримай обличчя в рамці")
                        .font(.tzSans(13, weight: .medium))
                        .kerning(-0.1)
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.18))
                        .clipShape(Capsule())

                    Spacer()

                    Circle().fill(Color.white.opacity(0.18))
                        .frame(width: 40, height: 40)
                        .overlay(TZIcon("bolt.fill", size: 18, color: .white))
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                Spacer()

                // Hint chips
                HStack(spacing: 8) {
                    ForEach(["✓ Освітлення", "✓ Обличчя", "⏵ Прямий погляд"], id: \.self) { t in
                        Text(t)
                            .font(.tzSans(12, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.16))
                            .clipShape(Capsule())
                    }
                }

                Spacer().frame(height: 40)

                // Shutter row
                HStack {
                    // Gallery picker
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.18))
                            .frame(width: 50, height: 50)
                            .overlay(TZIcon("photo", size: 22, color: .white))
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()

                    // Shutter button
                    Button { takePhoto() } label: {
                        ZStack {
                            Circle().stroke(Color.white, lineWidth: 3)
                            Circle().fill(Color.white)
                                .padding(5)
                                .scaleEffect(shooting ? 0.8 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: shooting)
                        }
                        .frame(width: 78, height: 78)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()

                    // Flip camera
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 50, height: 50)
                        .overlay(TZIcon("arrow.triangle.2.circlepath.camera", size: 20, color: .white))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }

            // Flash overlay
            if flash {
                Color.white.ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .onChange(of: selectedItem) { _ in
            appState.photoTaken = true
            if appState.gender == nil {
                appState.navigate(to: .gender)
            } else {
                appState.navigate(to: .gallery)
            }
        }
    }

    private func takePhoto() {
        withAnimation(.easeIn(duration: 0.05)) { flash = true }
        shooting = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.15)) { flash = false }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            appState.photoTaken = true
            if appState.gender == nil {
                appState.navigate(to: .gender)
            } else {
                appState.navigate(to: .gallery)
            }
        }
    }

    private let corners: [(CGFloat, CGFloat, Double)] = [
        (-100, -135, 0), (100, -135, 90), (-100, 135, 270), (100, 135, 180)
    ]
}

private struct CornerBracket: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: rect.maxY))
        p.addLine(to: CGPoint(x: 0, y: 0))
        p.addLine(to: CGPoint(x: rect.maxX, y: 0))
        return p
    }
}

// MARK: - 06 Gender Select

struct GenderSelectView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            Color.tzBg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                TZBackButton { appState.back() }
                    .padding(.horizontal, 28)
                    .padding(.top, 64)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Які стилі")
                        .font(.tzSerif(38))
                        .foregroundColor(.tzInk)
                        .kerning(-1.1)
                    Text("покажемо?")
                        .font(.tzSerif(38, italic: true))
                        .foregroundColor(.tzInk)
                        .kerning(-1.1)
                    Text("Це можна змінити будь-коли.")
                        .font(.tzSans(15))
                        .foregroundColor(.tzMuted)
                        .kerning(-0.2)
                        .padding(.top, 4)
                }
                .padding(.horizontal, 28)
                .padding(.top, 32)

                VStack(spacing: 14) {
                    GenderCard(
                        gender: .woman,
                        label: "Жіночі",
                        count: womenHairstyles.count,
                        hue: "A88563",
                        style: womenHairstyles[14]
                    )
                    GenderCard(
                        gender: .man,
                        label: "Чоловічі",
                        count: menHairstyles.count,
                        hue: "1A140F",
                        style: menHairstyles[4]
                    )
                }
                .padding(.horizontal, 28)
                .padding(.top, 32)

                Spacer()
            }
        }
    }
}

private struct GenderCard: View {
    @EnvironmentObject var appState: AppState
    let gender: HairGender
    let label: String
    let count: Int
    let hue: String
    let style: HairstyleItem

    var body: some View {
        Button {
            appState.gender = gender
            appState.navigate(to: .hairquiz)
        } label: {
            HStack(spacing: 0) {
                HairGlyphView(style: style)
                    .frame(width: 140)
                    .clipShape(RoundedRectangle(cornerRadius: .radiusXL, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.tzSerif(30))
                        .foregroundColor(.tzInk)
                        .kerning(-0.8)
                    Text("\(count) стилів")
                        .font(.tzSans(13))
                        .foregroundColor(.tzMuted)
                }
                .padding(24)

                Spacer()
                TZIcon("arrow.right", size: 20)
                    .padding(.trailing, 20)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(Color.tzSurface)
            .overlay(RoundedRectangle(cornerRadius: .radiusXL).stroke(Color.tzHairline))
            .clipShape(RoundedRectangle(cornerRadius: .radiusXL))
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - 07 Hair Quiz

struct HairQuizView: View {
    @EnvironmentObject var appState: AppState
    @State private var step = 0
    @State private var profile: HairProfile

    init() {
        _profile = State(initialValue: HairProfile())
    }

    private let questions = QuizQuestion.all

    var body: some View {
        let q = questions[step]

        ZStack {
            Color.tzBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header: back, progress bar, skip
                HStack(spacing: 12) {
                    TZBackButton {
                        if step == 0 { appState.back() }
                        else { withAnimation { step -= 1 } }
                    }
                    HStack(spacing: 4) {
                        ForEach(0..<questions.count, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(i <= step ? Color.tzInk : Color.tzHairlineStrong)
                                .frame(height: 3)
                                .animation(.easeInOut(duration: 0.25), value: step)
                        }
                    }
                    Button("Пропустити") {
                        appState.hairProfile = profile
                        appState.navigate(to: .gallery)
                    }
                    .font(.tzSans(13))
                    .foregroundColor(.tzMuted)
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)

                // Step label
                Text("Крок \(step + 1) з \(questions.count)")
                    .font(.tzSans(11, weight: .medium))
                    .kerning(1.5)
                    .textCase(.uppercase)
                    .foregroundColor(.tzMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 28)

                // Question
                VStack(alignment: .leading, spacing: 8) {
                    Text(q.title)
                        .font(.tzSerif(32))
                        .foregroundColor(.tzInk)
                        .kerning(-0.9)
                    Text(q.subtitle)
                        .font(.tzSans(14))
                        .foregroundColor(.tzMuted)
                        .kerning(-0.1)
                        .lineSpacing(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .id("q-\(step)")
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .animation(.easeOut(duration: 0.35), value: step)

                // Options
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(q.options) { opt in
                            QuizOptionButton(
                                option: opt,
                                isSelected: isSelected(key: q.key, value: opt.value),
                                onTap: { selectOption(key: q.key, value: opt.value) }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 8)
                }
                .id("o-\(step)")
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .animation(.easeOut(duration: 0.4).delay(0.06), value: step)

                TZPrimaryButton(title: step < questions.count - 1 ? "Далі" : "Готово", icon: "arrow.right") {
                    if step < questions.count - 1 {
                        withAnimation(.easeOut(duration: 0.35)) { step += 1 }
                    } else {
                        appState.hairProfile = profile
                        appState.navigate(to: .gallery)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
        }
    }

    private func isSelected(key: String, value: String) -> Bool {
        switch key {
        case "texture":      return profile.texture == value
        case "thickness":    return profile.thickness == value
        case "porosity":     return profile.porosity == value
        case "faceShape":    return profile.faceShape == value
        case "timeStyling":  return profile.timeStyling == value
        default: return false
        }
    }

    private func selectOption(key: String, value: String) {
        switch key {
        case "texture":     profile.texture = value
        case "thickness":   profile.thickness = value
        case "porosity":    profile.porosity = value
        case "faceShape":   profile.faceShape = value
        case "timeStyling": profile.timeStyling = value
        default: break
        }
    }
}

private struct QuizOptionButton: View {
    let option: QuizOption
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                QuizGlyphView(kind: option.glyphKind, value: option.value, isActive: isSelected)
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text(option.label)
                        .font(.tzSans(16, weight: .medium))
                        .kerning(-0.2)
                        .foregroundColor(isSelected ? .white : .tzInk)
                    Text(option.desc)
                        .font(.tzSans(12))
                        .foregroundColor(isSelected ? .white.opacity(0.7) : .tzMuted)
                }
                Spacer()
                Circle()
                    .stroke(isSelected ? Color.white : Color.tzHairlineStrong, lineWidth: 1.5)
                    .frame(width: 22, height: 22)
                    .overlay(
                        isSelected ? AnyView(TZIcon("checkmark", size: 11, color: .white, weight: .bold)) : AnyView(EmptyView())
                    )
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(isSelected ? Color.tzInk : Color.tzSurface)
            .overlay(RoundedRectangle(cornerRadius: .radiusMed)
                .stroke(isSelected ? Color.tzInk : Color.tzHairline))
            .clipShape(RoundedRectangle(cornerRadius: .radiusMed))
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.18), value: isSelected)
    }
}

// MARK: - Quiz data model

struct QuizQuestion: Identifiable {
    let id = UUID()
    let key: String
    let title: String
    let subtitle: String
    let options: [QuizOption]

    static let all: [QuizQuestion] = [
        QuizQuestion(key: "texture", title: "Яка текстура волосся?",
                     subtitle: "Коли волосся висихає природно — як воно лежить?",
                     options: [
                        QuizOption(value: "straight", label: "Прямі",     desc: "Без хвиль, гладкі",       glyphKind: "texture"),
                        QuizOption(value: "wavy",     label: "Хвилясті",  desc: "Легка S-форма",           glyphKind: "texture"),
                        QuizOption(value: "curly",    label: "Кучеряві",  desc: "Виражені кучері",         glyphKind: "texture"),
                        QuizOption(value: "coily",    label: "Спіральні", desc: "Тугі завитки",            glyphKind: "texture"),
                     ]),
        QuizQuestion(key: "thickness", title: "Густина волосся?",
                     subtitle: "Зроби хвостик — наскільки він товстий?",
                     options: [
                        QuizOption(value: "thin",   label: "Тонке",    desc: "Хвостик ~1.5 см",  glyphKind: "thickness"),
                        QuizOption(value: "medium", label: "Середнє",  desc: "Хвостик ~2.5 см",  glyphKind: "thickness"),
                        QuizOption(value: "thick",  label: "Густе",    desc: "Хвостик 4+ см",    glyphKind: "thickness"),
                     ]),
        QuizQuestion(key: "porosity", title: "Як швидко волосся вбирає воду?",
                     subtitle: "Це впливає на стайлінг і вибір продуктів",
                     options: [
                        QuizOption(value: "low",    label: "Повільно",  desc: "Волосся вологе довго",     glyphKind: "porosity"),
                        QuizOption(value: "normal", label: "Нормально", desc: "Висихає за 1–2 год",       glyphKind: "porosity"),
                        QuizOption(value: "high",   label: "Швидко",    desc: "Висихає миттєво, пушиться", glyphKind: "porosity"),
                     ]),
        QuizQuestion(key: "faceShape", title: "Форма обличчя",
                     subtitle: "AI підтвердить, але обери що тобі ближче",
                     options: [
                        QuizOption(value: "oval",   label: "Овальна",   desc: "Збалансована",    glyphKind: "faceShape"),
                        QuizOption(value: "round",  label: "Кругла",    desc: "М'які лінії",     glyphKind: "faceShape"),
                        QuizOption(value: "square", label: "Квадратна", desc: "Виразна щелепа",  glyphKind: "faceShape"),
                        QuizOption(value: "heart",  label: "Серце",     desc: "Широке чоло",     glyphKind: "faceShape"),
                        QuizOption(value: "long",   label: "Видовжена", desc: "Висока та вузька", glyphKind: "faceShape"),
                     ]),
        QuizQuestion(key: "timeStyling", title: "Скільки часу на укладку зранку?",
                     subtitle: "Підбираємо стилі під твій ритм",
                     options: [
                        QuizOption(value: "<5",   label: "< 5 хв",   desc: "Помив — пішов",        glyphKind: "timeStyling"),
                        QuizOption(value: "5-15", label: "5–15 хв",  desc: "Швидкий стайлінг",     glyphKind: "timeStyling"),
                        QuizOption(value: "15-30",label: "15–30 хв", desc: "Завжди акуратно",      glyphKind: "timeStyling"),
                        QuizOption(value: "30+",  label: "30+ хв",   desc: "Стиль = ритуал",       glyphKind: "timeStyling"),
                     ]),
    ]
}

struct QuizOption: Identifiable {
    let id = UUID()
    let value: String
    let label: String
    let desc: String
    let glyphKind: String
}

// MARK: - Quiz glyph mini-icon (Canvas)

struct QuizGlyphView: View {
    let kind: String
    let value: String
    let isActive: Bool

    var body: some View {
        Canvas { ctx, size in
            let fg = isActive ? Color.white : Color.tzInk
            let bg = isActive ? Color.white.opacity(0.3) : Color.tzHairline
            ctx.fill(Path(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 12), with: .color(bg))
            drawQuizGlyph(&ctx, size: size, kind: kind, value: value, fg: fg)
        }
    }
}

private func drawQuizGlyph(_ ctx: inout GraphicsContext, size: CGSize, kind: String, value: String, fg: Color) {
    let lw: CGFloat = 1.6
    let w = size.width, h = size.height
    switch kind {
    case "texture":
        let xs: [CGFloat] = [w*0.32, w*0.5, w*0.68]
        switch value {
        case "straight":
            for x in xs {
                var lp = Path(); lp.move(to: CGPoint(x:x,y:h*0.22)); lp.addLine(to: CGPoint(x:x,y:h*0.78))
                ctx.stroke(lp, with: .color(fg), lineWidth: lw)
            }
        case "wavy":
            for x in xs {
                var lp = Path()
                lp.move(to: CGPoint(x:x,y:h*0.22))
                lp.addQuadCurve(to: CGPoint(x:x,y:h*0.5), control: CGPoint(x:x+6,y:h*0.36))
                lp.addQuadCurve(to: CGPoint(x:x,y:h*0.78), control: CGPoint(x:x-6,y:h*0.64))
                ctx.stroke(lp, with: .color(fg), lineWidth: lw)
            }
        case "curly":
            for x in xs {
                var lp = Path()
                lp.move(to: CGPoint(x:x,y:h*0.22))
                lp.addQuadCurve(to: CGPoint(x:x,y:h*0.5), control: CGPoint(x:x+8,y:h*0.32))
                lp.addQuadCurve(to: CGPoint(x:x,y:h*0.5), control: CGPoint(x:x-8,y:h*0.36))
                lp.addQuadCurve(to: CGPoint(x:x,y:h*0.78), control: CGPoint(x:x+8,y:h*0.62))
                ctx.stroke(lp, with: .color(fg), lineWidth: lw)
            }
        default: // coily
            for (i, x) in [w*0.36, w*0.64].enumerated() {
                for j in 0..<4 {
                    let y = h*0.26 + CGFloat(j)*h*0.16
                    ctx.stroke(Path(ellipseIn: CGRect(x:x-4,y:y-4,width:8,height:8)),
                               with: .color(fg), lineWidth: lw)
                    _ = i
                }
            }
        }
    case "thickness":
        let ww: CGFloat = value == "thin" ? 4 : value == "medium" ? 8 : 16
        ctx.fill(Path(roundedRect: CGRect(x: w/2-ww/2, y: h*0.22, width: ww, height: h*0.56), cornerRadius: ww/2), with: .color(fg))
    case "porosity":
        var drop = Path()
        drop.move(to: CGPoint(x:w*0.5,y:h*0.2))
        drop.addQuadCurve(to: CGPoint(x:w*0.64,y:h*0.42), control: CGPoint(x:w*0.68,y:h*0.3))
        drop.addQuadCurve(to: CGPoint(x:w*0.5,y:h*0.55), control: CGPoint(x:w*0.64,y:h*0.54))
        drop.addQuadCurve(to: CGPoint(x:w*0.36,y:h*0.42), control: CGPoint(x:w*0.36,y:h*0.54))
        drop.addQuadCurve(to: CGPoint(x:w*0.5,y:h*0.2), control: CGPoint(x:w*0.32,y:h*0.3))
        ctx.fill(drop, with: .color(fg))
        let drips: Int = value == "low" ? 1 : value == "normal" ? 2 : 5
        for i in 0..<drips {
            let x = w*0.3 + CGFloat(i) * (w*0.4 / max(1, CGFloat(drips-1)))
            var lp = Path(); lp.move(to: CGPoint(x:x,y:h*0.62)); lp.addLine(to: CGPoint(x:x,y:h*0.78))
            ctx.stroke(lp, with: .color(fg), lineWidth: lw)
        }
    case "faceShape":
        switch value {
        case "oval":   ctx.stroke(Path(ellipseIn: CGRect(x:w*0.27,y:h*0.15,width:w*0.46,height:h*0.7)), with: .color(fg), lineWidth: lw)
        case "round":  ctx.stroke(Path(ellipseIn: CGRect(x:w*0.22,y:h*0.22,width:w*0.56,height:h*0.56)), with: .color(fg), lineWidth: lw)
        case "square":
            ctx.stroke(Path(roundedRect: CGRect(x:w*0.24,y:h*0.22,width:w*0.52,height:h*0.52), cornerRadius: 3), with: .color(fg), lineWidth: lw)
        case "heart":
            var hp = Path()
            hp.move(to: CGPoint(x:w*0.5,y:h*0.78))
            hp.addQuadCurve(to: CGPoint(x:w*0.27,y:h*0.42), control: CGPoint(x:w*0.27,y:h*0.22))
            hp.addQuadCurve(to: CGPoint(x:w*0.5,y:h*0.42), control: CGPoint(x:w*0.5,y:h*0.22))
            hp.addQuadCurve(to: CGPoint(x:w*0.73,y:h*0.42), control: CGPoint(x:w*0.5,y:h*0.22))
            hp.addQuadCurve(to: CGPoint(x:w*0.5,y:h*0.78), control: CGPoint(x:w*0.73,y:h*0.22))
            ctx.stroke(hp, with: .color(fg), lineWidth: lw)
        default: // long
            ctx.stroke(Path(ellipseIn: CGRect(x:w*0.32,y:h*0.12,width:w*0.36,height:h*0.76)), with: .color(fg), lineWidth: lw)
        }
    case "timeStyling":
        ctx.stroke(Path(ellipseIn: CGRect(x:w*0.22,y:h*0.22,width:w*0.56,height:h*0.56)), with: .color(fg), lineWidth: lw)
        let handLengths: [String: (CGFloat, CGFloat)] = ["<5":(0.3,0.22),"5-15":(0.2,0.2),"15-30":(0.08,0.18),"30+":(0.0,0.16)]
        if let lens = handLengths[value] {
            var hand = Path()
            hand.move(to: CGPoint(x:w*0.5, y:h*0.5))
            hand.addLine(to: CGPoint(x:w*0.5, y:h*(0.5 - lens.1)))
            ctx.stroke(hand, with: .color(fg), lineWidth: lw)
            var hand2 = Path()
            hand2.move(to: CGPoint(x:w*0.5, y:h*0.5))
            hand2.addLine(to: CGPoint(x:w*(0.5 + lens.0), y:h*0.6))
            ctx.stroke(hand2, with: .color(fg), lineWidth: lw)
        }
    default: break
    }
}

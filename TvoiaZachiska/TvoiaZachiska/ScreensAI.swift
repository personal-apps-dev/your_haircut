import SwiftUI

// MARK: - 10 Analyzing

struct AnalyzingView: View {
    @EnvironmentObject var appState: AppState
    @State private var stage = 0
    @State private var scanOffset: CGFloat = -60
    @State private var apiTask: Task<Void, Never>? = nil

    private let stages = [
        "Аналіз обличчя",
        "Визначення типу волосся",
        "Підбір сумісності",
        "Готуємо рекомендації",
    ]

    var body: some View {
        ZStack {
            Color.tzBg.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button { appState.back() } label: {
                        Circle()
                            .fill(Color.tzSurfaceMuted)
                            .frame(width: 36, height: 36)
                            .overlay(TZIcon("xmark", size: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 28)
                .padding(.top, 60)

                Spacer()

                // Scanning portrait
                ZStack {
                    FaceCanvasView(hairHex: appState.selectedStyle?.hue ?? "3D2B1F")
                        .frame(width: 220, height: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 28))

                    // Scan line
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.4), .clear],
                        startPoint: .top, endPoint: .bottom
                    )
                    .frame(width: 220, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .offset(y: scanOffset)
                    .clipped()
                    .frame(width: 220, height: 280, alignment: .top)
                    .clipShape(RoundedRectangle(cornerRadius: 28))

                    // Grid overlay
                    GridOverlay()
                        .frame(width: 220, height: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .opacity(0.4)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 0) {
                    (Text("AI ").font(.tzSerif(28))
                     + Text("аналізує\n").font(.tzSerif(28, italic: true))
                     + Text("твій тип").font(.tzSerif(28)))
                        .foregroundColor(.tzInk)
                        .kerning(-0.8)
                        .lineSpacing(2)
                        .padding(.bottom, 20)

                    ForEach(Array(stages.enumerated()), id: \.offset) { idx, s in
                        HStack(spacing: 12) {
                            ZStack {
                                if idx < stage {
                                    Circle().fill(Color.tzInk)
                                        .frame(width: 22, height: 22)
                                    TZIcon("checkmark", size: 11, color: .white, weight: .bold)
                                } else if idx == stage {
                                    Circle()
                                        .stroke(Color.tzHairlineStrong, lineWidth: 1.5)
                                        .frame(width: 22, height: 22)
                                    PulsingDot()
                                } else {
                                    Circle()
                                        .stroke(Color.tzHairlineStrong, lineWidth: 1.5)
                                        .frame(width: 22, height: 22)
                                }
                            }
                            .frame(width: 22, height: 22)

                            Text(s)
                                .font(.tzSans(14, weight: idx == stage ? .semibold : .regular))
                                .kerning(-0.1)
                                .foregroundColor(.tzInk)
                        }
                        .padding(.vertical, 10)
                        .opacity(idx > stage ? 0.3 : 1)
                        .animation(.easeInOut(duration: 0.25), value: stage)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28)
                .padding(.bottom, 40)
            }
        }
        .onAppear { startAnalysis() }
        .onDisappear { apiTask?.cancel() }
    }

    private func startAnalysis() {
        withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
            scanOffset = 280
        }

        // Reset previous result
        appState.analysisResult = nil
        appState.apiError = nil

        // Run animation + (optional) API call concurrently. Navigate when both are done.
        apiTask = Task {
            async let animationDone: () = runStageAnimation()

            if let key = appState.apiKey, !key.isEmpty,
               let img = appState.capturedImage,
               let style = appState.selectedStyle {
                do {
                    let client = AnthropicClient(apiKey: key)
                    let result = try await client.analyzeHairstyle(image: img, hairstyle: style)
                    await MainActor.run { appState.analysisResult = result }
                } catch {
                    await MainActor.run {
                        appState.apiError = error.localizedDescription
                    }
                }
            }

            _ = await animationDone
            await MainActor.run {
                if !Task.isCancelled { appState.navigate(to: .result) }
            }
        }
    }

    @MainActor
    private func runStageAnimation() async {
        for i in 1..<stages.count {
            try? await Task.sleep(nanoseconds: 700_000_000)
            withAnimation { stage = i }
        }
        try? await Task.sleep(nanoseconds: 800_000_000)
    }
}

private struct PulsingDot: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.6

    var body: some View {
        Circle()
            .fill(Color.tzInk)
            .frame(width: 8, height: 8)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                    scale = 1.1; opacity = 1
                }
            }
    }
}

private struct GridOverlay: View {
    var body: some View {
        Canvas { ctx, size in
            let strokeStyle = StrokeStyle(lineWidth: 0.5, dash: [2, 4])
            let color = GraphicsContext.Shading.color(.white)
            for y in [size.height * 0.43, size.height * 0.57, size.height * 0.71] {
                var l = Path(); l.move(to: CGPoint(x: 20, y: y)); l.addLine(to: CGPoint(x: size.width - 20, y: y))
                ctx.stroke(l, with: color, style: strokeStyle)
            }
            for x in [size.width * 0.27, size.width * 0.5, size.width * 0.73] {
                var l = Path(); l.move(to: CGPoint(x: x, y: 40)); l.addLine(to: CGPoint(x: x, y: size.height - 40))
                ctx.stroke(l, with: color, style: strokeStyle)
            }
            // Anchor dots
            for pos in [(size.width*0.27, size.height*0.5), (size.width*0.5, size.height*0.5),
                        (size.width*0.73, size.height*0.5), (size.width*0.39, size.height*0.62),
                        (size.width*0.61, size.height*0.62), (size.width*0.5, size.height*0.74)] {
                ctx.fill(Path(ellipseIn: CGRect(x: pos.0-3, y: pos.1-3, width: 6, height: 6)), with: color)
            }
        }
    }
}

// MARK: - 11 Result

struct ResultView: View {
    @EnvironmentObject var appState: AppState
    @State private var displayedScore: Double = 0

    private var style: HairstyleItem {
        appState.selectedStyle ?? (hairstyles(for: appState.gender ?? .woman).first!)
    }

    private static let mockBreakdown: [(label: String, value: Int, note: String)] = [
        ("Форма обличчя", 92, "Овальна — підходить майже все"),
        ("Тип волосся",   85, "Середня густина, легка хвиля"),
        ("Стиль",         88, "Узгоджується з твоїм гардеробом"),
        ("Догляд",        78, "~15 хв ранкового стайлінгу"),
    ]

    private static let mockTips = [
        "Текстуруючий спрей надасть бажаний обʼєм біля коренів.",
        "Запитай майстра про точкове філіювання — підкреслить шари.",
        "Використовуй термозахист перед укладкою феном.",
    ]

    private var breakdown: [(label: String, value: Int, note: String)] {
        if let real = appState.analysisResult {
            return real.breakdown.map { ($0.label, $0.value, $0.note) }
        }
        return Self.mockBreakdown
    }

    private var tips: [String] {
        appState.analysisResult?.tips ?? Self.mockTips
    }

    private var displayedMatch: Int {
        appState.analysisResult?.matchScore ?? style.match
    }

    private var alts: [HairstyleItem] {
        hairstyles(for: appState.gender ?? .woman).filter { $0.id != style.id }.prefix(3).map { $0 }
    }

    private var matchLabel: String {
        if let real = appState.analysisResult { return real.matchLabel }
        return displayedMatch >= 85 ? "дуже личить" : displayedMatch >= 75 ? "добре пасує" : "пасує помірно"
    }

    var body: some View {
        ZStack {
            Color.tzBg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Hero top bar
                    HStack {
                        Button {
                            withAnimation(.easeOut(duration: 0.2)) {
                                appState.back()
                            }
                        } label: {
                            Circle()
                                .fill(Color.white.opacity(0.7))
                                .frame(width: 40, height: 40)
                                .overlay(TZIcon("arrow.left", size: 18))
                        }
                        .buttonStyle(PlainButtonStyle())

                        Spacer()
                        HStack(spacing: 8) {
                            Button { appState.toggleFavorite(style.id) } label: {
                                Circle()
                                    .fill(Color.white.opacity(0.7))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Image(systemName: appState.favorites.contains(style.id) ? "heart.fill" : "heart")
                                            .foregroundColor(appState.favorites.contains(style.id) ? .tzRed : .tzInk)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            Circle()
                                .fill(Color.white.opacity(0.7))
                                .frame(width: 40, height: 40)
                                .overlay(TZIcon("square.and.arrow.up", size: 16))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)

                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text(appState.analysisResult != nil ? "AI-аналіз · повний звіт" : "Демо-аналіз · додай API ключ")
                            .font(.tzSans(11, weight: .medium))
                            .kerning(1.5)
                            .textCase(.uppercase)
                            .foregroundColor(.tzMuted)

                        (Text(style.name).font(.tzSerif(36, italic: true))
                         + Text(" тобі\n").font(.tzSerif(36))
                         + Text(matchLabel).font(.tzSerif(36)))
                            .foregroundColor(.tzInk)
                            .kerning(-1)
                            .lineSpacing(2)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    // API error banner
                    if let err = appState.apiError {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.tzWarn)
                                .font(.system(size: 14))
                                .padding(.top, 1)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("AI-аналіз не вдалося виконати")
                                    .font(.tzSans(13, weight: .semibold))
                                    .foregroundColor(.tzInk)
                                Text(err)
                                    .font(.tzSans(12))
                                    .foregroundColor(.tzMuted)
                                    .lineLimit(3)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(12)
                        .background(Color.tzWarn.opacity(0.08))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.tzWarn.opacity(0.3)))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                    }

                    // Portrait + score ring
                    HStack(alignment: .center, spacing: 16) {
                        Group {
                            if let img = appState.capturedImage {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                FaceCanvasView(hairHex: style.hue)
                            }
                        }
                        .frame(width: 130, height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                        ScoreRingView(value: displayedScore, max: displayedMatch)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    // Breakdown section
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .lastTextBaseline) {
                            SectionHeading(serif: "Розбивка", plain: "аналізу")
                            Spacer()
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    appState.analysisStyle = appState.analysisStyle == .detailed ? .minimal : .detailed
                                }
                            } label: {
                                Text(appState.analysisStyle == .detailed ? "Компактно" : "Детально")
                                    .font(.tzSans(12))
                                    .foregroundColor(.tzMuted)
                            }
                        }

                        if appState.analysisStyle == .detailed {
                            VStack(spacing: 14) {
                                ForEach(breakdown, id: \.label) { b in
                                    DetailedBreakdownCard(label: b.label, value: b.value, note: b.note)
                                }
                            }
                        } else {
                            VStack(spacing: 0) {
                                ForEach(Array(breakdown.enumerated()), id: \.element.label) { idx, b in
                                    HStack {
                                        Text(b.label)
                                            .font(.tzSans(14))
                                            .foregroundColor(.tzInk)
                                            .kerning(-0.1)
                                        Spacer()
                                        (Text("\(b.value)").font(.tzSerif(18))
                                         + Text("/100").font(.tzSans(11)))
                                            .foregroundColor(.tzInk)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 14)
                                    if idx < breakdown.count - 1 {
                                        Divider().padding(.leading, 14)
                                    }
                                }
                            }
                            .background(Color.tzSurface)
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.tzHairline))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)

                    // Tips section
                    if appState.analysisStyle == .detailed {
                        VStack(alignment: .leading, spacing: 14) {
                            SectionHeading(serif: "Поради", plain: "від AI")

                            ZStack {
                                Color.tzInk
                                VStack(alignment: .leading, spacing: 12) {
                                    TZIcon("sparkles", size: 24, color: .white)
                                    ForEach(Array(tips.enumerated()), id: \.offset) { idx, tip in
                                        HStack(alignment: .top, spacing: 10) {
                                            Text("0\(idx + 1)")
                                                .font(.tzSerif(18))
                                                .foregroundColor(.white.opacity(0.4))
                                                .frame(width: 28, alignment: .leading)
                                            Text(tip)
                                                .font(.tzSans(14))
                                                .foregroundColor(.white.opacity(0.95))
                                                .kerning(-0.1)
                                                .lineSpacing(3)
                                        }
                                    }
                                }
                                .padding(20)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                    }

                    // Alternatives
                    VStack(alignment: .leading, spacing: 14) {
                        SectionHeading(serif: "Альтернативи,", plain: "що теж личать")

                        HStack(spacing: 10) {
                            ForEach(alts) { alt in
                                Button {
                                    appState.selectedStyle = alt
                                    appState.navigate(to: .preview)
                                } label: {
                                    VStack(alignment: .leading, spacing: 6) {
                                        HairGlyphView(style: alt)
                                            .aspectRatio(0.85, contentMode: .fill)
                                            .clipShape(RoundedRectangle(cornerRadius: 14))
                                        Text(alt.name)
                                            .font(.tzSans(12, weight: .medium))
                                            .foregroundColor(.tzInk)
                                            .kerning(-0.1)
                                            .lineLimit(1)
                                        Text("\(alt.match)% match")
                                            .font(.tzSans(11))
                                            .foregroundColor(.tzMuted)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)

                    // CTA
                    HStack(spacing: 10) {
                        TZGhostButton(title: "Назад") { appState.back() }
                        TZPrimaryButton(title: "Зберегти", icon: "heart") {
                            appState.saved.insert(SavedItem(styleId: style.id, date: "Щойно"), at: 0)
                            appState.navigate(to: .saved)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: 1.4)) {
                    displayedScore = Double(displayedMatch)
                }
            }
        }
    }
}

private struct DetailedBreakdownCard: View {
    let label: String
    let value: Int
    let note: String
    @State private var progressWidth: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .lastTextBaseline) {
                Text(label)
                    .font(.tzSans(14, weight: .medium))
                    .foregroundColor(.tzInk)
                Spacer()
                (Text("\(value)").font(.tzSerif(22))
                 + Text("/100").font(.tzSans(12)))
                    .foregroundColor(.tzInk)
                    .kerning(-0.4)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2).fill(Color.tzSurfaceMuted)
                    RoundedRectangle(cornerRadius: 2).fill(Color.tzInk)
                        .frame(width: geo.size.width * CGFloat(value) / 100)
                        .animation(.easeOut(duration: 0.8), value: value)
                }
            }
            .frame(height: 4)
            .padding(.top, 8)

            Text(note)
                .font(.tzSans(13))
                .foregroundColor(.tzMuted)
                .lineSpacing(2)
                .kerning(-0.1)
                .padding(.top, 10)
        }
        .padding(16)
        .background(Color.tzSurface)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.tzHairline))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

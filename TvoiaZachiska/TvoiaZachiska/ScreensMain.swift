import SwiftUI

// MARK: - 01 Splash

struct SplashView: View {
    @EnvironmentObject var appState: AppState
    @State private var progress: CGFloat = 0
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.tzBg.ignoresSafeArea()

            VStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("Твоя")
                        .font(.tzSerif(56, italic: true))
                        .foregroundColor(.tzInk)
                    Text("Зачіска")
                        .font(.tzSerif(56))
                        .foregroundColor(.tzInk)
                }
                .kerning(-1.5)
                .multilineTextAlignment(.center)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
                .animation(.easeOut(duration: 0.8), value: appeared)

                Text("AI · стиль · тобі")
                    .font(.tzSans(13, weight: .medium))
                    .kerning(2)
                    .textCase(.uppercase)
                    .foregroundColor(.tzMuted)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.8).delay(0.2), value: appeared)
            }

            // Progress bar at bottom
            VStack {
                Spacer()
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.tzHairlineStrong)
                        .frame(width: 80, height: 2)
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.tzInk)
                        .frame(width: 80 * progress, height: 2)
                        .animation(.easeOut(duration: 1.8), value: progress)
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            appeared = true
            progress = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                appState.navigate(to: .onboard)
            }
        }
    }
}

// MARK: - 02 Onboarding

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var step = 0

    private struct OnboardStep {
        let title: String
        let body: String
        let glyph: String // "photo" | "sparkle" | "gallery"
    }

    private let steps: [OnboardStep] = [
        OnboardStep(title: "Знайди свій образ",
                    body: "Завантаж фото та поглянь на себе з різними зачісками — без походу в салон.",
                    glyph: "photo"),
        OnboardStep(title: "AI підкаже найкраще",
                    body: "Аналізуємо форму обличчя, тип волосся й риси, щоб порекомендувати ідеальний варіант.",
                    glyph: "sparkle"),
        OnboardStep(title: "Колекція стилів",
                    body: "Сотні зачісок для жінок та чоловіків — від класики до сміливих експериментів.",
                    glyph: "gallery"),
    ]

    var body: some View {
        ZStack {
            Color.tzBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip
                HStack {
                    Spacer()
                    Button("Пропустити") { appState.navigate(to: .permission) }
                        .font(.tzSans(14))
                        .foregroundColor(.tzMuted)
                }
                .padding(.horizontal, 28)
                .padding(.top, 64)
                .padding(.bottom, 8)

                // Illustration
                ZStack {
                    OnboardGlyphView(glyph: steps[step].glyph)
                        .id(step)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 280)
                .animation(.easeOut(duration: 0.4), value: step)

                Spacer()

                // Text
                VStack(alignment: .leading, spacing: 12) {
                    Text(steps[step].title)
                        .font(.tzSerif(36))
                        .foregroundColor(.tzInk)
                        .kerning(-1)
                        .id("title-\(step)")
                        .transition(.move(edge: .bottom).combined(with: .opacity))

                    Text(steps[step].body)
                        .font(.tzSans(16))
                        .foregroundColor(.tzMuted)
                        .kerning(-0.1)
                        .lineSpacing(4)
                        .id("body-\(step)")
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .padding(.horizontal, 28)
                .animation(.easeOut(duration: 0.4).delay(0.08), value: step)

                // Dots + next
                HStack(spacing: 16) {
                    HStack(spacing: 6) {
                        ForEach(0..<steps.count, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(i == step ? Color.tzInk : Color.tzHairlineStrong)
                                .frame(width: i == step ? 22 : 6, height: 6)
                                .animation(.easeInOut(duration: 0.22), value: step)
                        }
                    }
                    Spacer()
                    Button {
                        if step < steps.count - 1 {
                            withAnimation { step += 1 }
                        } else {
                            appState.navigate(to: .permission)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text(step < steps.count - 1 ? "Далі" : "Почати")
                                .font(.tzSans(15, weight: .medium))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .frame(height: 56)
                        .background(Color.tzInk)
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 32)
                .padding(.bottom, 40)
            }
        }
    }
}

// Illustration views
private struct OnboardGlyphView: View {
    let glyph: String

    var body: some View {
        ZStack {
            if glyph == "photo" {
                PhotoGlyphView()
            } else if glyph == "sparkle" {
                SparkleGlyphView()
            } else {
                GalleryGlyphIllustration()
            }
        }
        .frame(width: 220, height: 260)
    }
}

private struct PhotoGlyphView: View {
    var body: some View {
        ZStack {
            // Polaroid card (tilted)
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.tzHairlineStrong))
                .frame(width: 140, height: 170)
                .rotationEffect(.degrees(-6))
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.tzSurfaceMuted)
                .frame(width: 120, height: 135)
                .rotationEffect(.degrees(-6))
                .offset(y: -8)
            // Face inside
            HairGlyphView(style: womenHairstyles[0])
                .frame(width: 80, height: 90)
                .rotationEffect(.degrees(-6))
                .offset(y: -8)
            // Camera icon top-right
            Circle()
                .stroke(Color.tzInk, lineWidth: 1.5)
                .frame(width: 16, height: 16)
                .overlay(Circle().fill(Color.tzInk).frame(width: 6, height: 6))
                .offset(x: 62, y: -70)
        }
    }
}

private struct SparkleGlyphView: View {
    @State private var twinkling = false

    var body: some View {
        ZStack {
            Circle().stroke(Color.tzHairlineStrong, lineWidth: 1).frame(width: 136, height: 136)
            Circle().fill(Color.tzInk).frame(width: 84, height: 84)
            HairGlyphView(style: womenHairstyles[3]).frame(width: 56, height: 56)
            ForEach(Array(sparklePositions.enumerated()), id: \.offset) { idx, pos in
                SparkleShape()
                    .fill(Color.tzInk)
                    .frame(width: 14, height: 14)
                    .offset(x: pos.x, y: pos.y)
                    .scaleEffect(twinkling ? 1.0 : 0.7)
                    .opacity(twinkling ? 1.0 : 0.3)
                    .animation(
                        Animation.easeInOut(duration: 2)
                            .repeatForever(autoreverses: true)
                            .delay(Double(idx) * 0.2),
                        value: twinkling)
            }
        }
        .onAppear { twinkling = true }
    }

    private let sparklePositions: [(x: CGFloat, y: CGFloat)] = [
        (-68, -70), (70, -60), (72, 70), (-70, 72), (0, -90), (0, 90),
    ]
}

private struct SparkleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let r = rect.width / 2
        var p = Path()
        p.move(to: CGPoint(x: c.x, y: c.y - r))
        p.addLine(to: CGPoint(x: c.x + r*0.2, y: c.y - r*0.2))
        p.addLine(to: CGPoint(x: c.x + r, y: c.y))
        p.addLine(to: CGPoint(x: c.x + r*0.2, y: c.y + r*0.2))
        p.addLine(to: CGPoint(x: c.x, y: c.y + r))
        p.addLine(to: CGPoint(x: c.x - r*0.2, y: c.y + r*0.2))
        p.addLine(to: CGPoint(x: c.x - r, y: c.y))
        p.addLine(to: CGPoint(x: c.x - r*0.2, y: c.y - r*0.2))
        p.closeSubpath()
        return p
    }
}

private struct GalleryGlyphIllustration: View {
    private let cards: [(x: CGFloat, y: CGFloat, h: CGFloat, hue: String)] = [
        (-55, -45, 90, "3D2B1F"),
        ( 25, -55, 100, "A88563"),
        (-55,  60, 80, "1A140F"),
        ( 25,  60, 80, "5B4030"),
    ]

    var body: some View {
        ZStack {
            ForEach(Array(cards.enumerated()), id: \.offset) { idx, c in
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.tzSurfaceMuted)
                    .frame(width: 70, height: c.h)
                    .offset(x: c.x, y: c.y)
                HairGlyphView(style: womenHairstyles[idx * 3])
                    .frame(width: 50, height: CGFloat(Int(c.h * 0.6)))
                    .offset(x: c.x, y: c.y)
            }
        }
    }
}

// MARK: - 03 Permission

struct PermissionView: View {
    @EnvironmentObject var appState: AppState
    @State private var granted = false

    var body: some View {
        ZStack {
            Color.tzBg.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    TZBackButton { appState.back() }
                    Spacer()
                }
                .padding(.horizontal, 28)
                .padding(.top, 64)

                Spacer()

                // Camera icon with pulse rings
                ZStack {
                    Circle()
                        .stroke(Color.tzHairlineStrong, lineWidth: 1)
                        .frame(width: 170, height: 170)
                        .pulseLoop(delay: 0)
                    Circle()
                        .stroke(Color.tzHairlineStrong, lineWidth: 1)
                        .frame(width: 210, height: 210)
                        .pulseLoop(delay: 0.6)
                    Circle()
                        .fill(Color.tzInk)
                        .frame(width: 130, height: 130)
                        .overlay(
                            Image(systemName: "camera")
                                .font(.system(size: 50, weight: .light))
                                .foregroundColor(.white)
                        )
                }

                Spacer()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Доступ до камери")
                        .font(.tzSerif(32))
                        .foregroundColor(.tzInk)
                        .kerning(-1)

                    Text("Потрібен, щоб робити фото для примірювання зачісок. Знімки залишаються на вашому пристрої.")
                        .font(.tzSans(15))
                        .foregroundColor(.tzMuted)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 32)

                VStack(spacing: 12) {
                    TZPrimaryButton(title: granted ? "✓ Дозволено" : "Надати доступ") {
                        granted = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            appState.navigate(to: .home)
                        }
                    }
                    TZGhostButton(title: "Завантажити з галереї натомість") {
                        appState.navigate(to: .home)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - 04 Home

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    private let recents = Array(womenHairstyles.prefix(4))

    var body: some View {
        ZStack {
            Color.tzBg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Top bar
                    HStack {
                        Text("П'ятниця, 30 квітня")
                            .font(.tzSans(13, weight: .medium))
                            .kerning(1.5)
                            .textCase(.uppercase)
                            .foregroundColor(.tzMuted)
                        Spacer()
                        Button { appState.navigate(to: .profile) } label: {
                            Circle()
                                .fill(Color.tzSurfaceMuted)
                                .frame(width: 36, height: 36)
                                .overlay(TZIcon("person", size: 18))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)

                    // Greeting
                    VStack(alignment: .leading, spacing: 6) {
                        (Text("Привіт, ").font(.tzSerif(44))
                         + Text("Олено").font(.tzSerif(44, italic: true)))
                            .foregroundColor(.tzInk)
                            .kerning(-1.4)
                        Text("Готова знайти новий образ?")
                            .font(.tzSans(16))
                            .foregroundColor(.tzMuted)
                            .kerning(-0.2)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    // Hero CTA
                    Button { appState.navigate(to: .capture) } label: {
                        ZStack(alignment: .topTrailing) {
                            Color.tzInk
                            Circle()
                                .fill(Color.white.opacity(0.04))
                                .frame(width: 180, height: 180)
                                .offset(x: 30, y: -30)
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Spacer()
                                    Circle()
                                        .fill(Color.white.opacity(0.08))
                                        .frame(width: 72, height: 72)
                                        .overlay(TZIcon("camera", size: 28, color: .white))
                                }
                                Text("Почати")
                                    .font(.tzSans(13, weight: .medium))
                                    .kerning(1.2)
                                    .textCase(.uppercase)
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding(.top, 80)
                                    .padding(.top, 0)
                                Spacer().frame(height: 80)
                                (Text("Зроби фото\n").font(.tzSerif(32))
                                 + Text("і приміряй").font(.tzSerif(32, italic: true)))
                                    .foregroundColor(.white)
                                    .kerning(-0.8)
                                    .lineSpacing(2)
                                HStack(spacing: 6) {
                                    Text("Камера або галерея")
                                        .font(.tzSans(14))
                                        .foregroundColor(.white.opacity(0.7))
                                    TZIcon("arrow.right", size: 14, color: .white.opacity(0.7))
                                }
                                .padding(.top, 16)
                            }
                            .padding(24)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: .radiusXL))
                    }
                    .buttonStyle(PressButtonStyle())
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    // Quick actions
                    HStack(spacing: 12) {
                        QuickCard(label: "Жіночі", count: womenHairstyles.count, hue: "A88563") {
                            appState.gender = .woman
                            appState.navigate(to: .gallery)
                        }
                        QuickCard(label: "Чоловічі", count: menHairstyles.count, hue: "3D2B1F") {
                            appState.gender = .man
                            appState.navigate(to: .gallery)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                    // Recommended
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .lastTextBaseline) {
                            SectionHeading(serif: "Рекомендовано", plain: "для тебе")
                            Spacer()
                            Button {
                                appState.gender = .woman
                                appState.navigate(to: .gallery)
                            } label: {
                                Text("Усі")
                                    .font(.tzSans(13))
                                    .foregroundColor(.tzMuted)
                            }
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(recents) { s in
                                    RecentStyleCard(style: s)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.horizontal, -24)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)

                    Spacer().frame(height: 120)
                }
            }

            TZTabBar(active: "home")
        }
    }
}

private struct RecentStyleCard: View {
    @EnvironmentObject var appState: AppState
    let style: HairstyleItem

    var body: some View {
        Button {
            appState.selectedStyle = style
            appState.gender = .woman
            appState.navigate(to: .preview)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    HairGlyphView(style: style)
                        .frame(width: 130, height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                    Text("\(style.match)%")
                        .font(.tzSans(11, weight: .semibold))
                        .kerning(-0.1)
                        .foregroundColor(.tzInk)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.95))
                        .clipShape(Capsule())
                        .padding(8)
                }

                Text(style.name)
                    .font(.tzSans(13, weight: .medium))
                    .foregroundColor(.tzInk)
                    .kerning(-0.1)
                    .lineLimit(1)

                Text("\(style.length.rawValue) · \(style.vibe)")
                    .font(.tzSans(11))
                    .foregroundColor(.tzMuted)
            }
            .frame(width: 130)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

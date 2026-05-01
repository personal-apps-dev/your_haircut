import SwiftUI

// MARK: - 12 Saved / Favorites

struct SavedView: View {
    @EnvironmentObject var appState: AppState

    private var allFavs: [HairstyleItem] {
        appState.favorites.compactMap { hairstyleById($0) }
    }

    var body: some View {
        ZStack {
            Color.tzBg.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    TZBackButton { appState.back() }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Колекція")
                            .font(.tzSans(11, weight: .medium))
                            .kerning(1.5)
                            .textCase(.uppercase)
                            .foregroundColor(.tzMuted)
                        Text("Обране")
                            .font(.tzSerif(26, italic: true))
                            .foregroundColor(.tzInk)
                            .kerning(-0.6)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)

                if allFavs.isEmpty {
                    SavedEmptyState()
                } else {
                    ScrollView(showsIndicators: false) {
                        let cols = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
                        LazyVGrid(columns: cols, spacing: 12) {
                            ForEach(allFavs) { s in
                                Button {
                                    appState.selectedStyle = s
                                    appState.navigate(to: .preview)
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        ZStack(alignment: .topTrailing) {
                                            HairGlyphView(style: s)
                                                .aspectRatio(0.82, contentMode: .fill)
                                                .clipShape(RoundedRectangle(cornerRadius: 18))

                                            Circle()
                                                .fill(Color.white.opacity(0.95))
                                                .frame(width: 28, height: 28)
                                                .overlay(
                                                    Image(systemName: "heart.fill")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.tzRed)
                                                )
                                                .padding(8)
                                        }

                                        Text(s.name)
                                            .font(.tzSans(14, weight: .medium))
                                            .foregroundColor(.tzInk)
                                            .kerning(-0.2)
                                            .lineLimit(1)

                                        Text("\(s.match)% match")
                                            .font(.tzSans(12))
                                            .foregroundColor(.tzMuted)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 120)
                    }
                }
            }

            TZTabBar(active: "saved")
        }
    }
}

private struct SavedEmptyState: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 16) {
            // Illustration
            ZStack {
                Ellipse()
                    .fill(Color.tzHairline)
                    .frame(width: 140, height: 12)
                    .offset(y: 70)

                // Dashed heart outline
                HeartOutline()
                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [4, 6]))
                    .foregroundColor(Color.tzHairlineStrong)
                    .frame(width: 80, height: 70)

                // Small heart inside
                HeartShape()
                    .fill(Color.tzSurfaceMuted)
                    .overlay(HeartShape().stroke(Color.tzInk, lineWidth: 1.5))
                    .frame(width: 30, height: 27)
            }
            .frame(width: 200, height: 160)

            Text("Поки порожньо")
                .font(.tzSerif(24))
                .foregroundColor(.tzInk)
                .kerning(-0.5)

            Text("Збережи зачіски, які тобі сподобались, щоб повернутись до них пізніше.")
                .font(.tzSans(14))
                .foregroundColor(.tzMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .kerning(-0.1)
                .frame(maxWidth: 260)

            TZPrimaryButton(title: "Переглянути стилі") {
                appState.navigate(to: .gender)
            }
            .frame(width: 220)
            .padding(.top, 8)
        }
        .padding(.horizontal, 40)
        .frame(maxHeight: .infinity)
    }
}

private struct HeartOutline: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height, cx = rect.midX
        var p = Path()
        p.move(to: CGPoint(x: cx, y: h))
        p.addQuadCurve(to: CGPoint(x: rect.minX, y: h*0.36), control: CGPoint(x: rect.minX, y: h*0.05))
        p.addQuadCurve(to: CGPoint(x: cx, y: h*0.36), control: CGPoint(x: cx, y: h*0.05))
        p.addQuadCurve(to: CGPoint(x: w, y: h*0.36), control: CGPoint(x: cx, y: h*0.05))
        p.addQuadCurve(to: CGPoint(x: cx, y: h), control: CGPoint(x: w, y: h*0.05))
        return p
    }
}

private struct HeartShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height, cx = rect.midX
        var p = Path()
        p.move(to: CGPoint(x: cx, y: h))
        p.addQuadCurve(to: CGPoint(x: rect.minX, y: h*0.4), control: CGPoint(x: rect.minX, y: h*0.1))
        p.addQuadCurve(to: CGPoint(x: cx, y: h*0.4), control: CGPoint(x: cx, y: h*0.1))
        p.addQuadCurve(to: CGPoint(x: w, y: h*0.4), control: CGPoint(x: cx, y: h*0.1))
        p.addQuadCurve(to: CGPoint(x: cx, y: h), control: CGPoint(x: w, y: h*0.1))
        p.closeSubpath()
        return p
    }
}

// MARK: - 13 Profile

struct ProfileView: View {
    @EnvironmentObject var appState: AppState

    private var tries: Int { appState.saved.count + 4 }

    var body: some View {
        ZStack {
            Color.tzBg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack {
                        TZBackButton { appState.back() }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Профіль")
                                .font(.tzSans(11, weight: .medium))
                                .kerning(1.5)
                                .textCase(.uppercase)
                                .foregroundColor(.tzMuted)
                        }
                        Spacer()
                        Button { appState.navigate(to: .settings) } label: {
                            Circle()
                                .fill(Color.tzSurfaceMuted)
                                .frame(width: 40, height: 40)
                                .overlay(TZIcon("gearshape", size: 17))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)

                    // Avatar + name
                    HStack(spacing: 16) {
                        FaceCanvasView(hairHex: "3D2B1F")
                            .frame(width: 76, height: 76)
                            .clipShape(Circle())
                            .background(Color.tzSurfaceMuted.clipShape(Circle()))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Олена")
                                .font(.tzSerif(28))
                                .foregroundColor(.tzInk)
                                .kerning(-0.6)
                            Text("З нами 2 місяці · Pro-план")
                                .font(.tzSans(13))
                                .foregroundColor(.tzMuted)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    // Stats
                    HStack(spacing: 8) {
                        StatBox(value: tries, label: "Примірок")
                        StatBox(value: appState.favorites.count, label: "В обраному")
                        StatBox(value: 12, label: "Аналізів")
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    // Face profile
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Твій типаж")
                            .font(.tzSans(11, weight: .medium))
                            .kerning(1.5)
                            .textCase(.uppercase)
                            .foregroundColor(.tzMuted)

                        VStack(spacing: 0) {
                            ForEach(Array(profileRows.enumerated()), id: \.element.key) { idx, row in
                                HStack {
                                    Text(row.key)
                                        .font(.tzSans(14))
                                        .foregroundColor(.tzMuted)
                                        .kerning(-0.1)
                                    Spacer()
                                    Text(row.value)
                                        .font(.tzSans(14, weight: .medium))
                                        .foregroundColor(.tzInk)
                                        .kerning(-0.1)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                if idx < profileRows.count - 1 {
                                    Divider().padding(.leading, 16)
                                }
                            }
                        }
                        .background(Color.tzSurface)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.tzHairline))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    // Menu
                    VStack(alignment: .leading, spacing: 10) {
                        VStack(spacing: 0) {
                            // API key row — always first, navigates to Settings
                            Button { appState.navigate(to: .settings) } label: {
                                HStack(spacing: 14) {
                                    TZIcon("key", size: 18, color: .tzMuted)
                                    Text("API ключ Claude")
                                        .font(.tzSans(14))
                                        .foregroundColor(.tzInk)
                                        .kerning(-0.1)
                                    Spacer()
                                    Text(appState.hasApiKey ? "Активний" : "Не встановлено")
                                        .font(.tzSans(12))
                                        .foregroundColor(appState.hasApiKey ? .tzPos : .tzMuted)
                                    TZIcon("chevron.right", size: 13, color: .tzMutedSoft)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                            }
                            .buttonStyle(PlainButtonStyle())
                            Divider().padding(.leading, 16)

                            ForEach(Array(menuItems.enumerated()), id: \.element.0) { idx, item in
                                Button {
                                    // placeholder
                                } label: {
                                    HStack(spacing: 14) {
                                        TZIcon(item.1, size: 18, color: .tzMuted)
                                        Text(item.0)
                                            .font(.tzSans(14))
                                            .foregroundColor(.tzInk)
                                            .kerning(-0.1)
                                        Spacer()
                                        TZIcon("chevron.right", size: 13, color: .tzMutedSoft)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                }
                                .buttonStyle(PlainButtonStyle())
                                if idx < menuItems.count - 1 {
                                    Divider().padding(.leading, 16)
                                }
                            }
                        }
                        .background(Color.tzSurface)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.tzHairline))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    Spacer().frame(height: 120)
                }
            }

            TZTabBar(active: "profile")
        }
    }

    private let profileRows: [(key: String, value: String)] = [
        ("Форма обличчя", "Овальна"),
        ("Тип волосся",   "Хвилясте, середнє"),
        ("Тон шкіри",     "Теплий світлий"),
        ("Колір очей",    "Карі"),
    ]

    private let menuItems: [(String, String)] = [
        ("Сповіщення",     "bell"),
        ("Конфіденційність","lock.shield"),
        ("Підписка",       "heart"),
        ("Допомога",       "questionmark.circle"),
    ]
}

private struct StatBox: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.tzSerif(26))
                .foregroundColor(.tzInk)
                .kerning(-0.6)
            Text(label)
                .font(.tzSans(11))
                .foregroundColor(.tzMuted)
                .kerning(-0.1)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.tzSurface)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.tzHairline))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

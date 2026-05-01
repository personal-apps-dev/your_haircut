import SwiftUI

// MARK: - Primary Button

struct TZPrimaryButton: View {
    let title: String
    var icon: String? = nil
    var dark: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.tzSans(16, weight: .medium))
                    .kerning(-0.2)
                if let icon { TZIcon(icon, size: 18, color: dark ? .tzInk : .white) }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(dark ? Color.white : Color.tzInk)
            .foregroundColor(dark ? .tzInk : .white)
            .clipShape(Capsule())
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Ghost Button

struct TZGhostButton: View {
    let title: String
    var leadingIcon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = leadingIcon { TZIcon(icon, size: 15, color: .tzInk) }
                Text(title)
                    .font(.tzSans(15, weight: .medium))
                    .kerning(-0.2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .foregroundColor(.tzInk)
            .overlay(Capsule().stroke(Color.tzHairlineStrong, lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Chip

struct TZChip: View {
    let title: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.tzSans(13, weight: .medium))
                .kerning(-0.1)
                .foregroundColor(isActive ? .white : .tzInkSoft)
                .padding(.horizontal, 14)
                .frame(height: 34)
                .background(isActive ? Color.tzInk : Color.clear)
                .overlay(Capsule().stroke(isActive ? Color.tzInk : Color.tzHairlineStrong, lineWidth: 1))
                .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.15), value: isActive)
    }
}

// MARK: - Back button

struct TZBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color.tzSurfaceMuted)
                .frame(width: 40, height: 40)
                .overlay(TZIcon("arrow.left", size: 18))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Tab Bar

struct TZTabBar: View {
    @EnvironmentObject var appState: AppState
    let active: String

    private let items: [(id: String, icon: String, label: String, target: AppScreen)] = [
        ("home",    "house",         "Дім",     .home),
        ("gallery", "square.grid.2x2", "Стилі", .gender),
        ("capture", "camera",        "Камера",  .capture),
        ("saved",   "heart",         "Обране",  .saved),
        ("profile", "person",        "Профіль", .profile),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            HStack(spacing: 0) {
                ForEach(items, id: \.id) { item in
                    Button {
                        appState.navigate(to: item.target)
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: active == item.id && item.id == "saved"
                                ? "heart.fill"
                                : (active == item.id ? item.icon + (item.id == "home" ? ".fill" : "") : item.icon))
                                .font(.system(size: 20, weight: active == item.id ? .semibold : .regular))
                                .foregroundColor(active == item.id ? .tzInk : .tzMutedSoft)
                            Text(item.label)
                                .font(.tzSans(10, weight: active == item.id ? .semibold : .medium))
                                .foregroundColor(active == item.id ? .tzInk : .tzMutedSoft)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 4)
            .background(Color.white)
            .overlay(Capsule().stroke(Color.tzHairline, lineWidth: 1))
            .clipShape(Capsule())
            .padding(.horizontal, 12)
            .shadow(color: .black.opacity(0.04), radius: 20, y: 4)
            .padding(.bottom, 28)
        }
    }
}

// MARK: - TZIcon (SF Symbols wrapper)

struct TZIcon: View {
    let name: String
    var size: CGFloat = 22
    var color: Color = .tzInk
    var weight: Font.Weight = .regular

    init(_ name: String, size: CGFloat = 22, color: Color = .tzInk, weight: Font.Weight = .regular) {
        self.name = name
        self.size = size
        self.color = color
        self.weight = weight
    }

    var body: some View {
        Image(systemName: name)
            .font(.system(size: size, weight: weight))
            .foregroundColor(color)
    }
}

// MARK: - ScoreRing

struct ScoreRingView: View {
    let value: Double       // animated current value
    let max: Int            // target / label

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.tzHairline, lineWidth: 6)
                Circle()
                    .trim(from: 0, to: value / 100)
                    .stroke(Color.tzInk, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.4), value: value)
                VStack(spacing: 0) {
                    Text("\(Int(value))")
                        .font(.tzSerif(28))
                        .foregroundColor(.tzInk)
                    + Text("%")
                        .font(.tzSans(14))
                        .foregroundColor(.tzMuted)
                }
            }
            .frame(width: 100, height: 100)

            VStack(alignment: .leading, spacing: 4) {
                Text("Загальна оцінка")
                    .font(.tzSans(12))
                    .foregroundColor(.tzMuted)
                    .kerning(1.2)
                    .textCase(.uppercase)
                Text(matchLabel(Int(value)))
                    .font(.tzSerif(18))
                    .foregroundColor(.tzInk)
                    .lineLimit(2)
            }
        }
    }

    private func matchLabel(_ v: Int) -> String {
        v >= 85 ? "Сильний матч" : v >= 75 ? "Хороший вибір" : "Помірно пасує"
    }
}

// MARK: - Match bar (horizontal progress strip)

struct MatchBar: View {
    let value: Int

    var body: some View {
        HStack(spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.tzHairline)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.tzInk)
                        .frame(width: geo.size.width * CGFloat(value) / 100)
                }
            }
            .frame(height: 3)
            Text("\(value)%")
                .font(.tzSans(11, weight: .semibold))
                .foregroundColor(.tzInk)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

// MARK: - Press button style (scale on tap)

struct PressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Safe area helpers

struct SafeAreaSpacer: View {
    var body: some View { Spacer().frame(height: 0) }
}

// MARK: - Pulse animation modifier

struct PulseModifier: ViewModifier {
    @State private var scale: CGFloat = 0.85
    @State private var opacity: Double = 0.7
    let delay: Double

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    Animation.easeOut(duration: 2.4)
                        .repeatForever(autoreverses: false)
                        .delay(delay)
                ) {
                    scale = 1.4
                    opacity = 0
                }
            }
    }
}

extension View {
    func pulseLoop(delay: Double = 0) -> some View { modifier(PulseModifier(delay: delay)) }
}

// MARK: - QuickCard (Home screen)

struct QuickCard: View {
    let label: String
    let count: Int
    let hue: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color(hex: hue))
                    .frame(width: 80, height: 80)
                    .offset(x: 20, y: 20)
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(count) стилів")
                        .font(.tzSans(13))
                        .foregroundColor(.tzMuted)
                    Text(label)
                        .font(.tzSerif(24))
                        .foregroundColor(.tzInk)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
            }
            .frame(height: 120)
            .background(Color.tzSurface)
            .overlay(RoundedRectangle(cornerRadius: .radiusXL).stroke(Color.tzHairline, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: .radiusXL))
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Section heading

struct SectionHeading: View {
    let serif: String
    let plain: String
    var size: CGFloat = 22

    var body: some View {
        (Text(serif).font(.tzSerif(size, italic: true))
         + Text(" " + plain).font(.tzSerif(size)))
            .foregroundColor(.tzInk)
            .kerning(-0.4)
    }
}

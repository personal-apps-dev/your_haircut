import SwiftUI

// MARK: - 08 Gallery

struct GalleryView: View {
    @EnvironmentObject var appState: AppState
    @State private var filter: HairLength? = nil

    private var styles: [HairstyleItem] { hairstyles(for: appState.gender ?? .woman) }

    private var filters: [HairLength?] {
        let base: [HairLength?] = [nil]
        if appState.gender == .man {
            return base + [.bald, .short, .medium, .long]
        } else {
            return base + [.short, .medium, .long]
        }
    }

    private var filtered: [HairstyleItem] {
        guard let f = filter else { return styles }
        return styles.filter { $0.length == f }
    }

    var body: some View {
        ZStack {
            Color.tzBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack(spacing: 12) {
                    TZBackButton { appState.back() }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(appState.gender == .man ? "Чоловічі" : "Жіночі")
                            .font(.tzSans(11, weight: .medium))
                            .kerning(1.5)
                            .textCase(.uppercase)
                            .foregroundColor(.tzMuted)
                        Text("Колекція")
                            .font(.tzSerif(26))
                            .foregroundColor(.tzInk)
                            .kerning(-0.6)
                    }

                    Spacer()

                    // Layout switcher
                    HStack(spacing: 0) {
                        ForEach(layouts, id: \.0) { (id, icon) in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    appState.galleryLayout = GalleryLayout(rawValue: id)!
                                }
                            } label: {
                                Circle()
                                    .fill(appState.galleryLayout.rawValue == id ? Color.white : Color.clear)
                                    .frame(width: 32, height: 32)
                                    .shadow(color: appState.galleryLayout.rawValue == id ? .black.opacity(0.08) : .clear, radius: 3)
                                    .overlay(
                                        Image(systemName: icon)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(appState.galleryLayout.rawValue == id ? .tzInk : .tzMuted)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(3)
                    .background(Color.tzSurfaceMuted)
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)

                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filters, id: \.?.rawValue) { f in
                            TZChip(
                                title: f?.rawValue ?? "Усі",
                                isActive: filter == f,
                                action: { withAnimation { filter = f } }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 20)

                Text("\(filtered.count) стилів")
                    .font(.tzSans(13))
                    .foregroundColor(.tzMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                // Gallery content
                ScrollView(showsIndicators: false) {
                    switch appState.galleryLayout {
                    case .grid:     GridLayout(styles: filtered)
                    case .carousel: CarouselLayout(styles: filtered)
                    case .list:     ListLayout(styles: filtered)
                    }
                }

                Spacer().frame(height: 0)
            }

            TZTabBar(active: "gallery")
        }
    }

    private let layouts: [(String, String)] = [
        ("grid", "square.grid.2x2"),
        ("carousel", "rectangle.split.2x1"),
        ("list", "list.bullet"),
    ]
}

// MARK: Grid

private struct GridLayout: View {
    let styles: [HairstyleItem]
    let cols = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        LazyVGrid(columns: cols, spacing: 12) {
            ForEach(styles) { s in GridCard(style: s) }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 120)
    }
}

struct GridCard: View {
    @EnvironmentObject var appState: AppState
    let style: HairstyleItem

    var body: some View {
        Button {
            appState.selectedStyle = style
            appState.navigate(to: .preview)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    HairGlyphView(style: style)
                        .aspectRatio(0.82, contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 18))

                    // Favorite heart
                    FavButton(id: style.id)
                        .padding(10)

                    // Match %
                    Text("\(style.match)%")
                        .font(.tzSans(11, weight: .semibold))
                        .kerning(-0.1)
                        .foregroundColor(.tzInk)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.95))
                        .clipShape(Capsule())
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .bottomLeading)
                        .frame(maxHeight: .infinity, alignment: .bottomLeading)
                }

                Text(style.name)
                    .font(.tzSans(14, weight: .medium))
                    .foregroundColor(.tzInk)
                    .kerning(-0.2)
                    .lineLimit(1)

                Text("\(style.length.rawValue) · \(style.vibe)")
                    .font(.tzSans(12))
                    .foregroundColor(.tzMuted)
            }
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: Carousel

private struct CarouselLayout: View {
    let styles: [HairstyleItem]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Spacer().frame(width: 12)
                ForEach(styles) { s in CarouselCard(style: s) }
                Spacer().frame(width: 12)
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 120)
    }
}

private struct CarouselCard: View {
    @EnvironmentObject var appState: AppState
    let style: HairstyleItem

    var body: some View {
        Button {
            appState.selectedStyle = style
            appState.navigate(to: .preview)
        } label: {
            ZStack(alignment: .bottom) {
                HairGlyphView(style: style)
                    .frame(width: 240, height: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 24))

                LinearGradient(
                    colors: [.black.opacity(0.6), .clear],
                    startPoint: .bottom, endPoint: .center
                )
                .clipShape(RoundedRectangle(cornerRadius: 24))

                VStack(alignment: .leading, spacing: 2) {
                    Text(style.name)
                        .font(.tzSerif(22))
                        .foregroundColor(.white)
                        .kerning(-0.4)
                    Text("\(style.length.rawValue) · \(style.vibe) · \(style.match)% match")
                        .font(.tzSans(12))
                        .foregroundColor(.white.opacity(0.85))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
            }
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: List

private struct ListLayout: View {
    let styles: [HairstyleItem]

    var body: some View {
        LazyVStack(spacing: 10) {
            ForEach(styles) { s in ListRow(style: s) }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 120)
    }
}

private struct ListRow: View {
    @EnvironmentObject var appState: AppState
    let style: HairstyleItem

    var body: some View {
        Button {
            appState.selectedStyle = style
            appState.navigate(to: .preview)
        } label: {
            HStack(spacing: 14) {
                HairGlyphView(style: style)
                    .frame(width: 70, height: 84)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 2) {
                    Text(style.name)
                        .font(.tzSans(15, weight: .medium))
                        .foregroundColor(.tzInk)
                        .kerning(-0.2)
                    Text("\(style.length.rawValue) · \(style.vibe)")
                        .font(.tzSans(12))
                        .foregroundColor(.tzMuted)
                    MatchBar(value: style.match)
                        .padding(.top, 6)
                }
                Spacer()
                FavButton(id: style.id)
            }
            .padding(12)
            .background(Color.tzSurface)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.tzHairline))
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: Fav button (shared)

struct FavButton: View {
    @EnvironmentObject var appState: AppState
    let id: String

    var body: some View {
        Button {
            appState.toggleFavorite(id)
        } label: {
            Circle()
                .fill(Color.white.opacity(0.92))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: appState.favorites.contains(id) ? "heart.fill" : "heart")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(appState.favorites.contains(id) ? .tzRed : .tzInk)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 09 Preview (split before/after)

struct PreviewSplitView: View {
    @EnvironmentObject var appState: AppState
    @State private var splitFraction: CGFloat = 0.5
    @State private var isDragging = false
    @State private var editTask: Task<Void, Never>? = nil

    private var style: HairstyleItem {
        appState.selectedStyle ?? (hairstyles(for: appState.gender ?? .woman).first!)
    }

    /// Cached edited image for the current photo + hairstyle, if any.
    private var cachedEdit: UIImage? {
        appState.editedImages[style.id]
    }

    /// Whether we should attempt the OpenAI image edit.
    private var canEdit: Bool {
        appState.capturedImage != nil && appState.hasOpenAIKey
    }

    var body: some View {
        ZStack {
            Color.tzBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    TZBackButton { appState.back() }
                    Spacer()
                    VStack(spacing: 2) {
                        Text("Превʼю")
                            .font(.tzSans(10, weight: .medium))
                            .kerning(1.5)
                            .textCase(.uppercase)
                            .foregroundColor(.tzMuted)
                        Text(style.name)
                            .font(.tzSerif(18))
                            .foregroundColor(.tzInk)
                            .kerning(-0.3)
                    }
                    Spacer()
                    FavButton(id: style.id)
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                // Split viewer
                GeometryReader { geo in
                    ZStack {
                        // AFTER — edited photo from OpenAI if available; otherwise
                        // a stylized canvas glyph as a placeholder.
                        Group {
                            if let edited = cachedEdit {
                                Image(uiImage: edited)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                FaceCanvasView(hairHex: style.hue)
                            }
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()

                        // Loading overlay while the OpenAI edit is in flight
                        if appState.isEditingImage && cachedEdit == nil {
                            EditLoadingOverlay()
                                .frame(width: geo.size.width, height: geo.size.height)
                        }

                        // Edit error banner (only on right half)
                        if let err = appState.editingError, cachedEdit == nil, !appState.isEditingImage {
                            EditErrorOverlay(message: err) {
                                fireEdit(force: true)
                            }
                            .frame(width: geo.size.width, height: geo.size.height)
                        }

                        Text("ПІСЛЯ")
                            .font(.tzSans(11, weight: .semibold))
                            .kerning(0.5)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(Color.tzInk)
                            .clipShape(Capsule())
                            .position(x: geo.size.width - 50, y: 24)

                        // BEFORE — real photo if user captured one, else fallback
                        Group {
                            if let img = appState.capturedImage {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                FaceCanvasView(hairHex: "3D2B1F")
                            }
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .mask(
                            HStack(spacing: 0) {
                                Rectangle()
                                    .frame(width: geo.size.width * splitFraction)
                                Spacer()
                            }
                            .frame(width: geo.size.width)
                        )

                        Text("ДО")
                            .font(.tzSans(11, weight: .semibold))
                            .kerning(0.5)
                            .foregroundColor(.tzInk)
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .position(x: 34, y: 24)

                        // Divider line
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 2)
                            .shadow(color: .black.opacity(0.5), radius: 8)
                            .position(x: geo.size.width * splitFraction, y: geo.size.height / 2)

                        // Handle circle
                        Circle()
                            .fill(Color.white)
                            .frame(width: 44, height: 44)
                            .shadow(color: .black.opacity(0.3), radius: 12)
                            .overlay(
                                Image(systemName: "arrow.left.arrow.right")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.tzInk)
                            )
                            .scaleEffect(isDragging ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.15), value: isDragging)
                            .position(x: geo.size.width * splitFraction, y: geo.size.height / 2)
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { val in
                                isDragging = true
                                let frac = val.location.x / geo.size.width
                                splitFraction = max(0.08, min(0.92, frac))
                            }
                            .onEnded { _ in isDragging = false }
                    )
                }
                .frame(maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: .radiusXL))
                .padding(.horizontal, 20)
                .padding(.top, 20)

                // Match strip
                HStack(spacing: 14) {
                    ZStack {
                        Circle().fill(Color.tzInk)
                        Text("\(style.match)")
                            .font(.tzSerif(16))
                            .foregroundColor(.white)
                    }
                    .frame(width: 44, height: 44)

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Сумісність")
                            .font(.tzSans(14, weight: .medium))
                            .foregroundColor(.tzInk)
                        Text("За попереднім аналізом")
                            .font(.tzSans(12))
                            .foregroundColor(.tzMuted)
                    }
                    Spacer()
                    Button {
                        appState.navigate(to: .analyzing)
                    } label: {
                        HStack(spacing: 6) {
                            TZIcon("sparkles", size: 14, color: .white)
                            Text("Повний аналіз")
                                .font(.tzSans(13, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 14)
                        .frame(height: 36)
                        .background(Color.tzInk)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(PressButtonStyle())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.tzSurface)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.tzHairline))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .padding(.horizontal, 20)
                .padding(.top, 14)

                // Bottom actions
                HStack(spacing: 10) {
                    TZGhostButton(title: "Інші", leadingIcon: "square.grid.2x2") { appState.back() }
                    TZPrimaryButton(title: "Аналізувати") { appState.navigate(to: .analyzing) }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 32)
            }
        }
        .onAppear { fireEdit(force: false) }
        .onChange(of: style.id) { _ in fireEdit(force: false) }
        .onDisappear { editTask?.cancel() }
    }

    // MARK: - Image edit driver

    private func fireEdit(force: Bool) {
        guard canEdit,
              let key = appState.openaiKey,
              let img = appState.capturedImage else { return }

        // Already cached — nothing to do unless caller forces a retry.
        if !force, appState.editedImages[style.id] != nil { return }

        editTask?.cancel()
        appState.editingError = nil
        appState.isEditingImage = true

        let currentStyle = style
        editTask = Task {
            do {
                let client = OpenAIClient(apiKey: key)
                let result = try await client.editHairstyle(image: img, hairstyle: currentStyle)
                await MainActor.run {
                    if !Task.isCancelled {
                        appState.editedImages[currentStyle.id] = result
                        appState.isEditingImage = false
                    }
                }
            } catch {
                await MainActor.run {
                    if !Task.isCancelled {
                        appState.editingError = error.localizedDescription
                        appState.isEditingImage = false
                    }
                }
            }
        }
    }
}

// MARK: - Edit overlays

private struct EditLoadingOverlay: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
            VStack(spacing: 12) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.4)
                Text("Приміряємо зачіску…")
                    .font(.tzSans(13, weight: .medium))
                    .foregroundColor(.white)
                Text("AI генерує фото у високій якості — до 60 сек")
                    .font(.tzSans(11))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
        }
    }
}

private struct EditErrorOverlay: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.tzWarn)
                    .font(.system(size: 28))
                Text("Не вдалося згенерувати фото")
                    .font(.tzSans(14, weight: .semibold))
                    .foregroundColor(.white)
                Text(message)
                    .font(.tzSans(12))
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 16)
                Button {
                    onRetry()
                } label: {
                    Text("Спробувати ще")
                        .font(.tzSans(13, weight: .medium))
                        .foregroundColor(.tzInk)
                        .padding(.horizontal, 16)
                        .frame(height: 36)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
                .buttonStyle(PressButtonStyle())
            }
            .padding(.horizontal, 24)
        }
    }
}

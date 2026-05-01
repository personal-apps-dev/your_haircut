import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            Color.tzBg.ignoresSafeArea()

            // Full-screen view per screen, animated with cross-fade + slide
            ZStack {
                screenView
                    .transition(
                        .asymmetric(
                            insertion: AnyTransition.opacity.combined(
                                with: .offset(
                                    x: appState.navDirection == .forward ? 20 : -20,
                                    y: 0
                                )
                            ),
                            removal: AnyTransition.opacity.combined(
                                with: .offset(
                                    x: appState.navDirection == .forward ? -20 : 20,
                                    y: 0
                                )
                            )
                        )
                    )
                    .id(appState.currentScreen)
            }
        }
        .animation(.easeInOut(duration: 0.26), value: appState.currentScreen)
    }

    @ViewBuilder
    private var screenView: some View {
        switch appState.currentScreen {
        case .splash:     SplashView()
        case .onboard:    OnboardingView()
        case .permission: PermissionView()
        case .home:       HomeView()
        case .capture:    CaptureView()
        case .gender:     GenderSelectView()
        case .hairquiz:   HairQuizView()
        case .gallery:    GalleryView()
        case .preview:    PreviewSplitView()
        case .analyzing:  AnalyzingView()
        case .result:     ResultView()
        case .saved:      SavedView()
        case .profile:    ProfileView()
        }
    }
}

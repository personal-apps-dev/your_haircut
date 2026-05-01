import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var anthropicInput: String = ""
    @State private var openaiInput: String = ""
    @State private var showSaved: Bool = false

    var body: some View {
        ZStack {
            Color.tzBg.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    TZBackButton { appState.back() }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Налаштування")
                            .font(.tzSans(11, weight: .medium))
                            .kerning(1.5)
                            .textCase(.uppercase)
                            .foregroundColor(.tzMuted)
                        Text("API ключі")
                            .font(.tzSerif(26, italic: true))
                            .foregroundColor(.tzInk)
                            .kerning(-0.6)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {

                        // Status banner
                        StatusBanner(
                            hasAnthropic: appState.hasApiKey,
                            hasOpenAI: appState.hasOpenAIKey
                        )
                        .padding(.top, 24)

                        // Anthropic key
                        KeyField(
                            label: "Anthropic API key",
                            sublabel: "Для AI-аналізу зачісок (як підходить, поради)",
                            placeholder: "sk-ant-api03-...",
                            value: $anthropicInput,
                            isActive: appState.hasApiKey,
                            onDelete: {
                                KeychainHelper.shared.delete(account: KeychainHelper.anthropicAccount)
                                appState.apiKey = nil
                                anthropicInput = ""
                            }
                        )

                        // OpenAI key
                        KeyField(
                            label: "OpenAI API key",
                            sublabel: "Для зміни зачіски на твоєму фото (gpt-image-1)",
                            placeholder: "sk-proj-...",
                            value: $openaiInput,
                            isActive: appState.hasOpenAIKey,
                            onDelete: {
                                KeychainHelper.shared.delete(account: KeychainHelper.openaiAccount)
                                appState.openaiKey = nil
                                appState.editedImages = [:]
                                openaiInput = ""
                            }
                        )

                        TZPrimaryButton(title: showSaved ? "✓ Збережено" : "Зберегти ключі") {
                            saveKeys()
                        }

                        // How-to
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Як отримати ключі")
                                .font(.tzSerif(20, italic: true))
                                .foregroundColor(.tzInk)
                                .padding(.top, 12)

                            HowToBlock(title: "Anthropic (Claude)", url: "console.anthropic.com", steps: [
                                "Реєстрація на console.anthropic.com",
                                "Поповни баланс (мін. $5)",
                                "API Keys → Create Key",
                                "Встав ключ у поле вище",
                            ])

                            HowToBlock(title: "OpenAI", url: "platform.openai.com", steps: [
                                "Реєстрація на platform.openai.com",
                                "Поповни баланс (мін. $5)",
                                "API keys → Create new secret key",
                                "Підтверди верифікацію organization (для gpt-image-1)",
                                "Встав ключ у поле вище",
                            ])
                        }

                        // Cost note
                        Text("""
                        Орієнтовна вартість одного циклу (аналіз + заміна зачіски):
                        • Claude Opus 4.7 — ≈ $0.02-0.05
                        • OpenAI gpt-image-1 (medium) — ≈ $0.07
                        Ключі можна видалити будь-коли.
                        """)
                            .font(.tzSans(12))
                            .foregroundColor(.tzMuted)
                            .lineSpacing(3)
                            .padding(.bottom, 60)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .onAppear {
            anthropicInput = appState.apiKey ?? ""
            openaiInput = appState.openaiKey ?? ""
        }
    }

    private func saveKeys() {
        let aTrim = anthropicInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let oTrim = openaiInput.trimmingCharacters(in: .whitespacesAndNewlines)

        if !aTrim.isEmpty {
            KeychainHelper.shared.save(aTrim, account: KeychainHelper.anthropicAccount)
            appState.apiKey = aTrim
        }
        if !oTrim.isEmpty {
            // Reset edit cache when key changes — old key may have produced different results
            if appState.openaiKey != oTrim { appState.editedImages = [:] }
            KeychainHelper.shared.save(oTrim, account: KeychainHelper.openaiAccount)
            appState.openaiKey = oTrim
        }

        showSaved = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            showSaved = false
        }
    }
}

// MARK: - Subviews

private struct StatusBanner: View {
    let hasAnthropic: Bool
    let hasOpenAI: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            row(label: "AI-аналіз (Claude)", on: hasAnthropic)
            row(label: "Заміна зачіски (OpenAI)", on: hasOpenAI)
        }
        .padding(14)
        .background(Color.tzSurface)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.tzHairline))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func row(label: String, on: Bool) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(on ? Color.tzPos : Color.tzMutedSoft)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.tzSans(13))
                .foregroundColor(.tzInkSoft)
            Spacer()
            Text(on ? "Активно" : "Не встановлено")
                .font(.tzSans(12))
                .foregroundColor(on ? .tzPos : .tzMuted)
        }
    }
}

private struct KeyField: View {
    let label: String
    let sublabel: String
    let placeholder: String
    @Binding var value: String
    let isActive: Bool
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.tzSans(11, weight: .medium))
                    .kerning(1.5)
                    .textCase(.uppercase)
                    .foregroundColor(.tzMuted)
                Spacer()
                if isActive {
                    Button { onDelete() } label: {
                        Text("Видалити")
                            .font(.tzSans(12))
                            .foregroundColor(.tzRed)
                    }
                }
            }
            SecureField(placeholder, text: $value)
                .font(.tzSans(14))
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(16)
                .background(Color.tzSurface)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.tzHairline))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            Text(sublabel)
                .font(.tzSans(12))
                .foregroundColor(.tzMuted)
                .lineSpacing(2)
        }
    }
}

private struct HowToBlock: View {
    let title: String
    let url: String
    let steps: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.tzSans(14, weight: .semibold))
                    .foregroundColor(.tzInk)
                Text("·")
                    .foregroundColor(.tzMutedSoft)
                Text(url)
                    .font(.tzSans(12))
                    .foregroundColor(.tzMuted)
            }
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(steps.enumerated()), id: \.offset) { idx, text in
                    HStack(alignment: .top, spacing: 10) {
                        Text(String(format: "%02d", idx + 1))
                            .font(.tzSerif(14))
                            .foregroundColor(.tzMutedSoft)
                            .frame(width: 22, alignment: .leading)
                        Text(text)
                            .font(.tzSans(13))
                            .foregroundColor(.tzInkSoft)
                            .lineSpacing(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .padding(14)
        .background(Color.tzSurface)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.tzHairline))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var inputKey: String = ""
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
                        Text("API ключ Claude")
                            .font(.tzSerif(26, italic: true))
                            .foregroundColor(.tzInk)
                            .kerning(-0.6)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {

                        // Status banner
                        StatusBanner(hasKey: !(appState.apiKey ?? "").isEmpty)
                            .padding(.top, 24)

                        // Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Anthropic API key")
                                .font(.tzSans(11, weight: .medium))
                                .kerning(1.5)
                                .textCase(.uppercase)
                                .foregroundColor(.tzMuted)
                                .padding(.top, 24)

                            SecureField("sk-ant-api03-...", text: $inputKey)
                                .font(.tzSans(14))
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding(16)
                                .background(Color.tzSurface)
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.tzHairline))
                                .clipShape(RoundedRectangle(cornerRadius: 14))

                            Text("Ключ зберігається лише на твоєму iPhone у Keychain. Він не передається нікуди, окрім api.anthropic.com під час аналізу.")
                                .font(.tzSans(13))
                                .foregroundColor(.tzMuted)
                                .lineSpacing(2)
                                .padding(.top, 4)
                        }

                        // Actions
                        VStack(spacing: 10) {
                            TZPrimaryButton(title: showSaved ? "✓ Збережено" : "Зберегти ключ") {
                                let trimmed = inputKey.trimmingCharacters(in: .whitespacesAndNewlines)
                                guard !trimmed.isEmpty else { return }
                                KeychainHelper.shared.save(trimmed)
                                appState.apiKey = trimmed
                                showSaved = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                                    showSaved = false
                                }
                            }

                            if !(appState.apiKey ?? "").isEmpty {
                                TZGhostButton(title: "Видалити ключ") {
                                    KeychainHelper.shared.delete()
                                    appState.apiKey = nil
                                    inputKey = ""
                                }
                            }
                        }
                        .padding(.top, 16)

                        // How-to
                        Text("Як отримати ключ")
                            .font(.tzSerif(20, italic: true))
                            .foregroundColor(.tzInk)
                            .padding(.top, 36)

                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(steps, id: \.0) { num, text in
                                HStack(alignment: .top, spacing: 12) {
                                    Text(num)
                                        .font(.tzSerif(18))
                                        .foregroundColor(.tzMutedSoft)
                                        .frame(width: 26, alignment: .leading)
                                    Text(text)
                                        .font(.tzSans(14))
                                        .foregroundColor(.tzInkSoft)
                                        .lineSpacing(3)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .padding(.top, 12)

                        // Cost note
                        Text("Один аналіз ≈ $0.02-0.05 (модель Claude Opus 4.7).\nКлюч можна видалити будь-коли.")
                            .font(.tzSans(12))
                            .foregroundColor(.tzMuted)
                            .lineSpacing(3)
                            .padding(.top, 24)
                            .padding(.bottom, 60)
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .onAppear {
            inputKey = appState.apiKey ?? ""
        }
    }

    private let steps: [(String, String)] = [
        ("01", "Зареєструйся на console.anthropic.com"),
        ("02", "Поповни баланс акаунту (мінімум $5)"),
        ("03", "Перейди в API Keys → Create Key"),
        ("04", "Скопіюй ключ і встав у поле вище"),
    ]
}

private struct StatusBanner: View {
    let hasKey: Bool

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(hasKey ? Color.tzPos : Color.tzWarn)
                .frame(width: 8, height: 8)
            Text(hasKey ? "Ключ встановлено — AI-аналіз увімкнено" : "Ключ не встановлено — використовується демо-режим")
                .font(.tzSans(13))
                .foregroundColor(.tzInkSoft)
                .kerning(-0.1)
            Spacer()
        }
        .padding(14)
        .background(Color.tzSurface)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.tzHairline))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

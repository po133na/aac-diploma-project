//
//  LanguageSelectView.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 17.03.2026.
//


import SwiftUI

struct LanguageSelectView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var localization: LocalizationManager
    var onLanguageSelected: () -> Void = {}

    private let languages: [LanguageOption] = [
        LanguageOption(code: .english,  flag: "🇬🇧", name: "English",   subtitle: "English"),
        LanguageOption(code: .russian,  flag: "🇷🇺", name: "Русский",   subtitle: "Russian"),
        LanguageOption(code: .kazakh,   flag: "🇰🇿", name: "Қазақша",  subtitle: "Kazakh"),
    ]

    var body: some View {
        ZStack {
            AuthBackground()

            VStack(spacing: 0) {
                Spacer()

                // Иллюстрация — TTS/speech волна
                SpeechWaveIllustration()
                    .frame(height: 140)
                    .padding(.bottom, 40)

                // Карточка с языками
                AuthCard {
                    VStack(spacing: 12) {
                        ForEach(languages) { option in
                            LanguageRowView(option: option) {
                                localization.currentLanguage = option.code
                                authViewModel.selectLanguage(option.code)
                                onLanguageSelected()
                            }
                        }
                    }
                }

                Spacer()
            }
        }
    }
}

// MARK: - Language Option Model

struct LanguageOption: Identifiable {
    let id = UUID()
    let code: AppLanguage
    let flag: String
    let name: String
    let subtitle: String
}

// MARK: - Language Row

private struct LanguageRowView: View {
    let option: LanguageOption
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Флаг в круге
                ZStack {
                    Circle()
                        .fill(AuthColors.gradientTop)
                        .frame(width: 46, height: 46)
                    Text(option.flag)
                        .font(.system(size: 22))
                }

                // Название
                VStack(alignment: .leading, spacing: 2) {
                    Text(option.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AuthColors.titleText)
                    Text(option.subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(AuthColors.subtitleText)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AuthColors.languageRow)
                    .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Speech Wave Illustration (отрисовка без изображений)

struct SpeechWaveIllustration: View {
    var body: some View {
        ZStack {
            // Полукруг снизу
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let cx = w / 2
                let cy = h * 0.72

                // Дуга (полукруг)
                Path { path in
                    path.addArc(
                        center: CGPoint(x: cx, y: cy),
                        radius: 52,
                        startAngle: .degrees(180),
                        endAngle: .degrees(0),
                        clockwise: false
                    )
                }
                .stroke(Color(hex: "5BBBBB"), style: StrokeStyle(lineWidth: 5, lineCap: .round))

                // Горизонтальные линии внутри дуги (лицо)
                Group {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: "5BBBBB"))
                        .frame(width: 22, height: 3)
                        .position(x: cx, y: cy - 10)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: "5BBBBB"))
                        .frame(width: 14, height: 3)
                        .position(x: cx, y: cy - 2)
                }

                // Звуковые волны (вертикальные линии сверху)
                let waveData: [(xOffset: CGFloat, height: CGFloat)] = [
                    (-52, 28), (-36, 44), (-20, 56), (0, 64),
                    (20, 56),  (36, 44),  (52, 28)
                ]
                ForEach(waveData.indices, id: \.self) { i in
                    let item = waveData[i]
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(hex: "5BBBBB"))
                        .frame(width: 4, height: item.height)
                        .position(x: cx + item.xOffset, y: cy - 52 - item.height / 2)
                }

                // Три кнопки на дуге (маленькие прямоугольники)
                let btnPositions: [CGFloat] = [-28, 0, 28]
                ForEach(btnPositions.indices, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(hex: "9B8FD0"))
                        .frame(width: 14, height: 10)
                        .position(x: cx + btnPositions[i], y: cy - 52)
                }
            }
        }
    }
}

#Preview {
    LanguageSelectView(onLanguageSelected: {})
        .environmentObject(AuthViewModel())
}

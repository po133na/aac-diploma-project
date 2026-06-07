import SwiftUI

// MARK: - Tutorial Step

enum TutorialStep: Int, CaseIterable {
    case plusButton    = 0   // tap anywhere → next
    case basicCategory = 1   // tap Основные → advance
    case tapCard       = 2   // tap card → advance
    case speakButton   = 3   // tap Speak → advance
    case closeButton   = 4   // tap X in ListenModal → advance
    case statsTab      = 5   // tap Settings → advance
    case languageTheme = 6   // "Готово" → finish
}

// MARK: - Tutorial Manager

@MainActor
final class TutorialManager: ObservableObject {
    static let shared = TutorialManager()
    private init() {}

    @Published var isActive = false
    @Published var currentStep: TutorialStep = .plusButton

    private var frames: [TutorialStep: CGRect] = [:]

    var currentFrame: CGRect { frames[currentStep] ?? .zero }

    func startIfNeeded() {
        guard !isActive, !UserDefaults.standard.bool(forKey: "tutorial_done") else { return }
        Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !isActive else { return }  // повторная проверка — onAppear может сработать несколько раз
            currentStep = .plusButton
            isActive = true
        }
    }

    func register(_ step: TutorialStep, frame: CGRect) {
        guard frame != .zero else { return }  // не перезаписываем валидный фрейм нулём
        objectWillChange.send()
        frames[step] = frame
    }

    // Вызывается из кода приложения когда юзер выполнил нужное действие.
    // Ждёт пока следующий шаг зарегистрирует фрейм (для случаев с сетевой загрузкой),
    // но не более 5 секунд.
    func advance(from step: TutorialStep) {
        guard isActive, currentStep == step else { return }
        Task {
            // Минимальная задержка — даём View время появиться
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard currentStep == step else { return }

            // Ждём фрейм КОНКРЕТНО следующего шага (до 5 секунд, шаг 100мс).
            // Важно: ждём именно idx+1, а не любой последующий — иначе всегда
            // найдём уже зарегистрированный statsTab и пропустим tapCard/closeButton.
            let all = TutorialStep.allCases
            if let idx = all.firstIndex(of: step), idx + 1 < all.count {
                let nextStep = all[idx + 1]
                let maxWait: UInt64 = 5_000_000_000
                let interval: UInt64 = 100_000_000
                var waited: UInt64 = 0
                while waited < maxWait {
                    guard currentStep == step else { return }
                    if let f = frames[nextStep], f != .zero { break }
                    try? await Task.sleep(nanoseconds: interval)
                    waited += interval
                }
            }

            guard currentStep == step else { return }
            next()
        }
    }

    func next() {
        let all = TutorialStep.allCases
        guard let idx = all.firstIndex(of: currentStep) else { return }
        var nextIdx = idx + 1
        while nextIdx < all.count {
            let candidate = all[nextIdx]
            if let f = frames[candidate], f != .zero {
                currentStep = candidate
                return
            }
            nextIdx += 1
        }
        finish()
    }

    func finish() {
        isActive = false
        UserDefaults.standard.set(true, forKey: "tutorial_done")
    }
}

// MARK: - Overlay

struct TutorialOverlayView: View {
    @ObservedObject private var manager = TutorialManager.shared
    @ObservedObject private var l = LocalizationManager.shared

    // Шаги на которых оверлей перехватывает тапы (а не пропускает к приложению)
    private var isBlockingStep: Bool {
        manager.currentStep == .plusButton || manager.currentStep == .languageTheme
    }

    private var isLastStep: Bool { manager.currentStep == .languageTheme }

    private var message: String {
        switch manager.currentStep {
        case .plusButton:    return l.tutorialPlus
        case .basicCategory: return l.tutorialLongPress
        case .tapCard:       return l.tutorialTap
        case .speakButton:   return l.tutorialSpeak
        case .closeButton:   return l.tutorialClose
        case .statsTab:      return l.tutorialStats
        case .languageTheme: return l.tutorialLanguage
        }
    }

    var body: some View {
        if manager.isActive && manager.currentStep == .closeButton {
            // Для шага closeButton — только полноэкранный тинт.
            // Подсказка и подсветка показываются inline внутри ListenModalView.
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .transition(.opacity)
        } else if manager.isActive {
            ZStack {
                // Затемнение с вырезом под элемент
                TutorialSpotlight(frame: manager.currentFrame)
                    .allowsHitTesting(false)

                // Для шагов где нужно перехватить тап (plusButton и languageTheme)
                if isBlockingStep {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if isLastStep { manager.finish() } else { manager.next() }
                        }
                        .ignoresSafeArea()
                }

                TutorialBubble(text: message, frame: manager.currentFrame)
                    .allowsHitTesting(false)

                // Кнопка «Пропустить» / «Готово»
                VStack {
                    HStack {
                        Button(action: manager.finish) {
                            Text(isLastStep ? l.done : l.tutorialSkip)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(Color.white.opacity(0.18)))
                        }
                        .padding(.top, 56)
                        .padding(.leading, 20)
                        Spacer()
                    }
                    Spacer()
                }
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.35), value: manager.currentFrame)
            .transition(.opacity)
        }
    }
}

// MARK: - Spotlight (rounded rect matching element shape)

private struct TutorialSpotlight: View {
    let frame: CGRect

    private let spotlightPadding: CGFloat = 10
    private let cornerRadius: CGFloat = 18

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
            if frame != .zero {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .frame(
                        width: frame.width + spotlightPadding * 2,
                        height: frame.height + spotlightPadding * 2
                    )
                    .position(x: frame.midX, y: frame.midY)
                    .blendMode(.destinationOut)
            }
        }
        .compositingGroup()
        .ignoresSafeArea()
    }
}

// MARK: - Bubble

private struct TutorialBubble: View {
    let text: String
    let frame: CGRect

    private let maxWidth: CGFloat = 240
    private let padding: CGFloat = 10
    private let gap: CGFloat = 16
    private var screenH: CGFloat { UIScreen.main.bounds.height }
    private var screenW: CGFloat { UIScreen.main.bounds.width }

    private var showAbove: Bool { frame.midY > screenH * 0.55 }

    private var centerX: CGFloat {
        let x = frame == .zero ? screenW / 2 : frame.midX
        return min(max(x, maxWidth / 2 + 16), screenW - maxWidth / 2 - 16)
    }

    private var centerY: CGFloat {
        guard frame != .zero else { return screenH / 2 }
        let halfH = frame.height / 2 + padding + gap
        return showAbove ? frame.midY - halfH - 44 : frame.midY + halfH + 44
    }

    var body: some View {
        VStack(spacing: 0) {
            if !showAbove {
                TutorialArrow()
                    .fill(Color("AppSurface"))
                    .frame(width: 14, height: 7)
                    .rotationEffect(.degrees(180))
            }

            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color("AppTextPrimary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: maxWidth)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color("AppSurface"))
                        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
                )

            if showAbove {
                TutorialArrow()
                    .fill(Color("AppSurface"))
                    .frame(width: 14, height: 7)
            }
        }
        .position(x: centerX, y: centerY)
    }
}

// MARK: - Arrow shape

private struct TutorialArrow: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

// MARK: - Helper modifier

extension View {
    func tutorialAnchor(_ step: TutorialStep, yOffset: CGFloat = 0) -> some View {
        self.background(
            GeometryReader { geo in
                Color.clear.task {
                    try? await Task.sleep(nanoseconds: 150_000_000)
                    var frame = geo.frame(in: .global)
                    frame.origin.y += yOffset
                    TutorialManager.shared.register(step, frame: frame)
                }
            }
        )
    }
}

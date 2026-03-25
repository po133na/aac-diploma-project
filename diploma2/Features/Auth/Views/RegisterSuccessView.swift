//
//  RegisterSuccessView.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 17.03.2026.
//



import SwiftUI

struct RegisterSuccessView: View {
    var onContinue: () -> Void   // → переход на MainTabView

    var body: some View {
        ZStack {
            AuthBackground()

            AuthCard {
                VStack(spacing: 20) {

                    // Back button (без step badge)
                    HStack {
                        // На этом экране back скрыт — пользователь уже зарегистрирован
                        Spacer()
                    }

                    // Аватар — зелёный (успех)
                    AuthAvatar(color: AuthColors.avatarGreen)
                        .padding(.top, 12)

                    // Заголовок
                    VStack(spacing: 8) {
                        Text("You're in !")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AuthColors.titleText)

                        Text("Account created successfully.\nWelcome to Unim!")
                            .font(.system(size: 14))
                            .foregroundColor(AuthColors.subtitleText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }

                    Spacer().frame(height: 40)

                    // Hint баннер
                    AuthHintBanner(text: "✨ Almost done! One more click! 🎉")

                    // Кнопка — зелёная
                    AuthButton(
                        title: "Continue →",
                        color: AuthColors.buttonGreen
                    ) {
                        onContinue()
                    }
                }
            }
        }
    }
}

#Preview {
    RegisterSuccessView(onContinue: {})
}

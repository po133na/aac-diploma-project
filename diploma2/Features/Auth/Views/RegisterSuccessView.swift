//
//  RegisterSuccessView.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 17.03.2026.
//



import SwiftUI

struct RegisterSuccessView: View {
    var onContinue: () -> Void
    @ObservedObject private var l = LocalizationManager.shared

    var body: some View {
        ZStack {
            AuthBackground()

            AuthCard {
                VStack(spacing: 20) {

                    HStack { Spacer() }

                    ZStack {
                        AuthAvatar(color: AuthColors.avatarGreen)
                            .padding(.top, 12)
                        Image(systemName: "checkmark")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 12)
                    }

                    VStack(spacing: 8) {
                        Text(l.youreIn)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AuthColors.titleText)

                        Text(l.accountCreated)
                            .font(.system(size: 14))
                            .foregroundColor(AuthColors.subtitleText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }

                    Spacer().frame(height: 40)

                    AuthButton(
                        title: l.continueArrow,
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

//
//  ForgotPasswordView.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 26.03.2026.
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var localization: LocalizationManager
    
    @State private var email = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @FocusState private var isEmailFocused: Bool
    
    var body: some View {
        ZStack {
            AuthBackground()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 60)
                    
                    AuthCard {
                        VStack(spacing: 20) {
                            
                            // Иконка
                            ZStack {
                                Circle()
                                    .fill(AuthColors.avatarBlue.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                Image(systemName: "key.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(AuthColors.buttonBlue)
                            }
                            
                            // Заголовок
                            VStack(spacing: 6) {
                                Text(localization.resetPasswordTitle)
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(AuthColors.titleText)

                                Text(localization.enterEmailReset)
                                    .font(.system(size: 14))
                                    .foregroundColor(AuthColors.subtitleText)
                                    .multilineTextAlignment(.center)
                            }

                            // Сообщения
                            if let error = errorMessage {
                                AuthErrorBanner(
                                    title: localization.errorTitle,
                                    subtitle: error
                                )
                            }

                            if let success = successMessage {
                                AuthSuccessBanner(
                                    title: localization.successTitle,
                                    subtitle: success
                                )
                            }

                            // Поле email
                            AuthTextField(
                                label: localization.emailAddress,
                                placeholder: localization.emailPlaceholder,
                                icon: "envelope",
                                text: $email,
                                isError: errorMessage != nil,
                                keyboardType: .emailAddress
                            )
                            .focused($isEmailFocused)
                            .disabled(isLoading)

                            // Инструкция
                            Text(localization.resetInstructions)
                                .font(.system(size: 13))
                                .foregroundColor(AuthColors.subtitleText)
                                .multilineTextAlignment(.center)
                                .padding(.vertical, 8)

                            // Кнопка Send
                            AuthButton(
                                title: isLoading ? localization.sending : localization.sendResetLink,
                                color: AuthColors.buttonBlue,
                                isDisabled: email.isEmpty || isLoading
                            ) {
                                sendResetLink()
                            }

                            // Кнопка Back
                            Button {
                                dismiss()
                            } label: {
                                Text(localization.backToLogin)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(AuthColors.subtitleText)
                                    .padding(.vertical, 12)
                            }
                            .disabled(isLoading)
                        }
                    }
                    
                    Spacer().frame(height: 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func sendResetLink() {
        guard !email.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        isEmailFocused = false
        
        Task {
            do {
                let response = try await authViewModel.forgotPassword(email: email)
                successMessage = response.message
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
                successMessage = nil
            }
            isLoading = false
        }
    }
}

// Добавляем AuthSuccessBanner
struct AuthSuccessBanner: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "10B981"))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "065F46"))
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "047857"))
            }
            
            Spacer()
        }
        .padding(14)
        .background(Color(hex: "D1FAE5"))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "10B981").opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    ForgotPasswordView()
        .environmentObject(AuthViewModel())
}

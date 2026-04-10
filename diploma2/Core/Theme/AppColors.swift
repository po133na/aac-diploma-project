//
//  AppColors.swift
//  diploma2
//

import SwiftUI

struct AppColors {
    // MARK: - Backgrounds
    /// Main screen background  (#EAF4FB / dark #0F1B24)
    static let bg                = Color("AppBg")
    /// Profile / alternate background  (#D6EEF5 / dark #0A1520)
    static let bgAlt             = Color("AppBgAlt")
    /// Card / sheet surface  (#FFFFFF / dark #1C2B38)
    static let surface           = Color("AppSurface")
    /// Text-field background  (#EEF5F9 / dark #152230)
    static let surfaceSecondary  = Color("AppSurfaceSecondary")

    // MARK: - Text
    /// Primary text, deep blue  (#1C3F6E / dark #D8EEFB)
    static let textPrimary       = Color("AppTextPrimary")
    /// Secondary / subtitle text  (#6B8BAE / dark #7A9AB5)
    static let textSecondary     = Color("AppTextSecondary")
    /// Hint / placeholder text  (#9BB8CC / dark #456070)
    static let textHint          = Color("AppTextHint")
    /// Dark-slate card text  (#2C3E50 / dark #B0C8D8)
    static let textDark          = Color("AppTextDark")

    // MARK: - Tints (pastel backgrounds for icons / pills)
    /// Image placeholder  (#C5D8F5 / dark #1A2B3A)
    static let placeholderBg     = Color("AppPlaceholderBg")
    /// Purple tint  (#D4C5F5 / dark #231840)
    static let tintPurple        = Color("AppTintPurple")
    /// Green tint  (#C5F5D8 / dark #0D2A1A)
    static let tintGreen         = Color("AppTintGreen")
    /// Blue tint  (#C5E8F5 / dark #0D2030)
    static let tintBlue          = Color("AppTintBlue")
    /// Border / divider  (#E5EEF5 / dark #1A2B38)
    static let borderLight       = Color("AppBorderLight")

    /// Sky blue tint for category cards  (#A8C8F0 / dark #0D2038)
    static let tintSkyBlue       = Color("AppTintSkyBlue")
    /// Yellow tint  (#F5ECC5 / dark #2A250A)
    static let tintYellow        = Color("AppTintYellow")
    /// Pink tint  (#F5C5C5 / dark #2A0A0A)
    static let tintPink          = Color("AppTintPink")
    /// Rose tint  (#F5C5D8 / dark #2A0A1A)
    static let tintRose          = Color("AppTintRose")
    /// Medium border  (#D0E5F0 / dark #1A2B38)
    static let borderMed         = Color("AppBorderMed")
    /// Success text on green bg  (#3A8A52 / dark #6DBF82)
    static let successText       = Color("AppSuccessText")

    // MARK: - Accents (same in light & dark)
    static let accentBlue        = Color(hex: "5BAECC")
    static let accentRed         = Color(hex: "F87171")
    static let accentPurple      = Color(hex: "A78BFA")
    static let accentGreen       = Color(hex: "6DBF82")
    static let accentOrange      = Color(hex: "F5A623")
    static let accentPurpleDark  = Color(hex: "7C5CBF")
}

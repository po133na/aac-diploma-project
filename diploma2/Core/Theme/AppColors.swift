//
//  AppColors.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 17.03.2026.
//

import SwiftUI

struct AppColors {
    // Основные (будут заменены на цвета из дизайна)
    static let primary      = Color("Primary")       // Синий — спокойный
    static let secondary    = Color("Secondary")     // Мягкий фиолетовый
    static let accent       = Color("Accent")        // Жёлтый/оранжевый
    static let background   = Color("Background")    // Очень светлый серый
    static let surface      = Color("Surface")       // Белый / тёмная карточка
    static let textPrimary  = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    static let success      = Color("Success")       // Зелёный
    static let error        = Color("Error")         // Красный (мягкий)
    
    // Autism-friendly: избегаем ярких насыщенных цветов
    // Рекомендуемая палитра до получения дизайна:
    // Primary:    #5B8DEF (мягкий синий)
    // Secondary:  #A78BFA (лавандовый)
    // Accent:     #FBBF24 (тёплый жёлтый)
    // Background: #F8F9FF (почти белый)
    // Surface:    #FFFFFF / #1E1E2E (тёмная тема)
}

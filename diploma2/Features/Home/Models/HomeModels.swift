//
//  HomeModels.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 18.03.2026.
//

import SwiftUI

// MARK: - Sentence Token

enum SentenceToken: Identifiable {
    case card(Card, UUID)
    case typed(String, UUID)

    var id: UUID {
        switch self { case .card(_, let u): return u; case .typed(_, let u): return u }
    }
    var word: String {
        switch self { case .card(let c, _): return c.word; case .typed(let t, _): return t }
    }
    var isCard: Bool {
        if case .card = self { return true }; return false
    }
}

// MARK: - Word Card
struct WordCard: Identifiable, Hashable {
    let id = UUID()
    let word: String
    let color: Color
}

// MARK: - Category
struct WordCategory: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let color: Color
    let words: [WordCard]
}

// MARK: - Sample Data
extension WordCategory {
    static let sampleData: [WordCategory] = [
        WordCategory(
            name: "Basics",
            subtitle: "Basic words",
            color: Color("AppTintSkyBlue"),
            words: [
                WordCard(word: "I",      color: Color("AppPlaceholderBg")),
                WordCard(word: "You",    color: Color("AppTintPurple")),
                WordCard(word: "Want",   color: Color("AppTintBlue")),
                WordCard(word: "Need",   color: Color("AppTintYellow")),
                WordCard(word: "Help",   color: Color("AppTintPurple")),
                WordCard(word: "Yes",    color: Color("AppTintGreen")),
                WordCard(word: "No",     color: Color("AppTintYellow")),
                WordCard(word: "Please", color: Color("AppTintPurple")),
                WordCard(word: "Listen", color: Color("AppTintBlue")),
                WordCard(word: "Eat",    color: Color("AppTintPink")),
                WordCard(word: "Drink",  color: Color("AppPlaceholderBg")),
                WordCard(word: "Play",   color: Color(hex: "C5F5E8")),
                WordCard(word: "Sleep",  color: Color("AppTintRose")),
                WordCard(word: "Go",     color: Color("AppTintPurple")),
                WordCard(word: "Read",   color: Color("AppTintBlue")),
                WordCard(word: "Watch",  color: Color("AppTintYellow")),
                WordCard(word: "Draw",   color: Color("AppTintGreen")),
                WordCard(word: "Sing",   color: Color("AppTintPink")),
                WordCard(word: "Dance",  color: Color("AppTintPurple")),
                WordCard(word: "Jump",   color: Color("AppTintBlue")),
            ]
        ),
        WordCategory(
            name: "Food",
            subtitle: "Food & drinks",
            color: Color(hex: "A8E8B0"),
            words: [
                WordCard(word: "Apple",  color: Color("AppTintPink")),
                WordCard(word: "Bread",  color: Color("AppTintYellow")),
                WordCard(word: "Milk",   color: Color("AppPlaceholderBg")),
                WordCard(word: "Water",  color: Color("AppTintBlue")),
                WordCard(word: "Rice",   color: Color("AppTintGreen")),
                WordCard(word: "Meat",   color: Color("AppTintRose")),
            ]
        ),
        WordCategory(
            name: "Actions",
            subtitle: "Things to do",
            color: Color(hex: "F5E8A0"),
            words: [
                WordCard(word: "Run",    color: Color("AppTintYellow")),
                WordCard(word: "Walk",   color: Color("AppTintGreen")),
                WordCard(word: "Jump",   color: Color("AppPlaceholderBg")),
                WordCard(word: "Sit",    color: Color("AppTintPurple")),
                WordCard(word: "Stand",  color: Color("AppTintPink")),
                WordCard(word: "Stop",   color: Color("AppTintRose")),
            ]
        ),
        WordCategory(
            name: "Feelings",
            subtitle: "How I feel",
            color: Color(hex: "F5B8C8"),
            words: [
                WordCard(word: "Happy",  color: Color("AppTintYellow")),
                WordCard(word: "Sad",    color: Color("AppPlaceholderBg")),
                WordCard(word: "Angry",  color: Color("AppTintPink")),
                WordCard(word: "Tired",  color: Color("AppTintPurple")),
                WordCard(word: "Good",   color: Color("AppTintGreen")),
                WordCard(word: "Pain",   color: Color("AppTintRose")),
            ]
        ),
        WordCategory(
            name: "People",
            subtitle: "Family & Friends",
            color: Color(hex: "C8B8F0"),
            words: [
                WordCard(word: "Mom",    color: Color("AppTintRose")),
                WordCard(word: "Dad",    color: Color("AppPlaceholderBg")),
                WordCard(word: "Friend", color: Color("AppTintGreen")),
                WordCard(word: "Teacher",color: Color("AppTintYellow")),
                WordCard(word: "Doctor", color: Color("AppTintPurple")),
                WordCard(word: "Me",     color: Color("AppTintBlue")),
            ]
        ),
        WordCategory(
            name: "Places",
            subtitle: "Where to go",
            color: Color(hex: "A8D8F0"),
            words: [
                WordCard(word: "Home",   color: Color("AppPlaceholderBg")),
                WordCard(word: "School", color: Color("AppTintYellow")),
                WordCard(word: "Park",   color: Color("AppTintGreen")),
                WordCard(word: "Store",  color: Color("AppTintPink")),
                WordCard(word: "Toilet", color: Color("AppTintPurple")),
                WordCard(word: "Outside",color: Color("AppTintBlue")),
            ]
        ),
    ]
}



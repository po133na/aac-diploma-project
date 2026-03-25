//
//  HomeModels.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 18.03.2026.
//

import SwiftUI

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
            color: Color(hex: "A8C8F0"),
            words: [
                WordCard(word: "I",      color: Color(hex: "C5D8F5")),
                WordCard(word: "You",    color: Color(hex: "D4C5F5")),
                WordCard(word: "Want",   color: Color(hex: "C5E8F5")),
                WordCard(word: "Need",   color: Color(hex: "F5ECC5")),
                WordCard(word: "Help",   color: Color(hex: "D4C5F5")),
                WordCard(word: "Yes",    color: Color(hex: "C5F5D8")),
                WordCard(word: "No",     color: Color(hex: "F5ECC5")),
                WordCard(word: "Please", color: Color(hex: "D4C5F5")),
                WordCard(word: "Listen", color: Color(hex: "C5E8F5")),
                WordCard(word: "Eat",    color: Color(hex: "F5C5C5")),
                WordCard(word: "Drink",  color: Color(hex: "C5D8F5")),
                WordCard(word: "Play",   color: Color(hex: "C5F5E8")),
                WordCard(word: "Sleep",  color: Color(hex: "F5C5D8")),
                WordCard(word: "Go",     color: Color(hex: "D4C5F5")),
                WordCard(word: "Read",   color: Color(hex: "C5E8F5")),
                WordCard(word: "Watch",  color: Color(hex: "F5ECC5")),
                WordCard(word: "Draw",   color: Color(hex: "C5F5D8")),
                WordCard(word: "Sing",   color: Color(hex: "F5C5C5")),
                WordCard(word: "Dance",  color: Color(hex: "D4C5F5")),
                WordCard(word: "Jump",   color: Color(hex: "C5E8F5")),
            ]
        ),
        WordCategory(
            name: "Food",
            subtitle: "Food & drinks",
            color: Color(hex: "A8E8B0"),
            words: [
                WordCard(word: "Apple",  color: Color(hex: "F5C5C5")),
                WordCard(word: "Bread",  color: Color(hex: "F5ECC5")),
                WordCard(word: "Milk",   color: Color(hex: "C5D8F5")),
                WordCard(word: "Water",  color: Color(hex: "C5E8F5")),
                WordCard(word: "Rice",   color: Color(hex: "C5F5D8")),
                WordCard(word: "Meat",   color: Color(hex: "F5C5D8")),
            ]
        ),
        WordCategory(
            name: "Actions",
            subtitle: "Things to do",
            color: Color(hex: "F5E8A0"),
            words: [
                WordCard(word: "Run",    color: Color(hex: "F5ECC5")),
                WordCard(word: "Walk",   color: Color(hex: "C5F5D8")),
                WordCard(word: "Jump",   color: Color(hex: "C5D8F5")),
                WordCard(word: "Sit",    color: Color(hex: "D4C5F5")),
                WordCard(word: "Stand",  color: Color(hex: "F5C5C5")),
                WordCard(word: "Stop",   color: Color(hex: "F5C5D8")),
            ]
        ),
        WordCategory(
            name: "Feelings",
            subtitle: "How I feel",
            color: Color(hex: "F5B8C8"),
            words: [
                WordCard(word: "Happy",  color: Color(hex: "F5ECC5")),
                WordCard(word: "Sad",    color: Color(hex: "C5D8F5")),
                WordCard(word: "Angry",  color: Color(hex: "F5C5C5")),
                WordCard(word: "Tired",  color: Color(hex: "D4C5F5")),
                WordCard(word: "Good",   color: Color(hex: "C5F5D8")),
                WordCard(word: "Pain",   color: Color(hex: "F5C5D8")),
            ]
        ),
        WordCategory(
            name: "People",
            subtitle: "Family & Friends",
            color: Color(hex: "C8B8F0"),
            words: [
                WordCard(word: "Mom",    color: Color(hex: "F5C5D8")),
                WordCard(word: "Dad",    color: Color(hex: "C5D8F5")),
                WordCard(word: "Friend", color: Color(hex: "C5F5D8")),
                WordCard(word: "Teacher",color: Color(hex: "F5ECC5")),
                WordCard(word: "Doctor", color: Color(hex: "D4C5F5")),
                WordCard(word: "Me",     color: Color(hex: "C5E8F5")),
            ]
        ),
        WordCategory(
            name: "Places",
            subtitle: "Where to go",
            color: Color(hex: "A8D8F0"),
            words: [
                WordCard(word: "Home",   color: Color(hex: "C5D8F5")),
                WordCard(word: "School", color: Color(hex: "F5ECC5")),
                WordCard(word: "Park",   color: Color(hex: "C5F5D8")),
                WordCard(word: "Store",  color: Color(hex: "F5C5C5")),
                WordCard(word: "Toilet", color: Color(hex: "D4C5F5")),
                WordCard(word: "Outside",color: Color(hex: "C5E8F5")),
            ]
        ),
    ]
}



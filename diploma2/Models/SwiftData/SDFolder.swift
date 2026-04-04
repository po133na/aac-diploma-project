import SwiftData
import Foundation

@Model
final class SDCategory {
    @Attribute(.unique) var id: Int
    var name: String
    var nameKk: String?
    var nameEn: String?
    var icon: String?
    var isSystem: Bool
    var cachedAt: Date

    init(from category: Category) {
        self.id       = category.id
        self.name     = category.name
        self.nameKk   = category.nameKk
        self.nameEn   = category.nameEn
        self.icon     = category.icon
        self.isSystem = category.isSystem
        self.cachedAt = Date()
    }

    func toDomain() -> Category {
        Category(
            id:        id,
            name:      name,
            nameKk:    nameKk,
            nameEn:    nameEn,
            icon:      icon,
            userId:    isSystem ? nil : -1,
            createdAt: cachedAt
        )
    }
}

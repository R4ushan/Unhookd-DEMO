import Foundation

struct GuideSection: Identifiable, Codable {
    let id: UUID
    let title: String
    let content: String
    var isFavorite: Bool
    
    init(title: String, content: String, isFavorite: Bool = false) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.isFavorite = isFavorite
    }
}

struct GuideContent: Codable {
    let addictionType: String
    let sections: [GuideSection]
    let generatedDate: Date
    
    var isStale: Bool {
        Calendar.current.dateComponents([.hour], from: generatedDate, to: Date()).hour ?? 0 > 24
    }
}

class GuideStorage {
    static let shared = GuideStorage()
    private let defaults = UserDefaults.standard
    
    private let guideKey = "cached_guide"
    private let favoritesKey = "favorite_sections"
    
    func saveGuide(_ guide: GuideContent) {
        if let encoded = try? JSONEncoder().encode(guide) {
            defaults.set(encoded, forKey: guideKey)
        }
    }
    
    func loadGuide() -> GuideContent? {
        guard let data = defaults.data(forKey: guideKey),
              let guide = try? JSONDecoder().decode(GuideContent.self, from: data)
        else {
            return nil
        }
        return guide
    }
    
    func saveFavorites(_ sections: [GuideSection]) {
        if let encoded = try? JSONEncoder().encode(sections) {
            defaults.set(encoded, forKey: favoritesKey)
        }
    }
    
    func loadFavorites() -> [GuideSection] {
        guard let data = defaults.data(forKey: favoritesKey),
              let sections = try? JSONDecoder().decode([GuideSection].self, from: data)
        else {
            return []
        }
        return sections
    }
    
    func clearCache() {
        defaults.removeObject(forKey: guideKey)
    }
} 
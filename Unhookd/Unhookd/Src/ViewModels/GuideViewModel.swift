import Foundation
import SwiftUI
import RegexBuilder

@MainActor
class GuideViewModel: ObservableObject {
    @Published var sections: [GuideSection] = []
    @Published var favoriteSections: [GuideSection] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedSection: GuideSection?
    @Published var showingSectionDetail = false
    
    private let geminiService = GeminiService()
    private let storage = GuideStorage.shared
    
    init() {
        favoriteSections = storage.loadFavorites()
    }
    
    func generateGuide(for addiction: String, force: Bool = false) {
        guard !addiction.isEmpty else {
            errorMessage = "Please complete the onboarding process to set your addiction type."
            return
        }
        
        // Check cache first
        if !force, let cached = storage.loadGuide(), cached.addictionType == addiction, !cached.isStale {
            self.sections = cached.sections
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let content = try await geminiService.generateGuide(for: addiction)
                sections = parseContent(content)
                
                // Update favorites
                sections = sections.map { section in
                    var updatedSection = section
                    updatedSection.isFavorite = favoriteSections.contains { $0.title == section.title }
                    return updatedSection
                }
                
                // Cache the guide
                let guide = GuideContent(
                    addictionType: addiction,
                    sections: sections,
                    generatedDate: Date()
                )
                storage.saveGuide(guide)
                
            } catch GeminiError.invalidAPIKey {
                errorMessage = "API key not found. Please check your configuration."
            } catch GeminiError.networkError {
                errorMessage = "Failed to connect to the service. Please check your internet connection."
            } catch GeminiError.emptyAddictionType {
                errorMessage = "Please complete the onboarding process to set your addiction type."
            } catch {
                errorMessage = "An unexpected error occurred. Please try again."
            }
            isLoading = false
        }
    }
    
    func toggleFavorite(_ section: GuideSection) {
        if let index = sections.firstIndex(where: { $0.id == section.id }) {
            sections[index].isFavorite.toggle()
            
            if sections[index].isFavorite {
                favoriteSections.append(sections[index])
            } else {
                favoriteSections.removeAll { $0.id == section.id }
            }
            
            storage.saveFavorites(favoriteSections)
        }
    }
    
    private func parseContent(_ content: String) -> [GuideSection] {
        var sections: [GuideSection] = []
        let lines = content.components(separatedBy: .newlines)
        
        var currentTitle = ""
        var currentContent: [String] = []
        
        for line in lines {
            if line.hasPrefix("# ") {
                // Save previous section if exists
                if !currentTitle.isEmpty && !currentContent.isEmpty {
                    sections.append(GuideSection(
                        title: currentTitle,
                        content: currentContent.joined(separator: "\n")
                    ))
                }
                
                // Start new section
                currentTitle = line.replacingOccurrences(of: "# ", with: "")
                currentContent = []
            } else if !line.isEmpty {
                currentContent.append(line)
            }
        }
        
        // Add last section
        if !currentTitle.isEmpty && !currentContent.isEmpty {
            sections.append(GuideSection(
                title: currentTitle,
                content: currentContent.joined(separator: "\n")
            ))
        }
        
        return sections
    }
    
    func clearCache() {
        storage.clearCache()
    }
} 
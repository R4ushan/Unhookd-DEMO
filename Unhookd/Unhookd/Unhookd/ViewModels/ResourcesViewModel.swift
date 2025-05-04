import Foundation
import SwiftUI

struct ResourceMethod: Identifiable, Codable {
    var id: String
    let title: String
    let content: [String]
    var isExpanded: Bool
    
    init(id: String = UUID().uuidString, title: String, content: [String], isExpanded: Bool = false) {
        self.id = id
        self.title = title
        self.content = content
        self.isExpanded = isExpanded
    }
}

struct WithdrawalSymptom: Identifiable, Codable {
    var id: String
    let title: String
    let description: String
    
    init(id: String = UUID().uuidString, title: String, description: String) {
        self.id = id
        self.title = title
        self.description = description
    }
}

struct ResourceContent: Codable {
    let addictionType: String
    let introduction: String
    let encouragement: String
    let methods: [ResourceMethod]
    let withdrawalSymptoms: [WithdrawalSymptom]
    let generatedDate: Date
    
    var isStale: Bool {
        Calendar.current.dateComponents([.hour], from: generatedDate, to: Date()).hour ?? 0 > 24
    }
    
    enum CodingKeys: String, CodingKey {
        case addictionType, introduction, encouragement, methods, withdrawalSymptoms, generatedDate
    }
}

@MainActor
class ResourcesViewModel: ObservableObject {
    @Published var content: ResourceContent?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var methods: [ResourceMethod] = []
    @Published var withdrawalSymptoms: [WithdrawalSymptom] = []
    
    private let geminiService = GeminiService()
    private let storage = GuideStorage.shared
    
    func generateResources(for addiction: String, force: Bool = false) {
        guard !addiction.isEmpty else {
            errorMessage = "Please complete the onboarding process to set your addiction type."
            return
        }
        
        // Check cache first
        if !force, let cached = loadFromCache(), cached.addictionType == addiction, !cached.isStale {
            self.updateContent(cached)
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let content = try await geminiService.generateResources(for: addiction)
                let parsedContent = try parseContent(content, addiction: addiction)
                self.updateContent(parsedContent)
                saveToCache(parsedContent)
            } catch {
                errorMessage = "Failed to generate resources. Please try again."
            }
            isLoading = false
        }
    }
    
    private func updateContent(_ content: ResourceContent) {
        self.content = content
        self.methods = content.methods
        self.withdrawalSymptoms = content.withdrawalSymptoms
    }
    
    private func parseContent(_ content: String, addiction: String) throws -> ResourceContent {
        // Parse the JSON response from Gemini
        let decoder = JSONDecoder()
        guard let data = content.data(using: .utf8) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid content format"])
        }
        
        let parsedContent = try decoder.decode(ResourceContent.self, from: data)
        return parsedContent
    }
    
    private func loadFromCache() -> ResourceContent? {
        // Implementation would be similar to GuideStorage
        return nil // For now
    }
    
    private func saveToCache(_ content: ResourceContent) {
        // Implementation would be similar to GuideStorage
    }
} 
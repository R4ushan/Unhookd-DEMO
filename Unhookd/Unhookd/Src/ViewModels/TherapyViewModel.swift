import Foundation
import SwiftUI

@MainActor
class TherapyViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var inputMessage = ""
    
    private let geminiService = GeminiService()
    private let storage = GuideStorage.shared
    
    func sendMessage(_ message: String, addiction: String) {
        guard !message.isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(content: message, isUser: true)
        messages.append(userMessage)
        inputMessage = ""
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await geminiService.generateTherapyResponse(
                    userMessage: message,
                    addiction: addiction
                )
                
                // Add therapist response
                let therapistMessage = ChatMessage(content: response, isUser: false)
                messages.append(therapistMessage)
                
            } catch {
                errorMessage = "Failed to get response. Please try again."
            }
            isLoading = false
        }
    }
    
    func clearConversation() {
        messages.removeAll()
        geminiService.clearConversation()
    }
} 
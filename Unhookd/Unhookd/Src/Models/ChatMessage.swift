import Foundation

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
    let sentiment: Sentiment?
    
    init(id: UUID = UUID(), content: String, isUser: Bool, timestamp: Date = Date(), sentiment: Sentiment? = nil) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.sentiment = sentiment
    }
}

enum Sentiment: String, Codable {
    case positive
    case neutral
    case negative
    case mixed
} 
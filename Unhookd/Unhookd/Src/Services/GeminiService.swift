import Foundation
import GoogleGenerativeAI

enum GeminiError: Error {
    case invalidAPIKey
    case networkError(Error)
    case invalidResponse
    case decodingError
    case emptyAddictionType
    case emptyResponse
}

class GeminiService {
    private let model: GenerativeModel
    private var conversationHistory: [String] = []
    
    init() {
        // Initialize with the provided API key
        self.model = GenerativeModel(name: "gemini-pro", apiKey: "***")
    }
    
    func analyzeSentiment(_ text: String) async throws -> Sentiment {
        let prompt = """
        Analyze the emotional tone of the following text and classify it as one of these categories:
        - positive
        - neutral
        - negative
        - mixed
        
        Text: "\(text)"
        
        Respond with only the category name.
        """
        
        do {
            let response = try await model.generateContent(prompt)
            guard let text = response.text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) else {
                throw GeminiError.emptyResponse
            }
            
            return Sentiment(rawValue: text) ?? .neutral
        } catch {
            throw GeminiError.networkError(error)
        }
    }
    
    func generateTherapyResponse(userMessage: String, addiction: String) async throws -> String {
        // Analyze sentiment of user's message
        let sentiment = try await analyzeSentiment(userMessage)
        
        // Add user message to conversation history
        conversationHistory.append("User: \(userMessage)")
        
        // Keep only the last 5 messages for context
        if conversationHistory.count > 5 {
            conversationHistory.removeFirst(conversationHistory.count - 5)
        }
        
        let prompt = """
        You are a trained therapist specializing in \(addiction) addiction recovery. 
        The user's message shows a \(sentiment.rawValue) emotional tone.
        
        Previous conversation:
        \(conversationHistory.joined(separator: "\n"))
        
        User's latest message: \(userMessage)
        
        Respond as a supportive therapist would, considering:
        1. The user's emotional state
        2. Their addiction context
        3. The conversation history
        4. Evidence-based therapeutic techniques
        
        Keep your response empathetic, professional, and focused on recovery.
        """
        
        do {
            let response = try await model.generateContent(prompt)
            guard let text = response.text else {
                throw GeminiError.emptyResponse
            }
            
            // Add therapist response to conversation history
            conversationHistory.append("Therapist: \(text)")
            
            return text
        } catch {
            throw GeminiError.networkError(error)
        }
    }
    
    func clearConversation() {
        conversationHistory.removeAll()
    }

    func generateGuide(for addiction: String) async throws -> String {
        guard !addiction.isEmpty else {
            throw GeminiError.emptyAddictionType
        }
        
        let prompt = """
        Create a personalized recovery guide for someone dealing with \(addiction) addiction. Format the response in clear sections using Markdown.

        Structure the guide as follows:

        # Understanding Your Journey
        [Provide a brief, empathetic explanation of \(addiction) addiction, focusing on hope and the possibility of recovery]

        # Today's Action Steps
        - [List 3-4 specific, actionable steps they can take today to manage \(addiction) cravings]
        - [Make these very specific to \(addiction) addiction]

        # Coping Strategies
        - [List 5-6 evidence-based coping mechanisms specifically for \(addiction) addiction]
        - [Include both immediate and long-term strategies]

        # Healthy Alternatives
        - [Suggest 4-5 specific activities or alternatives to replace \(addiction)-related behaviors]
        - [Make these practical and easily implementable]

        # Progress Markers
        - [List 3-4 signs of progress specific to \(addiction) recovery]
        - [Include both small wins and significant milestones]

        # Emergency Plan
        1. [Provide 3 immediate actions to take during intense \(addiction) urges]
        2. [Include specific grounding techniques]
        3. [Add relevant crisis resources]

        # Daily Affirmations
        - [Include 3 powerful, personalized affirmations specific to \(addiction) recovery]

        Write in a supportive, encouraging tone. Focus on empowerment and growth. Avoid triggering language and ensure all advice is evidence-based and safe.
        """
        
        do {
            let response = try await model.generateContent(prompt)
            guard let text = response.text else {
                throw GeminiError.emptyResponse
            }
            return text
        } catch {
            throw GeminiError.networkError(error)
        }
    }

    func generateResources(for addiction: String) async throws -> String {
        let prompt = """
        Generate personalized resources for someone recovering from \(addiction) addiction. 
        Include:
        1. A brief introduction about the addiction
        2. Words of encouragement
        3. 5 specific methods to mitigate the addiction, each with 3-4 detailed steps
        4. 5 common withdrawal symptoms with descriptions
        
        Format the response as a JSON object with the following structure:
        {
            "introduction": "string",
            "encouragement": "string",
            "methods": [
                {
                    "title": "string",
                    "content": ["string", "string", "string"]
                }
            ],
            "withdrawalSymptoms": [
                {
                    "title": "string",
                    "description": "string"
                }
            ]
        }
        """
        
        do {
            let response = try await model.generateContent(prompt)
            guard let text = response.text else {
                throw GeminiError.emptyResponse
            }
            return text
        } catch {
            throw GeminiError.networkError(error)
        }
    }

    func generateJournalPrompts() async throws -> [String] {
        let prompt = """
        Generate 7 personalized journal prompts for someone recovering from addiction. 
        The prompts should be:
        1. Specific to addiction recovery
        2. Focused on self-reflection and growth
        3. Encouraging and supportive
        4. Action-oriented
        5. Varied in their approach (some emotional, some practical)
        
        Format the response as a JSON array of strings.
        """
        
        do {
            let response = try await model.generateContent(prompt)
            guard let text = response.text else {
                throw GeminiError.emptyResponse
            }
            
            // Parse the JSON response
            if let data = text.data(using: .utf8),
               let prompts = try? JSONDecoder().decode([String].self, from: data) {
                return prompts
            }
            
            throw GeminiError.invalidResponse
        } catch {
            throw GeminiError.networkError(error)
        }
    }
} 

import Foundation

enum AnimalLevel: Int, CaseIterable {
    case pig = 0
    case cow = 1
    case fox = 2
    case dog = 3
    case wolf = 4
    case lion = 5
    
    var name: String {
        switch self {
        case .pig: return "Pig"
        case .cow: return "Cow"
        case .fox: return "Fox"
        case .dog: return "Dog"
        case .wolf: return "Wolf"
        case .lion: return "Lion"
        }
    }
    
    var requiredXP: Int {
        switch self {
        case .pig: return 0
        case .cow: return 100
        case .fox: return 250
        case .dog: return 500
        case .wolf: return 1000
        case .lion: return 2000
        }
    }
}

class ProgressModel: ObservableObject {
    @Published var currentXP: Int = 0
    @Published var streakDays: Int = 0
    @Published var resistedCount: Int = 0
    @Published var relapsedCount: Int = 0
    
    var currentLevel: AnimalLevel {
        let level = AnimalLevel.allCases.last { currentXP >= $0.requiredXP }
        return level ?? .pig
    }
    
    var progressToNextLevel: Double {
        guard let nextLevel = AnimalLevel(rawValue: currentLevel.rawValue + 1) else {
            return 1.0 // Max level reached
        }
        
        let xpInCurrentLevel = Double(currentXP - currentLevel.requiredXP)
        let xpRequiredForNextLevel = Double(nextLevel.requiredXP - currentLevel.requiredXP)
        
        return xpInCurrentLevel / xpRequiredForNextLevel
    }
    
    func addXP(_ amount: Int) {
        currentXP += amount
    }
    
    func logResisted() {
        resistedCount += 1
        addXP(10) // Award XP for resisting
    }
    
    func logRelapsed() {
        relapsedCount += 1
        streakDays = 0 // Reset streak
    }
} 
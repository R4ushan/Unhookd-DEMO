import SwiftUI

struct AppTheme {
    // Colors
    static let primaryPurple = Color(red: 98/255, green: 0/255, blue: 238/255)
    static let backgroundWhite = Color(red: 250/255, green: 250/255, blue: 255/255)
    static let textPrimary = Color.black
    static let textSecondary = Color.gray
    static let inputBackground = Color.white
    static let inputBorder = Color(white: 0.9)
    
    // Layout
    static let cornerRadius: CGFloat = 12
    static let padding: CGFloat = 16
    
    // Effects
    static let shadowRadius: CGFloat = 4
    static let shadowOpacity: CGFloat = 0.1
    
    // Animation
    static let animationDuration: Double = 0.3
}

extension View {
    func primaryButton() -> some View {
        self.frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.primaryPurple)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            .padding(.horizontal)
    }
} 
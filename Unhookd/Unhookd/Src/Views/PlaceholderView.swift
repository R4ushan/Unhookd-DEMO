import SwiftUI

struct PlaceholderView: View {
    var body: some View {
        ZStack {
            AppTheme.backgroundWhite.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Coming Soon")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("This screen will be implemented in the next phase")
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }
}

#Preview {
    PlaceholderView()
} 
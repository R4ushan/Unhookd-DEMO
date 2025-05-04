import SwiftUI

struct OnboardingView: View {
    @State private var addiction: String = ""
    @State private var navigateNext = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundWhite.ignoresSafeArea()
                
                // Accent lines
                AccentLines()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Logo at the top
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 225)
                        .padding(.top, 50)
                        .padding(.bottom, 80)
                    
                    // Main content
                    VStack(spacing: 32) {
                        Text("What is your\naddiction?")
                            .font(.system(size: 32, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                        TextField("No judgement. This stays Private.", text: $addiction)
                            .padding()
                            .background(AppTheme.inputBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppTheme.inputBorder, lineWidth: 1)
                            )
                            .padding(.horizontal, 24)
                    }
                    
                    Spacer()
                    
                    // Bottom button
                    NavigationLink(destination: ReflectView(addiction: addiction), isActive: $navigateNext) {
                        Text("Next")
                            .primaryButton()
                    }
                    .disabled(addiction.isEmpty)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    OnboardingView()
} 

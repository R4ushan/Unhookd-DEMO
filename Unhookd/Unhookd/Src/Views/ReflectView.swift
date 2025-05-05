import SwiftUI

struct ReflectView: View {
    let addiction: String
    @State private var opacity = 0.0
    @State private var scale = 0.8
    @State private var shouldNavigate = false
    // TODO: Add a reflection prompt
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundWhite.ignoresSafeArea()
                
                // Accent lines
                AccentLines()
                    .ignoresSafeArea()
                
                Text("Reflect")
                    .font(.system(size: 48, weight: .regular))
                    .opacity(opacity)
                    .scaleEffect(scale)
            }
            .navigationDestination(isPresented: $shouldNavigate) {
                QuestionnaireView(addiction: addiction)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Animate in
            withAnimation(.easeOut(duration: 0.5)) {
                opacity = 1
                scale = 1
            }
            
            // Wait 2 seconds and navigate
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                shouldNavigate = true
            }
        }
    }
} 
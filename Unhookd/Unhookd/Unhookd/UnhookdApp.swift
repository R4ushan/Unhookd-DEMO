import SwiftUI

@main
struct UnhookdApp: App {
    @AppStorage("addictionType") private var addictionType: String = ""
    
    var body: some Scene {
        WindowGroup {
            if addictionType.isEmpty {
                OnboardingView()
            } else {
                HomeView()
            }
        }
    }
} 
import SwiftUI

struct GuideView: View {
    @AppStorage("addictionType") private var addictionType: String = ""
    @State private var expandedSection: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    Text("NICOTINE ADDICTION")
                        .font(.title)
                        .bold()
                    
                    Text("Nicotine addiction is biological, behavioral, and emotional–so quitting needs to be a multifaceted approach. The key is not willpower alone, but the right mix of support, substitution, tapering, and self-compassion.")
                        .foregroundColor(.gray)
                    
                    Text("Even one day without nicotine is progress. And each day builds your momentum. You got this!")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                // Methods Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Methods of Mitigating Addiction")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        CollapsibleSection(
                            title: "Tapering (Gradual Reduction)",
                            isExpanded: expandedSection == "tapering",
                            onTap: { expandedSection = expandedSection == "tapering" ? nil : "tapering" }
                        ) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• Set a realistic reduction schedule")
                                Text("• Track daily usage and gradually decrease")
                                Text("• Use timer-based intervals between usage")
                                Text("• Document triggers and patterns")
                            }
                            .padding()
                        }
                        
                        CollapsibleSection(
                            title: "Nicotine Replacement Therapy (NRT)",
                            isExpanded: expandedSection == "nrt",
                            onTap: { expandedSection = expandedSection == "nrt" ? nil : "nrt" }
                        ) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• Consult healthcare provider for options")
                                Text("• Consider patches, gum, or lozenges")
                                Text("• Follow recommended dosage")
                                Text("• Combine with behavioral strategies")
                            }
                            .padding()
                        }
                        
                        CollapsibleSection(
                            title: "Non-Nicotine Medications",
                            isExpanded: expandedSection == "medications",
                            onTap: { expandedSection = expandedSection == "medications" ? nil : "medications" }
                        ) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• Discuss prescription options with doctor")
                                Text("• Monitor side effects")
                                Text("• Complete full treatment course")
                                Text("• Regular check-ins with healthcare provider")
                            }
                            .padding()
                        }
                        
                        CollapsibleSection(
                            title: "Cognitive-Behavioral Therapy (CBT)",
                            isExpanded: expandedSection == "cbt",
                            onTap: { expandedSection = expandedSection == "cbt" ? nil : "cbt" }
                        ) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• Identify triggers and thought patterns")
                                Text("• Develop coping strategies")
                                Text("• Practice stress management")
                                Text("• Build resilience skills")
                            }
                            .padding()
                        }
                        
                        CollapsibleSection(
                            title: "Behavioral Substitution Tools",
                            isExpanded: expandedSection == "substitution",
                            onTap: { expandedSection = expandedSection == "substitution" ? nil : "substitution" }
                        ) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("• Exercise and physical activity")
                                Text("• Mindfulness and meditation")
                                Text("• Healthy snacks and hydration")
                                Text("• Hobby development")
                            }
                            .padding()
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct CollapsibleSection<Content: View>: View {
    let title: String
    let isExpanded: Bool
    let onTap: () -> Void
    let content: Content
    
    init(
        title: String,
        isExpanded: Bool,
        onTap: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.isExpanded = isExpanded
        self.onTap = onTap
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding()
                .background(AppTheme.primaryPurple.opacity(0.1))
                .cornerRadius(15)
            }
            
            if isExpanded {
                content
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .background(Color.white)
        .cornerRadius(15)
    }
}

#Preview {
    GuideView()
} 
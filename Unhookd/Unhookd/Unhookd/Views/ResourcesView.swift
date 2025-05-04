import SwiftUI

struct ResourcesView: View {
    @StateObject private var viewModel = ResourcesViewModel()
    @AppStorage("addictionType") private var addictionType: String = ""
    @State private var showingWithdrawalSymptoms = false
    @State private var showingOptions = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.padding) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text(addictionType.capitalized)
                            .font(.title2)
                            .bold()
                            .padding(.top)
                        Text("RECOVERY")
                            .font(.title2)
                            .bold()
                    }
                    
                    Spacer()
                    
                    // Options menu
                    Button(action: { showingOptions = true }) {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.primaryPurple)
                    }
                    .confirmationDialog("Options", isPresented: $showingOptions) {
                        Button("Regenerate Resources") {
                            viewModel.generateResources(for: addictionType, force: true)
                        }
                    }
                }
                
                if viewModel.isLoading {
                    LoadingView()
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage) {
                        viewModel.generateResources(for: addictionType)
                    }
                } else if let content = viewModel.content {
                    // Introduction
                    Text(content.introduction)
                        .foregroundColor(.gray)
                        .padding(.bottom)
                    
                    Text(content.encouragement)
                        .foregroundColor(.gray)
                        .padding(.bottom, AppTheme.padding * 2)
                    
                    Text("Methods of Mitigating Addiction")
                        .font(.headline)
                    
                    VStack(spacing: AppTheme.padding) {
                        ForEach($viewModel.methods) { $method in
                            VStack(spacing: 0) {
                                Button(action: { method.isExpanded.toggle() }) {
                                    HStack {
                                        Text(method.title)
                                            .font(.subheadline)
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                            .rotationEffect(.degrees(method.isExpanded ? 180 : 0))
                                    }
                                    .padding()
                                    .background(AppTheme.primaryPurple.opacity(0.1))
                                    .cornerRadius(AppTheme.cornerRadius)
                                }
                                
                                if method.isExpanded {
                                    VStack(alignment: .leading, spacing: 8) {
                                        ForEach(method.content, id: \.self) { line in
                                            Text(line)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                                .padding(.horizontal)
                                        }
                                    }
                                    .padding(.vertical)
                                    .background(Color.white)
                                    .cornerRadius(AppTheme.cornerRadius)
                                }
                            }
                        }
                    }
                    
                    Button(action: { showingWithdrawalSymptoms.toggle() }) {
                        Text("View Withdrawal Symptoms")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.primaryPurple)
                            .cornerRadius(AppTheme.cornerRadius)
                    }
                    .padding(.top)
                } else {
                    ContentUnavailableView {
                        Label("No Resources Generated", systemImage: "doc.text.image")
                    } description: {
                        Text("Tap the menu button to generate resources for your addiction type")
                    }
                }
            }
            .padding()
        }
        .onChange(of: addictionType) { _ in
            if !addictionType.isEmpty {
                viewModel.generateResources(for: addictionType)
            }
        }
        .sheet(isPresented: $showingWithdrawalSymptoms) {
            WithdrawalSymptomsView(symptoms: viewModel.withdrawalSymptoms)
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: AppTheme.padding) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Generating your personalized resources...")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .transition(.opacity)
    }
}

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: AppTheme.padding) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.orange)
            Text(message)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            Button("Try Again", action: retryAction)
                .foregroundColor(AppTheme.primaryPurple)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .transition(.opacity)
    }
}

struct WithdrawalSymptomsView: View {
    @Environment(\.dismiss) var dismiss
    let symptoms: [WithdrawalSymptom]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.padding) {
                    Text("Common withdrawal symptoms that may occur:")
                        .font(.headline)
                        .padding(.bottom)
                    
                    ForEach(symptoms) { symptom in
                        symptomSection(symptom.title, symptom.description)
                    }
                }
                .padding()
            }
            .navigationTitle("Withdrawal Symptoms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func symptomSection(_ title: String, _ description: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(description)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ResourcesView()
} 
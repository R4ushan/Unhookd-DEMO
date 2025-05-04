import SwiftUI

struct PeopleInputView: View {
    @Binding var text: String
    @State private var isNobody = false
    @State private var customInput = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Button(action: {
                isNobody.toggle()
                text = isNobody ? "Nobody" : ""
                customInput = ""
            }) {
                Text("Nobody")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isNobody ? AppTheme.primaryPurple : AppTheme.inputBackground)
                    .foregroundColor(isNobody ? .white : .black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppTheme.inputBorder, lineWidth: 1)
                    )
            }
            
            if !isNobody {
                TextField("Enter people", text: $customInput)
                    .onChange(of: customInput) { newValue in
                        text = newValue
                    }
                    .padding()
                    .background(AppTheme.inputBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppTheme.inputBorder, lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 24)
    }
} 
import SwiftUI

struct YesNoInputView: View {
    @Binding var selection: String
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: {
                selection = "Yes"
            }) {
                Text("Yes")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selection == "Yes" ? AppTheme.primaryPurple : AppTheme.inputBackground)
                    .foregroundColor(selection == "Yes" ? .white : .black)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppTheme.inputBorder, lineWidth: 1)
                    )
            }
            
            Button(action: {
                selection = "No"
            }) {
                Text("No")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selection == "No" ? AppTheme.primaryPurple : AppTheme.inputBackground)
                    .foregroundColor(selection == "No" ? .white : .black)
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
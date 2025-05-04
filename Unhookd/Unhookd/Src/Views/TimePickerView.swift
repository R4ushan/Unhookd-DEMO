import SwiftUI

struct TimePickerView: View {
    @Binding var selectedTime: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var date = Date()
    @State private var showPicker = true
    
    var body: some View {
        VStack(spacing: 24) {
            if showPicker {
                DatePicker("", selection: $date, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                
                HStack(spacing: 16) {
                    Button(action: {
                        selectedTime = "Skipped"
                        dismiss()
                    }) {
                        Text("Skip")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(AppTheme.primaryPurple)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button(action: {
                        let formatter = DateFormatter()
                        formatter.timeStyle = .short
                        selectedTime = formatter.string(from: date)
                        dismiss()
                    }) {
                        Text("Confirm")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.primaryPurple)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
} 
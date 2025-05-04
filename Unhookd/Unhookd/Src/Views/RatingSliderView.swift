import SwiftUI

struct RatingSliderView: View {
    @Binding var rating: String
    let lowLabel: String
    let highLabel: String
    @State private var sliderValue: Double = 1
    
    var body: some View {
        VStack(spacing: 20) {
            // Current value display
            Text("\(Int(sliderValue))")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(AppTheme.primaryPurple)
            
            // Slider
            GeometryReader { geometry in
                VStack(spacing: 8) {
                    Slider(value: $sliderValue, in: 1...10, step: 1)
                        .tint(AppTheme.primaryPurple)
                        .onChange(of: sliderValue) { newValue in
                            rating = String(Int(newValue))
                        }
                    
                    // Labels
                    HStack {
                        Text(lowLabel)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Spacer()
                        Text(highLabel)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: min(geometry.size.width, 300))
                .frame(maxWidth: .infinity)
            }
            .frame(height: 50)
        }
        .padding(.horizontal, 40)
        .onAppear {
            if let existingRating = Int(rating) {
                sliderValue = Double(existingRating)
            }
        }
    }
} 
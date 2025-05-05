import SwiftUI

struct AccentLines: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                // First curve (top right)
                path.move(to: CGPoint(x: geometry.size.width * 0.7, y: 0))
                path.addCurve(
                    to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.3),
                    control1: CGPoint(x: geometry.size.width * 0.85, y: 0),
                    control2: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.1)
                )
                
                // Second curve (bottom left)
                path.move(to: CGPoint(x: 0, y: geometry.size.height * 0.7))
                path.addCurve(
                    to: CGPoint(x: geometry.size.width * 0.3, y: geometry.size.height),
                    control1: CGPoint(x: 0, y: geometry.size.height * 0.9),
                    control2: CGPoint(x: geometry.size.width * 0.15, y: geometry.size.height)
                )
            }
            .stroke(AppTheme.primaryPurple, lineWidth: 2)
        }
    }
}

#Preview {
    AccentLines()
        .frame(width: 300, height: 300)
        .background(Color.white)
} 
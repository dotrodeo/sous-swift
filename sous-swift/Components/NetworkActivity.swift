import SwiftUI

struct RotatingGradientEllipse: View {
    let showActivity: Bool
    private let rotationDuration: Double = 4
    private let gradientColors: [Color]
    var position: Double
    var offset: Double

    @State private var hueRotation: Angle = .degrees(0)

    init(showActivity: Bool, position: Double = -0.67, offset: Double = 12) {
        self.showActivity = showActivity
        // Precompute 120 gradient colors once
        self.gradientColors = (0..<120).map { i in
            Color(hue: Double(i) / 120, saturation: 1, brightness: 1)
        }
        self.position = position
        self.offset = offset
    }

    var body: some View {
        GeometryReader { geo in
            Ellipse()
                .fill(
                    AngularGradient(
                        gradient: Gradient(colors: gradientColors),
                        center: .center
                    )
                )
                .hueRotation(hueRotation)
                .frame(
                    width: geo.size.width * 2.50,
                    height: geo.size.width * 1.25
                )
                .position(
                    x: geo.size.width * 0.4,
                    y: geo.size.width * position
                )
                .offset(y: showActivity ? offset : 0)
                .animation(.easeInOut(duration: 0.3), value: showActivity)
                .onAppear {
                    withAnimation(.linear(duration: rotationDuration).repeatForever(autoreverses: false)) {
                        hueRotation = .degrees(360)
                    }
                }
        }
    }
}

#Preview {
    RotatingGradientEllipse(showActivity: true)
}

import SwiftUI

struct WelcomeScreen: View {
    @State private var hueOffset: Double = 0
    var onPressGetStarted: () -> Void = {}
    var onPressSignIn: () -> Void = {}

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                RotatingGradientEllipse(
                    showActivity: true,
                    position: 0.1,
                    offset: 16
                )
                Ellipse()
                    .fill(Color("p_sous"))
                    .frame(
                        width: geometry.size.width * 2.50,
                        height: geometry.size.width * 1.25
                    )
                    .position(
                        x: geometry.size.width * 0.4,
                        y: geometry.size.width * 0.1
                    )
                VStack {
                    HStack {
                        Caprasimo("s")
                            .size(200)
                            .foregroundColor(.black)
                    }
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height / 3
                    )
                    VStack(spacing: 24) {
                        HStack(spacing: 4) {
                            Caprasimo("welcome to")
                                .size(24)
                            Caprasimo("sous")
                                .size(24)
                                .foregroundColor(Color.pSous)
                        }
                        VStack {
                            Poppins("your kitchen friend")
                                .size(14)
                                .weight(.regular)
                        }
                        if #available(iOS 26.0, *) {
                            Button(action: onPressGetStarted) {
                                Poppins("get started").weight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                            }
                            .buttonStyle(.glassProminent)
                        } else {
                            Button(action: onPressGetStarted) {
                                Poppins("get started").weight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        HStack {
                            Poppins("alredy have an account?")
                                .size(14)
                            Button(action: onPressSignIn) {
                                Poppins("sign in").weight(.medium).size(14)
                                    .foregroundColor(Color.pPrimary)
                            }
                        }
                    }
                    .padding(32)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height * 2 / 3
                    )
                }
            }
        }
        .background(Color.pBackground)
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

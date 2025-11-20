import SwiftUI

struct LoadingOverlay: View {
    @State private var showSecondaryText = false

    var body: some View {
        ZStack {
            Color.pPrimary
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Caprasimo("let me get that for you...")
                    .size(24)
                    .foregroundColor(.white)

                if showSecondaryText {
                    Poppins("this could take a minute")
                        .foregroundColor(.white)
                        .transition(.opacity)
                }
                ProgressView()
                    .tint(.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    LoadingOverlay()
}

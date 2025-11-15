import SwiftUI
import UIKit

/// A UIKit-backed blur view for SwiftUI (like native frosted glass).
struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        let effect = UIBlurEffect(style: blurStyle)
        let view = UIVisualEffectView(effect: effect)
        view.clipsToBounds = true
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}

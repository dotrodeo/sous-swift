import SwiftUI

struct Poppins: View {
    let text: String?
    let attributedText: AttributedString?
    private var size: CGFloat = 16
    private var weight: Weights = .light
    private var fontName: String {
        switch weight {
        case .light: return "Poppins-Light"
        case .regular: return "Poppins-Regular"
        case .medium: return "Poppins-Medium"
        case .bold: return "Poppins-Bold"
        }
    }

    enum Weights {
        case light
        case regular
        case medium
        case bold
    }

    init(_ text: String) {
        self.text = text
        self.attributedText = nil
    }
    
    init(_ text: AttributedString) {
        self.attributedText = text
        self.text = nil
    }

    var body: some View {
        if let attributedText {
            Text(attributedText)
                .font(Font.custom(fontName, size: size))
                .tint(.clear)
        } else {
            Text(text ?? "")
                .font(Font.custom(fontName, size: size))
                .tint(.clear) 
        }
    }
}

extension Poppins {
    var asText: Text {
        if let attributedText {
            Text(attributedText)
                .font(Font.custom(fontName, size: size))
        } else {
            Text(text ?? "")
                .font(Font.custom(fontName, size: size))
        }
    }
    
    func size(_ size: CGFloat) -> Self {
        var copy = self
        copy.size = size
        return copy
    }

    func weight(_ weight: Weights) -> Self {
        var copy = self
        copy.weight = weight
        return copy
    }
}

#Preview {
    Poppins("Boilerplate")
        .size(14)
        .weight(.light)
    Poppins("Boilerplate")
        .weight(.regular)
    Poppins("Boilerplate")
        .size(20)
        .weight(.medium)
    Poppins("Boilerplate")
        .size(32)
        .weight(.bold)
    Poppins("Boilerplate")
        .size(32)
        .weight(.bold)
        .asText
}

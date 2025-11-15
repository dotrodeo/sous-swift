import SwiftUI

struct Caprasimo: View {
    let text: String
    
    private var size: CGFloat = 16


    init(_ text: String) {
        self.text = text
    }

    var body: some View {
            Text(text)
                .font(Font.custom("Caprasimo-Regular", size: size))
                .textCase(.lowercase)
    }
}

extension Caprasimo {
    func size(_ size: CGFloat) -> Self {
        var copy = self
        copy.size = size
        return copy
    }
}

#Preview {
    Caprasimo("Boilerplate")

}

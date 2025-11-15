import SwiftUI

struct Boilerplate<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack {
            Poppins(title)
                .size(20)
                .weight(.medium)
            content
        }
        .padding()
        .border(Color.blue, width: 2)
    }
}

#Preview {
    Boilerplate(title: "Boilerplate") {
        Poppins("Hello, world!")
    }
}

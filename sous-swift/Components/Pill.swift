import SwiftUI

struct Pill<Content: View>: View {
    @ViewBuilder var content: Content
    var action: () -> Void
    var isActive: Bool = false

    init(
        action: @escaping () -> Void,
        isActive: Bool,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.action = action
        self.isActive = isActive
    }

    var body: some View {
        Button(action: action) {
            content
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .foregroundColor(isActive ? .white : Color("p_primary"))
                .background(
                    RoundedRectangle(cornerRadius: 99)
                        .fill(isActive ? Color("p_primary") : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 99)
                        .stroke(Color("p_primary"), lineWidth: 1)
                )
        }
        .padding(1)
    }
}

import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    var placeholder: String = "Search"

    var body: some View {
        VStack {
            Spacer()
            GlassEffectContainer {
                HStack(spacing: 16) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .padding(.leading, 16)

                        TextField(placeholder, text: $text)
                            .focused(isFocused)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .padding(.trailing, 16)
                            .padding(.vertical, 16)

                        if !text.isEmpty {
                            Button {
                                text = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                                    .padding(16)
                            }
                        }
                    }
                    .glassEffect()
                    if isFocused.wrappedValue {
                        Button {
                            isFocused.wrappedValue = false
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.secondary)
                                .padding(16)
                        }
                        .glassEffect()
                        .transition(
                            .move(edge: .trailing).combined(with: .opacity)
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.bottom, 16)
        .animation(.easeInOut(duration: 0.2), value: isFocused.wrappedValue)
        .ignoresSafeArea(.keyboard)
    }
}

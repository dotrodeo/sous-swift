import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding
    var placeholder: String = "search"

    var body: some View {
        VStack {
            Spacer()
            if #available(iOS 26.0, *) {
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
            } else {
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
                if isFocused.wrappedValue {
                    Button {
                        isFocused.wrappedValue = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.secondary)
                            .padding(16)
                    }
                    .transition(
                        .move(edge: .trailing).combined(with: .opacity)
                    )
                }
            }
        }
        .padding(.bottom, 16)
    }
}

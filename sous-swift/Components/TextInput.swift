import SwiftUI

struct TextInput<FieldType: Hashable>: View {
    var label: String? = nil
    var prompt: String? = nil
    @Binding var text: String
    @FocusState.Binding var focusedField: FieldType?
    let equals: FieldType
    var next: FieldType? = nil
    var isMultiline: Bool = false

    var body: some View {
        let isFocused = focusedField == equals
        VStack(spacing: 4) {
            if let label {
                HStack {
                    Poppins(label)
                        .size(14)
                        .weight(.medium)
                    Spacer()
                }
                .padding(.leading, 12)
            }
            ZStack {
                TextField(
                    label ?? "",
                    text: $text,
                    prompt: Poppins(prompt ?? "").asText,
                    axis: isMultiline ? .vertical : .horizontal
                )
                .padding(12)
                .focused($focusedField, equals: equals)
                .lineLimit(isMultiline ? 10 : 1)
                .textInputAutocapitalization(.never)
                .submitLabel(next == nil ? .go : .next)
                .onSubmit {
                    if let next = next {
                        focusedField = next
                    } else {
                        focusedField = nil
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isFocused
                                ? Color("p_primary") : Color.white.opacity(0.2),
                            lineWidth: 2
                        )
                        .onTapGesture {
                            focusedField = equals
                        }
                )
            }
        }
    }
}

extension TextInput {
    func multiline() -> Self {
        var copy = self
        copy.isMultiline = true
        return copy
    }
}

#Preview {
    struct PreviewHost: View {
        enum Field { case mailman, username, password }
        @FocusState private var focusedField: Field?
        @State private var email: String = ""
        @State private var username: String = ""
        @State private var password: String = ""

        var body: some View {
            VStack(spacing: 16) {
                Spacer()
                TextInput(
                    label: "email",
                    prompt: "bigboy@aol.com",
                    text: $email,
                    focusedField: $focusedField,
                    equals: .mailman,
                    next: .username
                )
                TextInput(
                    label: "username",
                    prompt: "cooldude69",
                    text: $username,
                    focusedField: $focusedField,
                    equals: .username,
                    next: .password
                )
                TextInput(
                    label: "password",
                    prompt: "********",
                    text: $password,
                    focusedField: $focusedField,
                    equals: .password
                )
                Spacer()
            }
            .padding(16)
            .task {
                focusedField = .username
            }
        }
    }

    return PreviewHost()
}

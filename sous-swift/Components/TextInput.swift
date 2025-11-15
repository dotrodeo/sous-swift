import SwiftUI

struct TextInput<FieldType: Hashable>: View {
    let label: String
    let prompt: String
    @Binding var text: String
    @FocusState.Binding var focusedField: FieldType?
    let equals: FieldType
    var next: FieldType? = nil

    var body: some View {
        let isFocused = focusedField == equals
        VStack(spacing: 4) {
            HStack {
                Poppins(label)
                    .size(14)
                    .weight(.medium)
                Spacer()
            }
            .padding(.leading, 16)
            ZStack {
                TextField(
                    label,
                    text: $text,
                    prompt: Poppins(prompt).asText
                )
                .focused($focusedField, equals: equals)
                .textInputAutocapitalization(.never)
                .submitLabel(next == nil ? .go : .next)
                .onSubmit {
                    if let next = next {
                        focusedField = next
                    } else {
                        focusedField = nil
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    Capsule()
                        .stroke(
                            isFocused
                                ? Color("p_primary") : Color.white.opacity(0.2),
                            lineWidth: 2
                        )
                )
            }
        }
    }
}

extension TextInput {

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

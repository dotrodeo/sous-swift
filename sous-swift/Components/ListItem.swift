import SwiftUI

struct ListItem<Left: View, Right: View>: View {
    let text: String
    let dimText: Bool
    let leftAdornment: Left
    let rightAdornment: Right

    init(
        text: String,
        dimText: Bool? = false,
        @ViewBuilder leftAdornment: () -> Left,
        @ViewBuilder rightAdornment: () -> Right
    ) {
        self.text = text
        self.dimText = dimText ?? false
        self.leftAdornment = leftAdornment()
        self.rightAdornment = rightAdornment()
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                leftAdornment
                Poppins(text)
                    .textCase(.lowercase)
                    .opacity(dimText ? 0.5 : 1.0)
                Spacer()
                rightAdornment
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
        }
        .contentShape(Rectangle())
        .listRowInsets(EdgeInsets())
    }
}

#Preview {
    struct PreviewHost: View {
        @State private var showingAlert: Bool = false

        var body: some View {

            VStack(spacing: 16) {
                List {
                    Section(header: Poppins("pressable & swipeable").asText) {
                        ListItem(
                            text: "Bean Enchiladas",
                            leftAdornment: {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 12, height: 12)
                            },
                            rightAdornment: {
                                ZStack {
                                    Poppins("8/11")
                                        .size(12)
                                        .font(.caption)
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(
                                    Color("p_background")
                                )
                                .cornerRadius(99)
                            }
                        )
                        .onTapGesture {
                            showingAlert = true
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {

                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {

                            } label: {
                                Label("Flag", systemImage: "flag")
                            }
                        }
                        ListItem(
                            text:
                                "Really really really really really long item name",
                            leftAdornment: {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 12, height: 12)
                            },
                            rightAdornment: {
                                ZStack {
                                    Poppins("8/11")
                                        .size(12)
                                        .font(.caption)
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(
                                    Color("p_background")
                                )
                                .cornerRadius(99)
                            }
                        )
                        .onTapGesture {
                            showingAlert = true
                        }
                        .swipeActions(edge: .leading) {
                            Button {

                            } label: {
                                Label("Flag", systemImage: "flag")
                            }
                        }
                    }
                    .listSectionSeparator(.hidden)
                    Section(header: Poppins("alternate adornments").asText) {
                        ListItem(
                            text: "Vegetable Curry",
                            leftAdornment: {
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(.green)
                            },
                            rightAdornment: {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        )
                        .onTapGesture {
                            showingAlert = true
                        }
                        ListItem(
                            text: "Vegetable Curry",
                            leftAdornment: {
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(.green)
                            },
                            rightAdornment: {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        )
                        .onTapGesture {
                            showingAlert = true
                        }
                    }
                    .listSectionSeparator(.hidden)
                }
                .listStyle(.plain)
            }
            .background(Color("p_background"))
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Important Message"),
                    message: Text("This is your alert message."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    return PreviewHost()
}

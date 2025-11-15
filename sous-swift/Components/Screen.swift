import SwiftUI

struct Screen<Content: View>: View {
    @Binding var isLoading: Bool
    @FocusState.Binding var isSearchFocused: Bool
    @Binding var searchText: String
    let title: String
    let content: Content

    init(
        title: String,
        isLoading: Binding<Bool>,
        isSearchFocused: FocusState<Bool>.Binding,
        searchText: Binding<String>,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self._isLoading = isLoading
        self._isSearchFocused = isSearchFocused
        self._searchText = searchText
        self.content = content()
    }

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                HStack {
                    Poppins(title)
                        .size(36)
                        .weight(.medium)
                    Spacer()
                }
                .padding(.horizontal, 16)
                content
                Spacer()
            }
            GeometryReader { geometry in
                Ellipse()
                    .fill(Color("p_sous"))
                    .frame(
                        width: geometry.size.width * 2.50,
                        height: geometry.size.width * 1.25
                    )
                    .position(
                        x: geometry.size.width * 0.4,
                        y: geometry.size.width * -0.67
                    )
            }
            SearchBarView(text: $searchText, isFocused: $isSearchFocused)

            if isLoading {
                LoadingOverlay()
                    .transition(.move(edge: .top))
                    .zIndex(1000)
            }
        }
        .toolbarColorScheme(.light)
    }
}

#Preview {
    struct PreviewHost: View {
        @State private var isLoading = false
        @State private var searchText = ""
        @FocusState private var isSearchFocused: Bool

        var body: some View {
            NavigationStack {
                Screen(
                    title: "screen",
                    isLoading: $isLoading,
                    isSearchFocused: $isSearchFocused,
                    searchText: $searchText
                ) {
                    Poppins("Hello, world!")
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("do magic", systemImage: "sparkles") {
                            // Action
                        }
                        .tint(Color("p_primary"))
                        .buttonStyle(.glassProminent)
                    }
                }
            }
        }
    }
    return PreviewHost()
}

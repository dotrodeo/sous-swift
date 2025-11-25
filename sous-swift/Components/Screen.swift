import SwiftUI

struct Screen<TitleView: View, Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isLoading: Bool
    var isSearchFocused: FocusState<Bool>.Binding?
    @Binding var searchText: String?
    @Binding var buttonIsDisabled: Bool
    var buttonAction: (() async -> Void)? = nil
    
    let titleView: TitleView
    let content: Content

    init(
        title: String,
        isLoading: Binding<Bool>,
        isSearchFocused: FocusState<Bool>.Binding? = nil,
        searchText: Binding<String?>? = nil,
        buttonIsDisabled: Binding<Bool>? = nil,
        buttonAction: (() async -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) where TitleView == Poppins {
        self.titleView = Poppins(title)
            .size(36)
            .weight(.medium)

        self._isLoading = isLoading
        self.isSearchFocused = isSearchFocused
        self._searchText = searchText ?? .constant(nil)
        self._buttonIsDisabled = buttonIsDisabled ?? .constant(false)
        self.buttonAction = buttonAction
        self.content = content()
    }

    init(
        @ViewBuilder title: () -> TitleView,
        isLoading: Binding<Bool>,
        isSearchFocused: FocusState<Bool>.Binding? = nil,
        searchText: Binding<String?>? = nil,
        buttonIsDisabled: Binding<Bool>? = nil,
        buttonAction: (() async -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.titleView = title()

        self._isLoading = isLoading
        self.isSearchFocused = isSearchFocused
        self._searchText = searchText ?? .constant(nil)
        self._buttonIsDisabled = buttonIsDisabled ?? .constant(false)
        self.buttonAction = buttonAction
        self.content = content()
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    titleView
                    Spacer()
                    if let buttonAction {
                        SaveButton(isSaving: $buttonIsDisabled, onTap: buttonAction)
                    }
                }
                .padding(16)
                .background(Color.pBackground)

                content
            }
            
            RotatingGradientEllipse(showActivity: isLoading)

            GeometryReader { geometry in
                Ellipse()
                    .fill(colorScheme == .dark ? Color.pPrimary : Color.pSous)
                    .frame(
                        width: geometry.size.width * 2.50,
                        height: geometry.size.width * 1.25
                    )
                    .position(
                        x: geometry.size.width * 0.4,
                        y: geometry.size.width * -0.67
                    )
            }

            if let isSearchFocused {
                SearchBarView(
                    text: optionalStringBinding($searchText),
                    isFocused: isSearchFocused
                )
            }

            // TODO: Revisit this when data logic is more stable
            //            if isLoading {
            //                LoadingOverlay()
            //                    .transition(.move(edge: .top))
            //                    .zIndex(1000)
            //            }
        }
    }

    private func optionalStringBinding(_ binding: Binding<String?>) -> Binding<String> {
        Binding<String>(
            get: { binding.wrappedValue ?? "" },
            set: { binding.wrappedValue = $0 }
        )
    }
}

#Preview {
    struct PreviewHost: View {
        @State private var isLoading = true
        @State private var searchText: String? = ""
        @State private var buttonIsDisabled: Bool = false
        @FocusState private var isSearchFocused: Bool

        var body: some View {
            NavigationStack {
                // With search
                Screen(
                    title: "screen",
                    isLoading: $isLoading,
                    isSearchFocused: $isSearchFocused,
                    searchText: $searchText,
                    buttonIsDisabled: $buttonIsDisabled,
                    buttonAction: {
                        try? await Task.sleep(nanoseconds: 500_000_000)
                    }
                ) {
                    Poppins("Hello, world!")
                    Spacer()
                }
                .toolbar {
                    ToolbarButton(text: "Do Magic", icon: "sparkles", action: {})
                }
            }
        }
    }
    return PreviewHost()
}

import SwiftData
import SwiftUI

struct HighlightedTextView: View {
    let segments: [HighlightedSegment]
    let onTapHighlight: (HighlightedSegment) -> Void

    var body: some View {
        Poppins(makeAttributedString())
            .size(32)
            .weight(.regular)
            .foregroundColor(Color.pBackground)
            .environment(
                \.openURL,
                OpenURLAction { url in
                    handle(url)
                    return .handled
                }
            )
    }

    private func makeAttributedString() -> AttributedString {
        var result = AttributedString()

        for segment in segments {
            var chunk = AttributedString(segment.text)

            if segment.isHighlighted {
                chunk.foregroundColor = Color.pBackground
                chunk.underlineStyle = .single
                chunk.link = URL(
                    string: "highlight://\(segment.id.uuidString)"
                )!
            }

            result += chunk
        }

        return result
    }

    private func handle(_ url: URL) {
        guard url.scheme == "highlight",
            let uuid = UUID(uuidString: url.host ?? url.lastPathComponent),
            let seg = segments.first(where: { $0.id == uuid })
        else { return }

        onTapHighlight(seg)
    }
}

private struct IdentifiedString: Identifiable, Hashable {
    let id = UUID()
    let value: String
}

struct BigModeView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @StateObject private var viewModel: RecipeViewModel
    @Binding var path: NavigationPath
    private var recipeId: Recipe.ID?

    @State private var isLoading: Bool = false
    @State private var selectedIngredient: IdentifiedString?

    init(
        path: Binding<NavigationPath>,
        recipeId: Recipe.ID,
        recipeService: RecipeServiceProtocol,
        pantryService: PantryServiceProtocol
    ) {
        _path = path
        self.recipeId = recipeId
        _viewModel = StateObject(
            wrappedValue: RecipeViewModel(
                recipeId: recipeId,
                recipeService: recipeService,
                pantryService: pantryService
            )
        )
    }

    var ingredients: [String] {
        (viewModel.recipe?.ingredients ?? []).map { $0.sentence }
    }

    var body: some View {
        let instructions = viewModel.recipe?.instructions ?? [""]

        Swiper {
            ForEach(instructions.indices, id: \.self) { index in
                let instruction = instructions[index]
                let highlighted = InstructionHighlighter().highlight(
                    ingredients: ingredients,
                    instruction: instruction
                )

                ScrollView {
                    VStack(spacing: 16) {
                        Poppins("\(index + 1)")
                            .size(64)
                            .weight(.bold)
                            .foregroundColor(Color.pBackground)

                        HighlightedTextView(segments: highlighted) { tapped in
                            if let full = tapped.match?.item.fullIngredient {
                                selectedIngredient = IdentifiedString(
                                    value: full
                                )
                            }
                            print(tapped.match ?? "")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 64)
                    .padding(.bottom, 176)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .background(Color.pPrimary)
        .ignoresSafeArea()
        .toolbar(.hidden, for: .tabBar)
        .overlay(alignment: .bottom) {
            ZStack {
                if let selectedIngredient {
                    ZStack {
                        Poppins(selectedIngredient.value)
                            .size(16)
                            .weight(.medium)
                            .foregroundColor(.black)
                            .padding(16)
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.pPink)
                            }
                    }
                    .padding(.bottom, 32)
                    .transition(
                        .move(edge: .bottom)
                    )
                }
            }
            .animation(
                .spring(response: 0.35, dampingFraction: 0.8),
                value: selectedIngredient
            )
        }
        .onTapGesture {
            selectedIngredient = nil
        }
        .task {
            if recipeId != nil {
                await viewModel.loadRecipe()
            }
        }
        .onChange(of: viewModel.isLoading) { _, newValue in
            withAnimation(.easeInOut(duration: 0.4)) {
                isLoading = newValue
            }
        }
    }
}

import SwiftData
import SwiftUI

struct BigModeView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @StateObject private var viewModel: RecipeViewModel
    @Binding var path: NavigationPath
    private var recipeId: Recipe.ID?

    @State private var isLoading: Bool = false

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

    var body: some View {
        let instructions = viewModel.recipe?.instructions ?? [""]

        Swiper {
            ForEach(instructions.indices, id: \.self) { index in
                let instruction = instructions[index]

                ScrollView {
                    VStack(spacing: 16) {
                        Poppins("\(index + 1)")
                            .size(64)
                            .weight(.bold)
                            .foregroundColor(Color.pBackground)

                        Poppins(instruction)
                            .size(sizeClass == .regular ? 48 : 32)
                            .weight(.regular)
                            .foregroundColor(Color.pBackground)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 64)
                    .padding(.bottom, 128)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .background(Color.pPrimary)
        .ignoresSafeArea()
        .toolbar(.hidden, for: .tabBar)
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

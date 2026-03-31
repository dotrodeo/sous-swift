import SwiftUI

struct RecipesView: View {
    @StateObject private var viewModel: RecipesViewModel
    @Binding var path: NavigationPath

    @FocusState private var isSearchFocused: Bool
    @State private var selectedTags: Set<String> = []

    init(
        path: Binding<NavigationPath>,
        recipeService: RecipeServiceProtocol,
        pantryService: PantryServiceProtocol
    ) {
        _path = path
        _viewModel = StateObject(
            wrappedValue: RecipesViewModel(
                recipeService: recipeService,
                pantryService: pantryService
            )
        )
    }

    var body: some View {
        Screen(
            title: "recipes",
            isLoading: $viewModel.isLoading,
            isSearchFocused: $isSearchFocused,
            searchText: $viewModel.searchText
        ) {
            RecipeFilters(
                tags: viewModel.recipeTags,
                selectedTags: $viewModel.selectedTags
            )

            List {
                Section {
                    ForEach(
                        viewModel.filteredRecipesPublished
                    ) { recipe in
                        RecipeRow(
                            recipe: recipe,
                            ratio: RecipeHelper.ratio(
                                for: recipe,
                                pantryItems: viewModel.pantry?.pantryItems ?? []
                            ),
                            onTap: {
                                path.append(RecipeRoute.recipeDetail(recipe.id))
                            },
                            onDelete: {
                                Task {
                                    await viewModel.deleteRecipe(recipe)
                                }
                            }
                        )
                    }
                }
            }
            .overlay {
                if viewModel.recipes.isEmpty {
                    ContentUnavailableView(
                        "You don't have any recipes",
                        systemImage: "book",
                        description: Text("Tap the + button to get started")
                    )
                    .offset(x: 0, y: -100)
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .listStyle(.inset)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80)
            }
        }
        .task {
            await viewModel.refresh()
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                ToolbarButton(
                    text: "New Recipe",
                    icon: "plus",
                    action: { path.append(RecipeRoute.editRecipe(nil)) }
                )
            }
        }
        // Present errors from the view model as an alert
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { present in if !present { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
    }
}

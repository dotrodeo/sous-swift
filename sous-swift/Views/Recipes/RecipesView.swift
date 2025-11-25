import SwiftData
import SwiftUI

struct RecipesView: View {
    @StateObject private var viewModel: RecipesViewModel
    @Binding var path: NavigationPath

    @State private var isLoading: Bool = false
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
            isLoading: $isLoading,
            isSearchFocused: $isSearchFocused,
            searchText: $viewModel.searchText
        ) {
            RecipeFilters(
                tags: viewModel.recipeTags,
                selectedTags: $selectedTags
            )

            List {
                Section {
                    ForEach(
                        viewModel.filteredRecipes(selectedTags: selectedTags)
                    ) { recipe in
                        RecipeRow(
                            recipe: recipe,
                            ratio: viewModel.ratio(
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
            isLoading = true
            await viewModel.refresh()
            isLoading = false
        }
        .onChange(of: viewModel.isLoading) { _, newValue in
            withAnimation(.easeInOut(duration: 0.4)) {
                isLoading = newValue
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                //                ToolbarButton(text: "Suggest Recipes", icon: "sparkles", action: {})
                ToolbarButton(
                    text: "New Recipe",
                    icon: "plus",
                    action: { path.append(RecipeRoute.editRecipe(nil)) }
                )
            }
        }

    }
}

#Preview {
    RecipeNavigator(startingRoute: RecipeRoute.recipeList)
}

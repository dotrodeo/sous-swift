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
                            )
                        ) {
                            path.append(RecipeRoute.recipeDetail(recipe.id))
                        }
                    }
                    Color.clear
                        .frame(height: 150)
                        .listRowInsets(.init())
                        .listRowSeparator(.hidden)
                }
                .listRowBackground(Color.pSurface)
            }
            .refreshable {
                await viewModel.refresh()
            }
            .listStyle(.plain)
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
                Button("suggest recipes", systemImage: "sparkles") {}
                    .tint(Color("p_primary"))
                    .buttonStyle(.glassProminent)

                Button("new recipe", systemImage: "plus") {
                    path.append(RecipeRoute.editRecipe(nil))
                }
                .tint(Color("p_primary"))
                .buttonStyle(.glassProminent)
            }
        }

    }
}

#Preview {
    RecipeNavigator(startingRoute: RecipeRoute.recipeList)
}

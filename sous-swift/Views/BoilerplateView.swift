import SwiftData
import SwiftUI

struct BoilerplateView: View {
  //    @Binding var path: NavigationPath

  @State private var isLoading: Bool = false
  @StateObject private var viewModel = RecipesViewModel(
    recipeApi: RecipeService(householdId: 1),
    pantryApi: PantryService(householdId: 1)
  )
  @FocusState private var isSearchFocused: Bool
  @State private var selectedTags: Set<String> = []

  var body: some View {
    Screen(
      title: "boilerplate",
      isLoading: $isLoading,
      isSearchFocused: $isSearchFocused,
      searchText: $viewModel.searchText
    ) {
      RecipeFilters(tags: [], selectedTags: $selectedTags)

      List {
        Section {
          ForEach(viewModel.filteredRecipes(selectedTags: [])) { recipe in
            RecipeRow(
              recipe: recipe,
              ratio: viewModel.ratio(
                for: recipe,
                pantryItems: viewModel.pantry?.pantryItems ?? []
              )
            ) {
              //                            path.append(RecipeRoute.recipeDetail(recipe.id))
            }
          }
        }
      }
      .refreshable {
        isLoading = true
        await viewModel.refresh()
        isLoading = false
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
      ToolbarItem(placement: .topBarTrailing) {
        Button("suggest recipes", systemImage: "sparkles") {}
          .tint(Color("p_primary"))
          .buttonStyle(.glassProminent)
      }
      ToolbarItem(placement: .topBarTrailing) {
        Button("new recipe", systemImage: "plus") {
          //                    path.append(RecipeRoute.editRecipe(nil))
        }
        .tint(Color("p_primary"))
        .buttonStyle(.glassProminent)
      }
    }
  }
}

#Preview {
  NavigationStack {
    BoilerplateView()
  }
}

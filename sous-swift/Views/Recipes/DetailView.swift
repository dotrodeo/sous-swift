import SwiftData
import SwiftUI

struct LeftAdornment {
    var icon: String
    var color: Color
}

struct PantryMatchedIngredient: Identifiable {
    let id: Ingredient.ID
    let ingredient: Ingredient
    let pantryItem: PantryItem?
}

struct RecipeDetailView: View {
    @StateObject private var viewModel: RecipeViewModel
    @Binding var path: NavigationPath
    private var recipeId: Recipe.ID?

    @State private var showMadeRecipeModal: Bool = false
    @State private var pantryMatchedIngredients: [PantryMatchedIngredient] = []

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
        let recipe = viewModel.recipe
        Screen(
            title: { Caprasimo(recipe?.name ?? "").size(36) },
            isLoading: $viewModel.isLoading
        ) {
            ScrollView {
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        HStack {
                            Poppins("prep time")
                                .size(12)
                                .weight(.medium)
                            Poppins(recipe?.prepTime ?? "")
                                .size(12)
                        }
                        HStack {
                            Poppins("cook time")
                                .size(12)
                                .weight(.medium)
                            Poppins(recipe?.cookTime ?? "")
                                .size(12)
                        }
                        Spacer()
                    }
                    HStack {
                        Poppins("ingredients")
                            .size(24)
                            .weight(.medium)
                        Spacer()
                    }
                    ForEach(recipe?.ingredients ?? []) { ingredient in
                        ingredientListing(ingredient: ingredient)
                    }
                    HStack {
                        Poppins("instructions")
                            .size(24)
                            .weight(.medium)
                        Spacer()
                    }
                    ForEach(
                        Array(
                            (recipe?.instructions ?? []).enumerated()
                        ),
                        id: \.offset
                    ) { index, instruction in
                        HStack(spacing: 0) {
                            VStack {
                                HStack {
                                    Poppins("\(index + 1)")
                                        .size(32)
                                        .weight(.bold)
                                        .offset(y: -4)
                                    Spacer()
                                }
                                Spacer()
                            }
                            .frame(width: 48)
                            HStack {
                                Poppins(instruction)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(
                                        horizontal: false,
                                        vertical: true
                                    )
                                Spacer()
                            }
                        }
                    }
                    Color.clear
                        .frame(height: 72)
                        .listRowInsets(.init())
                        .listRowSeparator(.hidden)
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            
        }
        .sheet(isPresented: $showMadeRecipeModal) {
            if let recipe = viewModel.recipe {
                IMadeThisModal(recipe: recipe, ingredients: pantryMatchedIngredients) { recipeCompletion in
                    await viewModel.completeRecipe(id: recipe.id, completion: recipeCompletion)
                    showMadeRecipeModal = false
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        if let id = viewModel.recipe?.id {
                            path.append(RecipeRoute.bigMode(id))
                        }
                    } label: {
                        Label("Let's Cook", systemImage: "frying.pan.fill")
                    }
                    Button {
                        showMadeRecipeModal = true
                    } label: {
                        Label("I Made This", systemImage: "checkmark")
                    }
                    Button {
                        if let id = viewModel.recipe?.id {
                            path.append(RecipeRoute.editRecipe(id))
                        }
                    } label: {
                        Label("Edit Recipe", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        Task {
                            if let recipe = viewModel.recipe {
                                await viewModel.deleteRecipe(recipe)
                            }
                        }
                    } label: {
                        Label("Delete Recipe", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis").padding(8)
                }
            }
        }
        .task {
            await viewModel.loadRecipe()
        }
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

extension RecipeDetailView {
    func ingredientListing(ingredient: Ingredient) -> some View {
        let cachedMatch = pantryMatchedIngredients.first(where: { $0.id == ingredient.id })

        let adornment = getLeftAdornment(
            pantryItem: cachedMatch?.pantryItem
        )

        return
            HStack {
                Image(
                    systemName: adornment.icon
                )
                .foregroundColor(adornment.color)
                .onTapGesture(perform: {
                    Task {
                        let item =
                            cachedMatch?.pantryItem == nil
                            ? PantryItemPatch(name: ingredient.item)
                            : PantryItemPatch(from: (cachedMatch?.pantryItem!)!)
                        if !(item.isInShoppingList ?? false) {
                            await viewModel.addToShoppingList(
                                item
                            )
                        }
                    }
                })
                Poppins(ingredient.sentence)
                Spacer()
            }
    }
    
    func updatePantryMatches() {
        guard let ingredients = viewModel.recipe?.ingredients else { return }
        pantryMatchedIngredients = ingredients.map { ingredient in
            PantryMatchedIngredient(
                id: ingredient.id,
                ingredient: ingredient,
                pantryItem: viewModel.matchToPantryItem(ingredient.item ?? "")
            )
        }
    }

    func getLeftAdornment(pantryItem: PantryItem?) -> LeftAdornment {
        guard let pantryItem else {
            return LeftAdornment(icon: "plus.circle", color: Color.pForeground)
        }

        if pantryItem.isInShoppingList {
            return LeftAdornment(
                icon: "cart.circle",
                color: Color.pForeground.opacity(0.5)
            )
        } else if pantryItem.isInStock {
            return LeftAdornment(
                icon: "plus.arrow.trianglehead.clockwise",
                color: Color.pSuccess
            )
        } else {
            return LeftAdornment(icon: "plus.circle", color: Color.pForeground)
        }
    }

}

//#Preview {
//    NavigationStack {
//        RecipeNavigator(startingRoute: RecipeRoute.recipeDetail(13))
//    }
//}

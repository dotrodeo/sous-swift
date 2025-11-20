import SwiftData
import SwiftUI

struct LeftAdornment {
    var icon: String
    var color: Color
}

struct RecipeDetailView: View {
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

    private func getLeftAdornment(pantryItem: PantryItem?) -> LeftAdornment {
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

    var body: some View {
        let recipe = viewModel.recipe
        Screen(
            title: { Caprasimo(recipe?.name ?? "").size(36) },
            isLoading: $isLoading
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
                    } label: {
                        Label("Delete Recipe", systemImage: "trash")
                    }
                } label: {
                    if #available(iOS 26.0, *) {
                        Button {
                        } label: {
                            Label("Options", systemImage: "ellipsis")
                        }
                        .tint(Color("p_primary"))
                        .buttonStyle(.glassProminent)
                    } else {
                        Button {
                        } label: {
                            Label("Options", systemImage: "ellipsis")
                        }
                        .tint(Color("p_primary"))
                    }
                }
            }
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

extension RecipeDetailView {
    func ingredientListing(ingredient: Ingredient) -> some View {

        let pantryItem = viewModel.matchToPantryItem(
            ingredient.item ?? ""
        )
        let adornment = getLeftAdornment(
            pantryItem: pantryItem
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
                            pantryItem == nil
                            ? PantryItemPatch(name: ingredient.item)
                            : PantryItemPatch(from: pantryItem!)
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
}

//#Preview {
//    NavigationStack {
//        RecipeNavigator(startingRoute: RecipeRoute.recipeDetail(13))
//    }
//}

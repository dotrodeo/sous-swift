import SwiftUI

enum Rating: Int, Codable {
    case thumbsUp = 1
    case thumbsDown = -1
}

struct IMadeThisModal: View {
    var recipe: Recipe?
    var ingredients: [PantryMatchedIngredient]? = []
    var onSave: (RecipeCompletion) async -> Void
    @State private var isSaving: Bool = false
    @State private var pantryItemStates: [Int: Bool] = [:]
    @State private var rating: Rating?

    func getFinishedPantryItems() -> [Int] {
        return
            pantryItemStates
            .filter { $0.value == true }
            .map { $0.key }
    }

    var body: some View {
        let filteredIngredients =
            ingredients?.filter { $0.pantryItem != nil } ?? []
        let madeThisText =
            recipe?.timesMade == 0
            ? "you made this recipe for the first time!"
            : "you've made this recipe **\(recipe?.timesMade ?? 0)** times!"
        VStack(spacing: 24) {
            HStack {
                Poppins("nice job 😎")
                    .size(32)
                    .weight(.medium)
                    .foregroundColor(Color.pBackground)
                Spacer()
                SaveButton(isSaving: $isSaving, buttonText: "done") {
                    if let recipe {
                        await onSave(
                            RecipeCompletion(
                                recipeId: recipe.id,
                                rating: rating,
                                finishedPantryItems: getFinishedPantryItems()
                            )
                        )
                    }
                }
            }
            HStack {
                Text(.init(madeThisText))
                    .font(Font.custom("Poppins-Regular", size: 28))
                    .tint(.clear)
                    .foregroundColor(Color.pBackground)
                Spacer()
            }
            VStack(spacing: 16) {
                Poppins("what did you think?")
                    .foregroundColor(Color.pBackground)
                HStack(spacing: 32) {
                    Image(systemName: "hand.thumbsup.circle")
                        .font(.system(size: 60))
                        .foregroundColor(
                            rating == .thumbsUp
                                ? Color.pPrimary
                                : Color.pBackground.opacity(0.3)
                        )
                        .onTapGesture {
                            rating = rating == .thumbsUp ? nil : .thumbsUp
                        }
                    Image(systemName: "hand.thumbsdown.circle")
                        .font(.system(size: 60))
                        .foregroundColor(
                            rating == .thumbsDown
                                ? Color.pPrimary
                                : Color.pBackground.opacity(0.3)
                        )
                        .onTapGesture {
                            rating = rating == .thumbsDown ? nil : .thumbsDown
                        }
                }
            }
            HStack {
                Poppins("did you run out of anything?")
                    .size(20)
                    .weight(.medium)
                    .foregroundColor(Color.pBackground)
                Spacer()
            }
            List {
                ForEach(filteredIngredients, id: \.id) { ingredient in
                    if let item = ingredient.pantryItem {
                        HStack {
                            if item.isFavorite {
                                Image(systemName: "repeat")
                                    .foregroundColor(Color.pPrimary)
                            } else {
                                ZStack {}
                                    .frame(width: 24, height: 24)
                            }
                            Toggle(
                                item.name.lowercased(),
                                isOn: Binding(
                                    get: { pantryItemStates[item.id] ?? false },
                                    set: { pantryItemStates[item.id] = $0 }
                                )
                            )
                            .tint(item.isFavorite ? Color.pPrimary : Color.pError)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.pSurface.opacity(0.3))
        }
        .padding(.horizontal, 16)
        .padding(.top, 32)
        .background(Color.pSuccess)
        .onAppear {
            if let ingredients = ingredients {
                for ingredient in ingredients {
                    if let item = ingredient.pantryItem {
                        pantryItemStates[item.id] = false
                    }
                }
            }
        }
    }
}

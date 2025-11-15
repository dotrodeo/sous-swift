import SwiftData
import SwiftUI

struct RecipeEditView: View {
    let recipeId: Recipe.ID?

    enum Field {
        case name
        case prepTime
        case cookTime
        case servings
    }

    @StateObject private var viewModel = RecipeViewModel(
        recipeApi: RecipeService(householdId: 1)
    )
    @State private var recipe: Recipe?
    @State private var name: String = ""
    @State private var prepTime: String = ""
    @State private var cookTime: String = ""
    @State private var servings: String = ""
    @FocusState private var focusedField: Field?

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
                .onTapGesture {
                    focusedField = nil
                }
            VStack(spacing: 24) {
                HStack {
                    Poppins(recipeId == nil ? "new recipe" : "edit recipe")
                        .size(36)
                        .weight(.medium)
                    Spacer()
                }
                TextInput(
                    label: "name",
                    prompt: "hot tamales",
                    text: $name,
                    focusedField: $focusedField,
                    equals: .name,
                    next: .prepTime
                )
                TextInput(
                    label: "prep time",
                    prompt: "15 minutes",
                    text: $prepTime,
                    focusedField: $focusedField,
                    equals: .prepTime,
                    next: .cookTime
                )
                TextInput(
                    label: "cook time",
                    prompt: "30 minutes",
                    text: $cookTime,
                    focusedField: $focusedField,
                    equals: .cookTime,
                    next: .servings
                )
                TextInput(
                    label: "servings",
                    prompt: "5-6",
                    text: $servings,
                    focusedField: $focusedField,
                    equals: .servings
                )
                Spacer()
            }
            .padding(.horizontal, 16)
            GeometryReader { geometry in
                Ellipse()
                    .fill(Color("p_sous"))
                    .frame(
                        width: geometry.size.width * 2.50,
                        height: geometry.size.width * 1.25
                    )
                    .position(
                        x: geometry.size.width * 0.4,
                        y: geometry.size.width * -0.7
                    )
            }
        }
        .toolbarColorScheme(.light)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if #available(iOS 26.0, *) {
                    Button("edit recipe", systemImage: "pencil") {
                        // Action
                    }
                    .tint(Color("p_primary"))
                    .buttonStyle(.glassProminent)
                } else {
                    Button("edit recipe", systemImage: "pencil") {
                        // Action
                    }
                }
            }
        }
        .task {
            if recipeId != nil {
                await viewModel.loadRecipe(id: recipeId!)
            }
        }
        .onChange(of: viewModel.recipe, initial: false) { _, recipeData in
            guard let recipeData else { return }
            recipe = recipeData
            name = recipeData.name
            prepTime = recipeData.prepTime ?? ""
            cookTime = recipeData.cookTime ?? ""
            servings = recipeData.servings ?? ""
        }
    }
}

#Preview {
    NavigationStack {
        RecipeEditView(recipeId: nil)
    }
}

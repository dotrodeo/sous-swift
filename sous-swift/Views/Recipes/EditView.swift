import SwiftData
import SwiftUI

struct PasteError: Identifiable {
    let id = UUID()
    let message: String
}

struct RecipeEditView: View {
    enum Field: Hashable {
        case name
        case prepTime
        case cookTime
        case servings
        case ingredient(Int)
        case instruction(Int)
    }

    @StateObject private var viewModel: RecipeViewModel
    @Binding var path: NavigationPath
    private var recipeId: Recipe.ID?
    
    init(
        path: Binding<NavigationPath>,
        recipeId: Recipe.ID?,
        recipeService: RecipeServiceProtocol
    ) {
        _path = path
        self.recipeId = recipeId
        _viewModel = StateObject(
            wrappedValue: RecipeViewModel(
                recipeService: recipeService
            )
        )
    }

    @State private var importURL: URL?
    @State private var pasteError: PasteError?
    @State private var isLoading: Bool = false
    @State private var recipe: Recipe?
    @State private var name: String = ""
    @State private var prepTime: String = ""
    @State private var cookTime: String = ""
    @State private var servings: String = ""
    @State private var ingredients: [String] = [""]
    @State private var instructions: [String] = [""]

    @FocusState private var focusedField: Field?

    private var imageName: String {
        name.isEmpty ? "circle.dotted" : "checkmark"
    }
    
    private func handlePaste() {
        Task {
            if let pasted = UIPasteboard.general.string,
               let url = URL(string: pasted) {
                importURL = nil
                try? await Task.sleep(for: .milliseconds(10))
                importURL = url
            } else {
                pasteError = PasteError(message: "Clipboard doesn't contain a valid URL.")
            }
        }
    }

    var body: some View {
        Screen(
            title: recipeId == nil ? "new recipe" : "edit recipe",
            isLoading: $isLoading
        ) {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                    .onTapGesture {
                        focusedField = nil
                    }
                ScrollView {
                    VStack(spacing: 16) {
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
                        HStack {
                            Poppins("ingredients")
                                .size(14)
                                .weight(.medium)
                                .foregroundColor(Color.pPrimary)
                            Spacer()
                        }
                        ForEach($ingredients.indices, id: \.self) { index in
                            HStack(spacing: 16) {
                                TextInput(
                                    prompt: "1 cup all-purpose flour",
                                    text: $ingredients[index],
                                    focusedField: $focusedField,
                                    equals: .ingredient(index)
                                )
                                .multiline()
                                Button {
                                    ingredients.remove(at: index)
                                } label: {
                                    Image(systemName: "minus")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        Button {
                            ingredients.append("")
                        } label: {
                            Label("add ingredient", systemImage: "plus")
                        }
                        HStack {
                            Poppins("instructions")
                                .size(14)
                                .weight(.medium)
                                .foregroundColor(Color.pPrimary)
                            Spacer()
                        }
                        ForEach($instructions.indices, id: \.self) { index in
                            HStack(spacing: 16) {
                                TextInput(
                                    prompt: "boil for 1 hour",
                                    text: $instructions[index],
                                    focusedField: $focusedField,
                                    equals: .instruction(index)
                                )
                                .multiline()

                                Button {
                                    instructions.remove(at: index)
                                } label: {
                                    Image(systemName: "minus")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        Button {
                            instructions.append("")
                        } label: {
                            Label("add instruction", systemImage: "plus")
                        }
                        Color.clear
                            .frame(height: 150)
                            .listRowInsets(.init())
                            .listRowSeparator(.hidden)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                }
                .background(Color.pBackground)
            }
        }
        .alert(item: $pasteError) { err in
            Alert(
                title: Text("Error"),
                message: Text(err.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .toolbar {
            if recipeId == nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button (action: handlePaste){
                        Label(
                            "Import",
                            systemImage: "square.and.arrow.down"
                        )
                    }
                    .tint(Color("p_primary"))
                    .buttonStyle(.glassProminent)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                } label: {
                    Label(
                        "Save",
                        systemImage: imageName
                    )
                    .contentTransition(.symbolEffect(.replace))
                }
                .disabled(name.isEmpty)
                .tint(Color("p_primary"))
                .buttonStyle(.glassProminent)
            }
        }
        .task {
            if recipeId != nil {
                await viewModel.loadRecipe(id: recipeId!)
            }
        }
        .onChange(of: viewModel.recipe) { _, recipeData in
            onRecipeChange(recipeData: recipeData)
        }
        .onChange(of: importURL) { _, url in
            onImportURLChange(url: url)
        }
    }
}

extension RecipeEditView {
    private func onRecipeChange(recipeData: Recipe?) {
        guard let recipeData else { return }

        // Break into simple assignments
        let newIngredients = recipeData.ingredients?.map { $0.sentence } ?? []
        let newInstructions = recipeData.instructions ?? []

        // Now update state
        recipe = recipeData
        name = recipeData.name
        prepTime = recipeData.prepTime ?? ""
        cookTime = recipeData.cookTime ?? ""
        servings = recipeData.servings ?? ""
        ingredients = newIngredients
        instructions = newInstructions
    }
    
    private func onImportURLChange(url: URL?) {
        Task {
            guard let url else { return }
            isLoading = true
            await viewModel.importRecipe(from: url)
            try? await Task.sleep(for: .milliseconds(1000))
            
            guard let recipeData = viewModel.importedRecipe else { return }
            
            // Break into simple assignments
            let newIngredients = recipeData.ingredients ?? [""]
            let newInstructions = recipeData.instructions ?? [""]

            // Now update state
            name = recipeData.name ?? ""
            prepTime = recipeData.prepTime ?? ""
            cookTime = recipeData.cookTime ?? ""
            servings = recipeData.servings ?? ""
            ingredients = newIngredients
            instructions = newInstructions
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack {
        RecipeNavigator(startingRoute: RecipeRoute.editRecipe(nil))
    }
}

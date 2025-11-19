import SwiftData
import SwiftUI

struct RecipeDetailView: View {
    @StateObject private var viewModel: RecipeViewModel
    @Binding var path: NavigationPath
    private var recipeId: Recipe.ID?
    
    @State private var isLoading: Bool = false
    
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
                        HStack {
                            Image(systemName: "plus.circle")
                            Poppins(ingredient.sentence)
                            Spacer()
                        }
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
                    Button {} label: {
                        Label("Options", systemImage: "ellipsis")
                    }
                    .tint(Color("p_primary"))
                    .buttonStyle(.glassProminent)
                }
            }
        }
        .task {
            if let id = recipeId {
                await viewModel.loadRecipe(id: id)
            }
        }
        .onChange(of: viewModel.isLoading) { _, newValue in
            withAnimation(.easeInOut(duration: 0.4)) {
                isLoading = newValue
            }
        }
    }
}

#Preview {
    NavigationStack {
        RecipeNavigator(startingRoute: RecipeRoute.recipeDetail(13))
    }
}

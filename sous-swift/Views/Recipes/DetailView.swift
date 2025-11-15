import SwiftData
import SwiftUI

struct RecipeDetailView: View {
    let recipeId: Recipe.ID
    @StateObject private var viewModel = RecipeViewModel(
        recipeApi: RecipeService(householdId: 1)
    )
    
    var body: some View {
        let recipe = viewModel.recipe
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 16) {
                        Caprasimo(recipe?.name ?? "")
                            .size(36)
                            .padding(.horizontal, 16)
                        
                        if viewModel.isLoading {
                            Spacer()
                            ProgressView("Loading recipes...")
                                .padding()
                            Spacer()
                        } else if let error = viewModel.errorMessage {
                            Poppins(error)
                                .foregroundColor(.red)
                                .padding()
                            Spacer()
                        } else {
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
                                ForEach(Array((recipe?.instructions ?? []).enumerated()), id: \.offset) {index, instruction in
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
                                                .fixedSize(horizontal: false, vertical: true)
                                            Spacer()
                                        }
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
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
                    Button("edit recipe", systemImage: "pencil") {
                        // Action
                    }
                    .tint(Color("p_primary"))
                    .buttonStyle(.glassProminent)
                }
            }
            .task {
                await viewModel.loadRecipe(id: recipeId)
            }
        }
    }
}

#Preview {
    RecipeDetailView(recipeId: 13)
}

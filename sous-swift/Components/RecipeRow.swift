import SwiftUI

struct RecipeRow: View {
    let recipe: Recipe
    let ratio: Double
    let onTap: () -> Void

    var body: some View {
        ListItem(
            text: recipe.name,
            leftAdornment: {
                statusDot(ratio)
            },
            rightAdornment: {
                ingredientRatioText
            }
        )
        .onTapGesture(perform: onTap)
        .swipeActions {
            Button(role: .destructive) {
                // delete
            } label: {
                Label("delete", systemImage: "trash")
            }
        }
    }

    private var ingredientRatioText: some View {
        let available = Int(ratio * Double(recipe.ingredients?.count ?? 1))
        let total = recipe.ingredients?.count ?? 0
        return ingredientRatio(available, total)
    }
}

private func statusDot(_ ratio: Double) -> some View {
    var color: Color = Color.pIndeterminate
    
    if (ratio > 0.5) {
        color = Color.pWarning
    }
    if (ratio > 0.9) {
        color = Color.pSuccess
    }
    
    return Circle()
        .fill(color)
        .frame(
            width: 16,
            height: 16
        )
}

private func ingredientRatio(_ available: Int, _ total: Int) -> some View {
    return ZStack {
        Poppins(
            "\(available) / \(total)"
        )
        .size(12)
    }
    .padding(.vertical, 4)
    .padding(.horizontal, 8)
    .background(
        Color("p_background")
    )
    .cornerRadius(99)
}

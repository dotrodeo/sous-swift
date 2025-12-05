import SwiftUI

struct PlanDayRow: View {
    let recipe: Recipe
    let ratio: Double
    let onTap: (Recipe) -> Void
    let onUnplan: (_ id: Int) -> Void

    init(
        recipe: Recipe,
        ratio: Double,
        onTap: @escaping (Recipe) -> Void,
        onUnplan: @escaping (_: Int) -> Void
    ) {
        self.recipe = recipe
        self.ratio = ratio
        self.onTap = onTap
        self.onUnplan = onUnplan
    }

    var body: some View {
        ListItem(
            text: recipe.name,
            leftAdornment: {
                statusDot(ratio)
            },
            rightAdornment: {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        )
        .onTapGesture {
            onTap(recipe)
        }
        .swipeActions {
            Button(role: .destructive) {
                onUnplan(recipe.id)
            } label: {
                Label("unplan", systemImage: "xmark")
            }
        }
    }
}

private func statusDot(_ ratio: Double) -> some View {
    var color: Color = Color.pIndeterminate

    if ratio > 0.5 {
        color = Color.pWarning
    }
    if ratio > 0.9 {
        color = Color.pSuccess
    }

    return Circle()
        .fill(color)
        .frame(
            width: 16,
            height: 16
        )
}

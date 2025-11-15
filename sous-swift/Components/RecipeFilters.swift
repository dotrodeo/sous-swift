import SwiftUI

struct RecipeFilters: View {
    var tags: [String] = []
    
    @Binding var selectedTags: Set<String>
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: {}) {
                Image(systemName: "slider.horizontal.3")
                    .padding(.vertical, 8)
                    .padding(.horizontal, 6)
                    .foregroundColor(Color("p_primary"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 99)
                            .stroke(
                                Color("p_primary"),
                            )
                    )
            }
            .padding(1)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        Pill(action: {
                            if (selectedTags.contains(tag)) {
                                selectedTags.remove(tag)
                            } else {
                                selectedTags.insert(tag)
                            }
                        }, isActive: selectedTags.contains(tag)) {
                            Poppins(tag)
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding(.leading, 16)
    }
}

#Preview {
    struct PreviewHost: View {
        @State private var selected: Set<String> = []
        var body: some View {
            VStack(spacing: 16) {
                RecipeFilters(tags: [
                    "vegetarian",
                    "quick",
                    "easy",
                    "breakfast",
                    "lunch",
                    "dinner",
                ], selectedTags: $selected)
            }
            .background(Color("p_background"))
        }
    }
    return PreviewHost()
}

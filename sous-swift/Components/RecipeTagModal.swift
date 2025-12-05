import SwiftUI

struct RecipeTagModal: View {
    enum Field { case search }
    @FocusState private var focusedField: Field?
    @State private var searchText: String = ""

    var tags: [RecipeTag]
    var tagged: [RecipeTagPatch]
    var onAdd: (RecipeTagPatch) -> Void = { _ in }
    var filteredTags: [RecipeTag] {
        tags.filter { tag in
            !tagged.contains(where: { t in t.name == tag.name })
                && (searchText.isEmpty
                    || tag.name.lowercased().contains(searchText.lowercased()))
        }
    }

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(filteredTags) { tag in
                        HStack {
                            HStack(spacing: 4) {
                                Poppins(tag.name)
                                    .foregroundColor(Color.pForeground)
                                Image(systemName: "pointer.arrow.ipad.rays")
                                    .foregroundColor(Color.pPrimary)
                            }
                            .padding(.vertical, 8)
                            .padding(.leading, 12)
                            .padding(.trailing, 8)
                            .background(Color.pForeground.opacity(0.1))
                            .clipShape(Capsule())
                            Spacer()
                        }
                        .onTapGesture {
                            onAdd(RecipeTagPatch(from: tag))
                        }
                    }
                }
            }
            HStack(spacing: 8) {
                TextInput(
                    prompt: "search or add",
                    text: $searchText,
                    focusedField: $focusedField,
                    equals: .search
                )
                ZStack {
                    Circle()
                        .fill(
                            searchText.isEmpty
                                ? Color.pIndeterminate : Color.pPrimary
                        )
                        .frame(width: 48, height: 48)
                    Image(
                        systemName: searchText.isEmpty
                            ? "circle.dotted" : "plus"
                    )
                    .foregroundColor(
                        searchText.isEmpty ? Color.black : Color.white
                    )
                    .font(.system(size: 24))
                    .onTapGesture {
                        onAdd(RecipeTagPatch(name: searchText))
                    }
                }
            }
            .padding(.top, 8)
        }
    }
}

import SwiftData
import SwiftUI

struct EditCategoriesView: View {
    @StateObject private var viewModel: PantryViewModel
    @Binding var path: NavigationPath
    @State var isLoading: Bool = false
    @State private var buttonText: String? = "save"
    @State private var buttonIcon: String? = "circle.dotted"
    @State private var editingItem: ItemCategoryPatch? = nil

    init(
        path: Binding<NavigationPath>,
        pantryService: PantryServiceProtocol,
        sseService: SSEServiceProtocol
    ) {
        _path = path
        _viewModel = StateObject(
            wrappedValue: PantryViewModel(
                pantryService: pantryService,
                sseService: sseService
            )
        )
    }

    private func moveItem(from source: IndexSet, to destination: Int) {
        viewModel.categories.move(fromOffsets: source, toOffset: destination)
    }

    var body: some View {
        Screen(
            title: "categories",
            isLoading: $isLoading,
            buttonIsDisabled: $isLoading,
            buttonAction: {
                await viewModel.updateCategorySortOrder()
            }
        ) {
            List {
                ForEach(viewModel.categories) { category in
                    ListItem(
                        text: "\(category.icon ?? "") \(category.name)",
                        leftAdornment: { DragHandle() },
                        rightAdornment: {}
                    )
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            Task {
                                await viewModel.deleteCategory(category)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button {
                            editingItem = ItemCategoryPatch(from: category)
                        } label: {
                            Label("edit", systemImage: "pencil")
                        }
                    }
                }
                .onMove(perform: moveItem)
            }
            .refreshable {
                isLoading = true
                await viewModel.refresh()
                isLoading = false
            }
            .listStyle(.plain)
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                ToolbarButton(
                    text: "New Category",
                    icon: "plus",
                    action: { editingItem = ItemCategoryPatch() }
                )
            }
        }
        .sheet(item: $editingItem) { item in
            let binding = Binding<ItemCategoryPatch>(
                get: { editingItem ?? item },
                set: { newValue in editingItem = newValue }
            )
            ItemCategoryModal(
                itemCategory: binding,
                onSave: {
                    if let current = editingItem {
                        await viewModel.saveCategory(current)
                    }
                }
            )
            .presentationDetents([.medium])
        }
        .task {
            isLoading = true
            await viewModel.refresh()
            isLoading = false
        }
    }
}

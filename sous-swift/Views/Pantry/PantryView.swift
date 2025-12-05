import SwiftData
import SwiftUI

struct PantryView: View {
    @StateObject private var viewModel: PantryViewModel
    @Binding var path: NavigationPath

    @State private var isLoading: Bool = false
    @State private var editingItem: PantryItemPatch? = nil
    @FocusState private var isSearchFocused: Bool

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

    var body: some View {
        let inPantry: [CategoryWithItems] = viewModel.pantryItemsByCategory()
        Screen(
            title: "pantry",
            isLoading: $isLoading,
            isSearchFocused: $isSearchFocused,
            searchText: $viewModel.searchText
        ) {
            List {
                ForEach(
                    inPantry,
                    id: \.name
                ) { group in
                    Section(
                        header: Poppins("\(group.category?.icon ?? "") \(group.name)")
                            .size(14)
                            .weight(.medium)
                            .asText
                            .textCase(.lowercase)
                    ) {
                        ForEach(group.pantryItems, id: \.id) { pantryItem in
                            PantryItemRow(
                                pantryItem: pantryItem,
                                onTap: {
                                    editingItem = PantryItemPatch(
                                        from: pantryItem
                                    )
                                },
                                onToggleFavorite: { item in
                                    await viewModel.toggleFavorite(item)
                                },
                                onMarkOutOfStock: { item in
                                    await viewModel.markOutOfStock(item)
                                },
                                onDelete: { item in
                                    await viewModel.deleteItem(item)
                                }
                            )
                        }
                    }
                }
            }
            .overlay {
                if inPantry.isEmpty {
                    ContentUnavailableView(
                        "Your pantry is empty",
                        systemImage: "refrigerator",
                        description: Text("Tap the + button to add something")
                    )
                    .offset(x: 0, y: -100)
                }
            }
            .refreshable {
                isLoading = true
                await viewModel.refresh()
                isLoading = false
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80)
            }
        }
        .sheet(item: $editingItem) { item in
            // Create a Binding<PantryItemPatch> backed by editingItem
            let binding = Binding<PantryItemPatch>(
                get: { editingItem ?? item },
                set: { newValue in editingItem = newValue }
            )
            PantryItemModal(
                pantryItem: binding,
                categories: viewModel.categories
            ) {
                if let current = editingItem {
                    await viewModel.saveItem(current)
                    editingItem = nil
                }
            }
            .presentationDetents([.medium])
        }
        .task {
            isLoading = true
            await viewModel.refresh()
            viewModel.listen()
            isLoading = false
        }
        .onChange(of: viewModel.isLoading) { _, newValue in
            withAnimation(.easeInOut(duration: 0.4)) {
                isLoading = newValue
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ToolbarButton(
                    text: "New Pantry Item",
                    icon: "plus",
                    action: { editingItem = PantryItemPatch() }
                )
            }
        }
    }
}

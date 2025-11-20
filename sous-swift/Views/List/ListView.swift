import SwiftData
import SwiftUI

struct ListView: View {
    @State private var showAllItems: Bool = false

    @StateObject private var viewModel: ListViewModel
    @Binding var path: NavigationPath

    @State private var isLoading: Bool = false
    @FocusState private var isSearchFocused: Bool
    @State private var editingItem: PantryItemPatch? = nil

    init(
        path: Binding<NavigationPath>,
        pantryService: PantryServiceProtocol
    ) {
        _path = path
        _viewModel = StateObject(
            wrappedValue: ListViewModel(
                pantryService: pantryService
            )
        )
    }

    var body: some View {
        Screen(
            title: "shopping list",
            isLoading: $isLoading,
            isSearchFocused: $isSearchFocused,
            searchText: .some($viewModel.searchText)
        ) {
            List {
                ForEach(
                    viewModel.forListView(showAll: showAllItems),
                    id: \.category
                ) { group in
                    Section(
                        header: Poppins(group.category)
                            .asText
                            .textCase(.lowercase)
                    ) {
                        ForEach(group.items, id: \.id) { item in
                            ShoppingListRow(
                                pantryItem: item,
                                isShowingAllItems: showAllItems,
                                onPurchase: {
                                    Task { await viewModel.purchaseItem(item) }
                                },
                                onAddToList: {
                                    Task { await viewModel.addItemToList(item) }
                                },
                                onDelete: { id in
                                    Task { await viewModel.deleteItem(item) }
                                },
                                onEdit: {
                                    editingItem = PantryItemPatch(from: item)
                                }
                            )
                        }
                    }
                    .headerProminence(.increased)
                    .listRowBackground(Color.pSurface)
                }
                Color.clear
                    .frame(height: 150)
                    .listRowInsets(.init())
                    .listRowSeparator(.hidden)
            }
            .refreshable {
                isLoading = true
                await viewModel.refresh()
                isLoading = false
            }
            .listStyle(.plain)
        }
        .sheet(item: $editingItem) { item in
            let binding = Binding<PantryItemPatch>(
                get: { editingItem ?? item },
                set: { newValue in editingItem = newValue }
            )
            PantryItemModal(
                pantryItem: binding,
                categories: viewModel.categories,
                onSave: {
                    if let current = editingItem {
                        await viewModel.saveItem(current)
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
        .onChange(of: viewModel.isLoading) { _, newValue in
            withAnimation(.easeInOut(duration: 0.4)) {
                isLoading = newValue
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ToolbarButton(
                    text: "Add From Items",
                    icon: showAllItems ? "checkmark" : "list.bullet",
                    action: { showAllItems = !showAllItems }
                )
            }
            ToolbarItem(placement: .topBarTrailing) {
                ToolbarButton(
                    text: "New List Item",
                    icon: "plus",
                    action: { editingItem = PantryItemPatch() }
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        ListNavigator(startingRoute: .list)
    }
}

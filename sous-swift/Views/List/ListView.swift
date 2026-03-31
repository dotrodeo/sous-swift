import SwiftData
import SwiftUI

struct ListView: View {
    @State private var showAllItems: Bool = false

    @StateObject private var viewModel: ListViewModel
    @Binding var path: NavigationPath

    @FocusState private var isSearchFocused: Bool
    @State private var editingItem: PantryItemPatch? = nil

    init(
        path: Binding<NavigationPath>,
        pantryService: PantryServiceProtocol,
        sseService: SSEServiceProtocol
    ) {
        _path = path
        _viewModel = StateObject(
            wrappedValue: ListViewModel(
                pantryService: pantryService,
                sseService: sseService
            )
        )
    }

    var body: some View {
        let inList: [CategoryWithItems] = viewModel.forListView(showAll: showAllItems)
        Screen(
            title: "shopping list",
            isLoading: $viewModel.isLoading,
            isSearchFocused: $isSearchFocused,
            searchText: .some($viewModel.searchText)
        ) {
            List {
                ForEach(
                    inList,
                    id: \.name
                ) { group in
                    Section(
                        header: Poppins("\(group.category?.icon ?? "") \(group.name)")
                            .size(14)
                            .weight(.medium)
                            .asText
                            .textCase(.lowercase)
                    ) {
                        ForEach(group.pantryItems, id: \.id) { item in
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
                }
            }
            .overlay {
                if inList.isEmpty {
                    ContentUnavailableView(
                        "Your list is empty",
                        systemImage: "cart",
                        description: Text("Tap the + button to add something")
                    )
                    .offset(x: 0, y: -100)
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80)
            }
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
                        editingItem = nil
                    }
                }
            )
            .presentationDetents([.medium])
        }
        .task {
            await viewModel.refresh()
            viewModel.listen()
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { present in if !present { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
        .onChange(of: viewModel.isLoading) { _, _ in
            withAnimation(.easeInOut(duration: 0.4)) {
                // UI reacts directly to viewModel.isLoading via Screen binding
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

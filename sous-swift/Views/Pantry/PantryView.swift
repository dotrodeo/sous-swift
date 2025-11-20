import SwiftData
import SwiftUI

struct PantryView: View {
    @StateObject private var viewModel: PantryViewModel
    @Binding var path: NavigationPath

    @State private var isLoading: Bool = false
    @State private var showItemSheet: Bool = false
    @State private var editingItem: PantryItemPatch? = nil
    @FocusState private var isSearchFocused: Bool

    init(
        path: Binding<NavigationPath>,
        pantryService: PantryServiceProtocol
    ) {
        _path = path
        _viewModel = StateObject(
            wrappedValue: PantryViewModel(
                pantryService: pantryService
            )
        )
    }

    var body: some View {
        Screen(
            title: "pantry",
            isLoading: $isLoading,
            isSearchFocused: $isSearchFocused,
            searchText: $viewModel.searchText
        ) {
            List {
                Section {
                    ForEach(viewModel.inPantry()) {
                        pantryItem in
                        PantryItemRow(
                            pantryItem: pantryItem,
                            onTap: {
                                editingItem = PantryItemPatch(from: pantryItem)
                            },
                            onToggleFavorite: { item in
                                await viewModel.toggleFavorite(item)
                            },
                            onMarkOutOfStock: { item in
                                await viewModel.markOutOfStock(item)
                            },
                            onDelete: { item in await viewModel.deleteItem(item)
                            }
                        )
                    }
                }
                .listRowBackground(Color.pSurface)
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
            // Create a Binding<PantryItemPatch> backed by editingItem
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
                    text: "New Pantry Item",
                    icon: "plus",
                    action: { editingItem = PantryItemPatch() }
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        PantryNavigator(startingRoute: .pantry)
    }
}

import SwiftData
import SwiftUI

struct PantryView: View {
    @StateObject private var viewModel: PantryViewModel
    @Binding var path: NavigationPath

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
            isLoading: $viewModel.isLoading,
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
                await viewModel.refresh()
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
        .onChange(of: viewModel.isLoading) { _, newValue in
            withAnimation(.easeInOut(duration: 0.4)) {
                // isLoading is now handled by the Screen view
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
        .onAppear {
            Task {
                await viewModel.refresh()
            }
        }
    }
}

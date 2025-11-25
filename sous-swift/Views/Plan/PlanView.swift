import Clerk
import SwiftData
import SwiftUI

struct PlanView: View {
    @Binding var path: NavigationPath
    @State var isLoading: Bool = false

    @State private var items = ["Lemon Garlic Chicken", "Veggie Stir-Fry", "Creamy Tomato Pasta", "Chili Lime Shrimp"]
    @State private var thursday = ["Smoked Thanksgiving Turkey", "Creamy Mashed Potatoes", "Sage Sourdough Stuffing", "Maple Glazed Carrots"]

    private func moveItem(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }

    var body: some View {
        Screen(
            title: "plan",
            isLoading: $isLoading
        ) {
            List {
                Section(
                    header: Poppins("upcoming")
                        .size(14)
                        .weight(.medium)
                        .asText
                        .textCase(.lowercase),
                    footer: Button(action: {}) { Poppins("+ add recipe") }
                ) {
                    ForEach(items, id: \.self) { item in
                        ListItem(
                            text: item,
                            leftAdornment: {
                                DragHandle()
                            },
                            rightAdornment: {
                                HStack {
                                    ZStack {
                                        Poppins(
                                            "3 / 6"
                                        )
                                        .size(12)
                                    }
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(
                                        Color.pBackground
                                    )
                                    .cornerRadius(99)
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                            }
                        )
                    }
                    .onMove(perform: moveItem)
                }
                Section(
                    header: HStack {
                        Poppins("thursday")
                            .size(14)
                            .weight(.medium)
                            .asText
                            .textCase(.lowercase)
                        ZStack {
                            Poppins(
                                "in 2 days"
                            )
                            .size(12)
                            .foregroundColor(Color.pPink)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            Color.pBackground
                        )
                        .cornerRadius(99)
                    },
                    footer: Button(action: {}) { Poppins("+ add recipe") }
                ) {
                    ForEach(thursday, id: \.self) { item in
                        ListItem(
                            text: item,
                            leftAdornment: {
                                DragHandle()
                            },
                            rightAdornment: {
                                HStack {
                                    ZStack {
                                        Poppins(
                                            "3 / 6"
                                        )
                                        .size(12)
                                    }
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(
                                        Color.pBackground
                                    )
                                    .cornerRadius(99)
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                            }
                        )
                    }
                    .onMove(perform: moveItem)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ToolbarButton(
                    text: "New Plan Item",
                    icon: "cart",
                    action: {}
                )
            }
            ToolbarItem(placement: .topBarTrailing) {
                ToolbarButton(
                    text: "New Plan Item",
                    icon: "calendar",
                    action: {}
                )
            }
        }
        .task {

        }
    }
}

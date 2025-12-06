import Clerk
import SwiftData
import SwiftUI

struct PlanView: View {
    @StateObject private var planViewModel: PlanViewModel
    @StateObject private var recipesViewModel: RecipesViewModel
    @State var isLoading: Bool = false
    @State var editingPlanDay: PlanDay? = nil
    @State private var newPlanDay: Date = Date()
    @State private var isShowingDatePicker = false
    private var onTapRecipe: (Recipe) -> Void

    init(
        planService: PlanServiceProtocol,
        recipeService: RecipeServiceProtocol,
        pantryService: PantryServiceProtocol,
        onTapRecipe: @escaping (Recipe) -> Void
    ) {
        _planViewModel = StateObject(
            wrappedValue: PlanViewModel(
                planService: planService,
                recipeService: recipeService
            )
        )
        _recipesViewModel = StateObject(
            wrappedValue: RecipesViewModel(
                recipeService: recipeService,
                pantryService: pantryService
            )
        )
        self.onTapRecipe = onTapRecipe
    }

    private func sectionHeader(for day: PlanDay) -> some View {
        var dateText = "any time"
        var pillText: String? = nil

        if let dateString = day.date,
            let date = DateHelper.fromString(dateString)
        {
            dateText = DateHelper.upcomingFormat(date)
            pillText =
                DateHelper.isWithinThreeDaysOrPast(date)
                ? DateHelper.relative(date) : nil
        }

        return HStack(spacing: 16) {
            Poppins(dateText)
                .size(14)
                .weight(.medium)
                .asText
                .textCase(.lowercase)
            if let pillText {
                Poppins(pillText)
                    .size(14)
                    .foregroundColor(Color.pPink)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 12)
                    .background(Color.pForeground.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
    }

    var body: some View {
        Screen(
            title: "plan",
            isLoading: $isLoading
        ) {
            List {
                ForEach(planViewModel.getFuturePlanDays()) { day in
                    Section(
                        header: sectionHeader(for: day),
                        footer: Poppins("+ add a recipe")
                            .weight(.medium)
                            .foregroundColor(Color.pPrimary)
                            .onTapGesture {
                                editingPlanDay = day
                            }
                    ) {
                        if day.recipes.isEmpty {
                            HStack {
                                Poppins("nothing planned here")
                                    .foregroundColor(
                                        Color.pForeground.opacity(0.5)
                                    )
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            ForEach(planViewModel.sortRecipes(day.recipes)) { recipe in
                                PlanDayRow(
                                    recipe: recipe,
                                    ratio: RecipeHelper.ratio(
                                        for: recipe,
                                        pantryItems: recipesViewModel.pantry?
                                            .pantryItems ?? []
                                    ),
                                    onTap: { r in
                                        onTapRecipe(r)
                                    },
                                    onUnplan: { id in
                                        Task {
                                            await planViewModel.unplanRecipe(
                                                planDayId: day.id,
                                                recipeId: id
                                            )
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
            }
        }
        .sheet(item: $editingPlanDay) { day in
            RecipeSelector(isSaving: $isLoading, recipes: planViewModel.recipes)
            {
                selected in
                await planViewModel.planRecipes(
                    planDayId: day.id,
                    recipeIds: Array(selected)
                )
                editingPlanDay = nil
            }
        }
        .sheet(isPresented: $isShowingDatePicker) {
            VStack {
                HStack {
                    Poppins("select a date")
                        .size(24)
                        .weight(.medium)
                    Spacer()
                    SaveButton(isSaving: $isLoading) {
                        await planViewModel.addPlanDay(
                            date: DateHelper.toString(newPlanDay)
                        )
                        isShowingDatePicker = false
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 32)
                DatePicker(
                    "",
                    selection: $newPlanDay,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .padding()

                Spacer()
            }
            .presentationDetents([.height(500)])
        }
        .toolbar {
            //            ToolbarItem(placement: .topBarTrailing) {
            //                ToolbarButton(
            //                    text: "New Plan Item",
            //                    icon: "cart",
            //                    action: {}
            //                )
            //            }
            ToolbarItem(placement: .topBarTrailing) {
                ToolbarButton(
                    text: "Add Plan Day",
                    icon: "calendar",
                    action: {
                        isShowingDatePicker = true
                    }
                )
            }
        }
        .task {
            await planViewModel.refresh()
            await recipesViewModel.refresh()
        }
    }
}

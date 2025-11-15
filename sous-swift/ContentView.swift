import SwiftUI
import SwiftData

struct ContentView: View {

    var body: some View {
        TabView {
            Tab("Recipes", systemImage: "book") {
                RecipeNavigator()
            }
            Tab("Pantry", systemImage: "refrigerator") {
                RecipeNavigator()
            }
            Tab("List", systemImage: "cart") {
                RecipeNavigator()
            }
            
            Tab("Profile", systemImage: "smiley") {
                RecipeNavigator()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}

#Preview {
    ContentView()
}

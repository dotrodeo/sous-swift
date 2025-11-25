import SwiftData
import SwiftUI

struct BoilerplateView: View {
    @Binding var path: NavigationPath
    @State var isLoading: Bool = false

    var body: some View {
        Screen(
            title: "profile",
            isLoading: $isLoading
        ) {

        }
        .toolbar {

        }
        .task {

        }
    }
}

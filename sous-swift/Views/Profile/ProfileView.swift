import Clerk
import SwiftData
import SwiftUI

struct ProfileView: View {
    @Binding var path: NavigationPath
    @State var isLoading: Bool = false

    var body: some View {
        Screen(
            title: "settings",
            isLoading: $isLoading
        ) {
            List {
                Section(header: Poppins("household settings").asText) {
                    ListItem(
                        text: "categories",
                        leftAdornment: {
                            Image(systemName: "list.dash")
                        },
                        rightAdornment: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    )
                    .onTapGesture {
                        path.append(ProfileRoute.editCategories)
                    }

                    ListItem(
                        text: "share household",
                        leftAdornment: {
                            Image(systemName: "qrcode")
                        },
                        rightAdornment: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    )
                    .onTapGesture {
                        path.append(ProfileRoute.shareHousehold)
                    }

                    ListItem(
                        text: "join household",
                        leftAdornment: {
                            Image(systemName: "qrcode.viewfinder")
                        },
                        rightAdornment: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    )
                    .onTapGesture {
                        path.append(ProfileRoute.joinHousehold)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                UserButton()
                    .frame(width: 32, height: 32)
                    .contentShape(Circle())
            }
        }
        .task {

        }
    }
}

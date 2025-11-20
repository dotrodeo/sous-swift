import SwiftUI

struct ToolbarButton: View {
    let text: String
    let icon: String
    let action: () -> Void

    var body: some View {
        if #available(iOS 26.0, *) {
            Button (action: action){
                Label(
                    text,
                    systemImage: icon
                )
            }
            .tint(Color("p_primary"))
            .buttonStyle(.glassProminent)
        } else {
            Button (action: action){
                Label(
                    text,
                    systemImage: icon
                )
            }
            .tint(Color("p_primary"))
        }
    }
}

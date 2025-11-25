import SwiftUI

struct DragHandle: View {
    
    private func LittleCircle() -> some View {
        Circle()
            .fill(Color.pForeground.opacity(0.5))
            .frame(width: 3, height: 3)
    }
    
    var body: some View {
        HStack(spacing: 3) {
            VStack(spacing: 3) {
                LittleCircle()
                LittleCircle()
                LittleCircle()
            }
            VStack(spacing: 3) {
                LittleCircle()
                LittleCircle()
                LittleCircle()
            }
        }
    }
}

#Preview {
    DragHandle()
}

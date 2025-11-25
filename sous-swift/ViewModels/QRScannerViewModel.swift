import Combine
import SwiftUI

@MainActor
class QRScannerViewModel: ObservableObject {
    @Published var scannedValue: String?
    @Published var isScanning = true

    func restart() {
        scannedValue = nil
        isScanning = true
    }
}

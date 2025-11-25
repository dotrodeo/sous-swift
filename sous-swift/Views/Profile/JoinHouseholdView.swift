import SwiftData
import SwiftUI

struct JoinHouseholdView: View {
    @StateObject private var vm = QRScannerViewModel()
    @StateObject private var viewModel: HouseholdViewModel
    @Binding var path: NavigationPath
    @State var isLoading: Bool = false

    init(
        path: Binding<NavigationPath>,
        household: Household,
        householdService: HouseholdServiceProtocol
    ) {
        self._path = path
        self._viewModel = StateObject(
            wrappedValue: HouseholdViewModel(
                household: household,
                householdService: householdService
            )
        )
    }

    var body: some View {
        ZStack {
            QRScannerView(
                scannedCode: $vm.scannedValue,
                isRunning: vm.isScanning
            )
            .ignoresSafeArea()

            if let value = vm.scannedValue {
                VStack {
                    Text("Scanned:")
                        .font(.headline)
                        .padding(.top, 60)

                    Text(value)
                        .font(.title2)
                        .bold()
                        .padding()

                    Button("Join Household") {
                        Task {
                            await viewModel.joinHousehold(joinToken: value)
                            vm.scannedValue = nil
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding()
            }
        }
        .toolbar {

        }
        .task {

        }
    }
}

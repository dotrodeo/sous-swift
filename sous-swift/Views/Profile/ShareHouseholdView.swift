import CoreImage.CIFilterBuiltins
import SwiftData
import SwiftUI

struct ShareHouseholdView: View {
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

    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()

    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(
                outputImage,
                from: outputImage.extent
            ) {
                return UIImage(cgImage: cgImage)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }

    var body: some View {
        Screen(
            title: "share household",
            isLoading: $isLoading
        ) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.pBackground)
                    .containerRelativeFrame(.horizontal) { length, axis in
                        length * 0.9
                    }
                Image(
                    uiImage: generateQRCode(
                        from: viewModel.household?.joinToken ?? ""
                    )
                )
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .containerRelativeFrame(.horizontal) { length, axis in
                    length * 0.55
                }
            }
            Spacer()
        }
        .toolbar {

        }
        .task {

        }
    }
}

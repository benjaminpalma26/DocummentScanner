import SwiftUI

struct PreviewView: View {
    let image: UIImage
    @EnvironmentObject var viewModel: ScannerViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .padding()

            HStack(spacing: 40) {
                Button(action: viewModel.rejectPage) {
                    Label("Rechazar", systemImage: "xmark.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(Color.red)
                        .clipShape(Capsule())
                }

                Button(action: { viewModel.acceptPage(image) }) {
                    Label("Aceptar", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(Color.green)
                        .clipShape(Capsule())
                }
            }
            .padding(.bottom, 48)
        }
    }
}

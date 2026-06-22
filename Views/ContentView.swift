import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ScannerViewModel

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .camera:
                cameraScreen

            case .preview(let image):
                PreviewView(image: image)

            case .exporting:
                ProgressView("Generando PDF…")
                    .progressViewStyle(.circular)
            }
        }
        .sheet(item: $viewModel.exportURL) { url in
            ShareSheet(url: url)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var cameraScreen: some View {
        ZStack(alignment: .bottom) {
            CameraView()
                .ignoresSafeArea()

            VStack(spacing: 16) {
                if viewModel.document.pageCount > 0 {
                    Text("\(viewModel.document.pageCount) página(s) escaneada(s)")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                }

                HStack(spacing: 32) {
                    // Botón disparador
                    CaptureButton()

                    // Botón generar PDF (solo si hay páginas)
                    if viewModel.document.pageCount > 0 {
                        Button(action: viewModel.generatePDF) {
                            Label("Generar PDF", systemImage: "doc.fill")
                                .font(.subheadline.bold())
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
}

private struct CaptureButton: View {
    @EnvironmentObject var viewModel: ScannerViewModel

    var body: some View {
        Button(action: {
            NotificationCenter.default.post(name: .capturePhoto, object: nil)
        }) {
            Circle()
                .fill(.white)
                .frame(width: 72, height: 72)
                .overlay(Circle().stroke(.white.opacity(0.4), lineWidth: 4).frame(width: 84, height: 84))
        }
    }
}

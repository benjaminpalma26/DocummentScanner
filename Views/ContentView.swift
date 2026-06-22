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

            case .pdfPreview(let url):
                PDFPreviewView(url: url)

            case .exporting:
                ZStack {
                    Color.black.ignoresSafeArea()
                    ProgressView("Generando PDF…")
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .foregroundStyle(.white)
                }
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
        .confirmationDialog(
            "¿Descartar todas las páginas escaneadas?",
            isPresented: $viewModel.showClearConfirm,
            titleVisibility: .visible
        ) {
            Button("Descartar todo", role: .destructive) {
                viewModel.clearAllPages()
            }
            Button("Cancelar", role: .cancel) {}
        }
    }

    private var cameraScreen: some View {
        ZStack(alignment: .bottom) {
            CameraView()
                .ignoresSafeArea()

            // Botón descartar (arriba izquierda)
            if viewModel.document.pageCount > 0 {
                VStack {
                    HStack {
                        Button(action: { viewModel.showClearConfirm = true }) {
                            HStack(spacing: 6) {
                                Image(systemName: "trash")
                                Text("Descartar")
                            }
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.red.opacity(0.8))
                            .clipShape(Capsule())
                        }
                        Spacer()
                    }
                    .padding(.top, 56)
                    .padding(.horizontal, 20)
                    Spacer()
                }
            }

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
                    CaptureButton()

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

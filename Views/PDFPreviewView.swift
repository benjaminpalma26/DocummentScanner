import SwiftUI
import PDFKit

struct PDFPreviewView: View {
    let url: URL
    @EnvironmentObject var viewModel: ScannerViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: viewModel.closePDFPreview) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Volver")
                        }
                        .foregroundStyle(.white)
                        .font(.subheadline.bold())
                    }
                    Spacer()
                    Text("Vista previa")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                    // Espacio para centrar el título
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Volver")
                    }
                    .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)
                .padding(.bottom, 12)

                // PDF Viewer
                PDFKitView(url: url)
                    .ignoresSafeArea(edges: .bottom)
            }

            // Botones de acción
            HStack(spacing: 20) {
                Button(action: viewModel.closePDFPreview) {
                    Label("Nueva sesión", systemImage: "camera")
                        .font(.subheadline.bold())
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(Color.gray.opacity(0.8))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }

                Button(action: { viewModel.sharePDF(url: url) }) {
                    Label("Guardar / Compartir", systemImage: "square.and.arrow.up")
                        .font(.subheadline.bold())
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            .padding(.bottom, 40)
            .padding(.horizontal, 16)
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = .darkGray
        pdfView.document = PDFDocument(url: url)
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}

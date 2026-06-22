import UIKit
import Combine

enum ScannerState {
    case camera
    case preview(UIImage)
    case pdfPreview(URL)
    case exporting
}

@MainActor
final class ScannerViewModel: ObservableObject {
    @Published var document = ScanDocument()
    @Published var state: ScannerState = .camera
    @Published var exportURL: URL?
    @Published var errorMessage: String?
    @Published var showClearConfirm = false

    private let imageProcessor = ImageProcessingService()
    private let pdfExporter = PDFExportService()

    func didCapture(image: UIImage) {
        let processed = imageProcessor.applyBinarization(to: image)
        state = .preview(processed)
    }

    func acceptPage(_ image: UIImage) {
        document.addPage(image)
        state = .camera
    }

    func rejectPage() {
        state = .camera
    }

    func clearAllPages() {
        document.clear()
        state = .camera
    }

    func generatePDF() {
        guard !document.pages.isEmpty else { return }
        state = .exporting
        Task {
            do {
                let url = try pdfExporter.export(pages: document.pages)
                state = .pdfPreview(url)
            } catch {
                errorMessage = error.localizedDescription
                state = .camera
            }
        }
    }

    func sharePDF(url: URL) {
        exportURL = url
    }

    func closePDFPreview() {
        state = .camera
    }
}

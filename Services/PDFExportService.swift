import PDFKit
import UIKit

final class PDFExportService {
    func export(pages: [UIImage]) throws -> URL {
        let pdfDocument = PDFDocument()

        for (index, image) in pages.enumerated() {
            guard let pdfPage = PDFPage(image: image) else { continue }
            pdfDocument.insert(pdfPage, at: index)
        }

        let fileName = "documento_\(Int(Date().timeIntervalSince1970)).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        guard pdfDocument.write(to: url) else {
            throw PDFExportError.writeFailed
        }

        return url
    }
}

enum PDFExportError: LocalizedError {
    case writeFailed

    var errorDescription: String? {
        "No se pudo generar el PDF. Inténtalo de nuevo."
    }
}

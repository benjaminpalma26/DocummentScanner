import UIKit

struct ScanDocument {
    var pages: [UIImage] = []

    var pageCount: Int { pages.count }

    mutating func addPage(_ image: UIImage) {
        pages.append(image)
    }

    mutating func removeLast() {
        guard !pages.isEmpty else { return }
        pages.removeLast()
    }

    mutating func clear() {
        pages.removeAll()
    }
}

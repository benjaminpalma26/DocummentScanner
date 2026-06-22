import SwiftUI

@main
struct DocumentScannerApp: App {
    @StateObject private var viewModel = ScannerViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}

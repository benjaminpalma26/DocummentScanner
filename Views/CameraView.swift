import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @EnvironmentObject var viewModel: ScannerViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    func makeUIViewController(context: Context) -> CameraViewController {
        let vc = CameraViewController()
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}

    final class Coordinator: CameraServiceDelegate {
        private let viewModel: ScannerViewModel

        init(viewModel: ScannerViewModel) {
            self.viewModel = viewModel
        }

        func cameraService(_ service: CameraService, didCapture image: UIImage) {
            Task { @MainActor in
                viewModel.didCapture(image: image)
            }
        }

        func cameraService(_ service: CameraService, didFail error: Error) {
            Task { @MainActor in
                viewModel.errorMessage = error.localizedDescription
            }
        }
    }
}

final class CameraViewController: UIViewController {
    weak var delegate: CameraServiceDelegate?

    private let cameraService = CameraService()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupPreview()
        observeCaptureNotification()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraService.stop()
    }

    private func setupCamera() {
        cameraService.delegate = delegate
        Task {
            let granted = await PermissionsManager.requestCameraAccess()
            if granted {
                cameraService.configure()
            }
        }
    }

    private func setupPreview() {
        let layer = AVCaptureVideoPreviewLayer(session: cameraService.session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = view.bounds
        view.layer.insertSublayer(layer, at: 0)
        previewLayer = layer
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    private func observeCaptureNotification() {
        captureObserver = NotificationCenter.default.addObserver(
            forName: .capturePhoto,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.cameraService.capturePhoto()
        }
    }

    deinit {
        if let captureObserver {
            NotificationCenter.default.removeObserver(captureObserver)
        }
    }
}

extension Notification.Name {
    static let capturePhoto = Notification.Name("capturePhoto")
}

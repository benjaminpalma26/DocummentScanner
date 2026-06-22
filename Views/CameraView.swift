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
        // El simulador no tiene cámara trasera real
        guard AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) != nil else {
            showNoCameraMessage()
            return
        }
        cameraService.delegate = delegate
        Task {
            let granted = await PermissionsManager.requestCameraAccess()
            if granted {
                cameraService.configure()
            } else {
                showPermissionDeniedMessage()
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

    private func showNoCameraMessage() {
        view.backgroundColor = .black
        let label = UILabel()
        label.text = "Cámara no disponible en el simulador.\nUsa un dispositivo físico."
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    private func showPermissionDeniedMessage() {
        view.backgroundColor = .black
        let label = UILabel()
        label.text = "Acceso a la cámara denegado.\nHabilítalo en Ajustes > Privacidad > Cámara."
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
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

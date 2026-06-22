import AVFoundation

enum CameraPermissionStatus {
    case granted, denied, restricted, undetermined
}

final class PermissionsManager {
    static func cameraStatus() -> CameraPermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:    return .granted
        case .denied:        return .denied
        case .restricted:    return .restricted
        case .notDetermined: return .undetermined
        @unknown default:    return .undetermined
        }
    }

    static func requestCameraAccess() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }
}

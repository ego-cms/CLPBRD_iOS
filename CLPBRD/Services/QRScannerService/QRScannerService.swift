import UIKit


enum QRScannerAuthorizationStatus {
    case authorized
    case denied
    case notDetermined
}

enum QRScannerError: Error {
    case notAuthorized
}

protocol QRScannerService: class {
    var authorizationStatus: QRScannerAuthorizationStatus { get }
    var previewLayer: CALayer? { get }
    
    var onQRCodeDetected: (String) -> Void { get set }
    var onSetupCompleted: (Error?) -> Void { get set }
    
    func setup()
    func startScanning()
    func stopScanning()
}




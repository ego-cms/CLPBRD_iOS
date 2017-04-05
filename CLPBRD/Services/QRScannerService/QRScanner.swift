import UIKit
import AVFoundation


final class QRScanner: NSObject, QRScannerService {
    var authorizationStatus: QRScannerAuthorizationStatus {
        let cameraMediaType = AVMediaTypeVideo
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: cameraMediaType)
        let statusMap: [AVAuthorizationStatus: QRScannerAuthorizationStatus] = [
            .denied: .denied,
            .authorized: .authorized,
            .restricted: .denied,
            .notDetermined: .notDetermined
        ]
        return statusMap[cameraAuthorizationStatus]!
    }
    
    private(set) var previewLayer: CALayer?
    
    var onQRCodeDetected: (String) -> Void = { _ in }
    var onSetupCompleted: (Error?) -> Void = { _ in }
    
    private var captureSession = AVCaptureSession()
    
    func setup() {
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureSession.addInput(input)
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.previewLayer = previewLayer
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { granted in
                let error = granted ? nil : QRScannerError.notAuthorized
                self.onSetupCompleted(error)
            }
        } catch {
            onSetupCompleted(error)
        }
    }
    
    func startScanning() {
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        guard authorizationStatus == .authorized else {
            print("Not authorized to scan QR code")
            return
        }
        deviceRotated()
        captureSession.startRunning()
    }
    
    func stopScanning() {
        NotificationCenter.default.removeObserver(self)
        captureSession.stopRunning()
    }
    
    func deviceRotated() {
        guard let previewLayer = self.previewLayer as? AVCaptureVideoPreviewLayer else {
            return
        }
        previewLayer.connection.videoOrientation = deviceOrientationToVideoOrientation(deviceOrientation: UIDevice.current.orientation)
    }
}


extension QRScanner: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        guard
            let qrCode = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            qrCode.type == AVMetadataObjectTypeQRCode,
            let string = qrCode.stringValue
        else {
            return
        }
        onQRCodeDetected(string)
    }    
}

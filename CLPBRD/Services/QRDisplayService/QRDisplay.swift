import UIKit
import CoreImage
import Result


class QRDisplay: QRDisplayService {
    var text: String = "" {
        didSet {
            prepareQRCode()
        }
    }
    
    var side: CGFloat = 240.0
    var onQRCodeReady: (String, Result<UIImage, QRDisplayError>) -> Void = { _ in }
    
    private func prepareQRCode() {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let data = self.text.data(using: .utf8) else {
                DispatchQueue.main.async {
                    self.onQRCodeReady(self.text, .failure(QRDisplayError.textError))
                }
                return
            }
            let filter = CIFilter(name: "CIQRCodeGenerator")
            filter?.setValue(data, forKey: "inputMessage")
            filter?.setValue("L", forKey: "inputCorrectionLevel")
            guard let image = filter?.outputImage else {
                DispatchQueue.main.async {
                    self.onQRCodeReady(self.text, .failure(QRDisplayError.qrGenerationError))
                }
                return
            }
            let uiimage = UIImage(ciImage: self.resizedImage(input: image))
            DispatchQueue.main.async {
                self.onQRCodeReady(self.text, .success(uiimage))
            }
        }
    }
    
    private func resizedImage(input: CIImage) -> CIImage {
        let inputSize = input.extent.size
        let outputSize = CGSize(width: side, height: side)
        let scaleTransform = CGAffineTransform(scaleX: outputSize.width / inputSize.width, y: outputSize.height / inputSize.height)
        let result = input.applying(scaleTransform)
        return result
    }
}

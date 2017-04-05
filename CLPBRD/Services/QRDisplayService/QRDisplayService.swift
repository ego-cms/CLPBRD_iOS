import UIKit
import Result


enum QRDisplayError: Error {
    case textError
//    case textTooBig
    case qrGenerationError
}


protocol QRDisplayService: class {
    var side: CGFloat { get set }
    var text: String { get set }
    var onQRCodeReady: (String, Result<UIImage, QRDisplayError>) -> Void { get set }
}

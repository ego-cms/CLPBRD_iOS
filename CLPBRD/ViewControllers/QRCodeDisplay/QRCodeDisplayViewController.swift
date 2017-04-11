import UIKit
import Result


protocol QRCodeDisplayViewControllerDelegate: class {
    func qrCodeDisplayViewControllerCancel(_ viewController: QRCodeDisplayViewController)
}


class QRCodeDisplayViewController: UIViewController {
    var qrDisplayService: QRDisplayService
    @IBOutlet weak var qrImageView: UIImageView!
    weak var delegate: QRCodeDisplayViewControllerDelegate?
    
    init(qrDisplayService: QRDisplayService) {
        self.qrDisplayService = qrDisplayService
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
        self.modalTransitionStyle = .crossDissolve
    }
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        qrDisplayService.onQRCodeReady = { [unowned self] in
            self.qrCodeCreationFinished(result: $1)
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))
        title = "QR Code"
        blurView.effect = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        blurView.effect = nil
        view.backgroundColor = UIColor.white
        if let lastResult = qrDisplayService.lastResult {
            qrCodeCreationFinished(result: lastResult)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5) {
            self.blurView.effect = UIBlurEffect(style: .extraLight)
            self.view.backgroundColor = .clear
        }
    }
    
    func qrCodeCreationFinished(result: Result<UIImage, QRDisplayError>) {
        switch result {
        case .success(let qrCodeImage):
            qrImageView.image = qrCodeImage
        case .failure(let error):
            print("Error making QR code \(error)")
        }
    }
    
    func cancelPressed() {
        delegate?.qrCodeDisplayViewControllerCancel(self)
    }
}

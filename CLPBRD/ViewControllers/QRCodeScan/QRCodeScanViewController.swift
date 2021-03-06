import UIKit


protocol QRCodeScanViewControllerDelegate: class {
    func qrCodeScanViewControllerCancel(_ viewController: QRCodeScanViewController)
    func qrCodeScanViewController(_ viewController: QRCodeScanViewController, detectedText: String)
}


class QRCodeScanViewController: UIViewController {
    var qrScannerService: QRScannerService
    weak var delegate: QRCodeScanViewControllerDelegate?
    
    private var lastText: String?
    @IBOutlet weak var failureDescriptionLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var warningView: UIView!
    
    init(qrScannerService: QRScannerService) {
        self.qrScannerService = qrScannerService
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var previewContainer: UIView!
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        guard let settingsURL = URL(string: UIApplicationOpenSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))
        title = L10n.scanQRCodeTitle.string
        warningLabel.text = L10n.badQRCodeWarning.string
        failureDescriptionLabel.text = L10n.cameraPermissionFailureDescription.string
        settingsButton.setTitle(L10n.settingsButtonTitle.string, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        qrScannerService.onSetupCompleted = scannerSetupCompleted
        qrScannerService.onQRCodeDetected = textDetected
        qrScannerService.setup()
    }
    
    func scannerSetupCompleted(error: Error?) {
        guard error == nil else {
            print("Error happened \(error!)")
            previewContainer.isHidden = true
            return
        }
        guard let layer = qrScannerService.previewLayer else {
            return
        }
        DispatchQueue.main.async {
            self.previewContainer.layer.addSublayer(layer)
            self.updatePreviewLayerFrame()
            self.qrScannerService.startScanning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        lastText = nil
    }
    
    func showInvalidQRWarning(qrText: String) {
        guard warningView.isHidden else { return }
        warningView.isHidden = false
        delay(3.0) { 
            self.warningView.isHidden = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePreviewLayerFrame()
    }
    
    func updatePreviewLayerFrame() {
        qrScannerService.previewLayer?.frame = previewContainer.layer.bounds
    }
    
    func textDetected(text: String) {
        if text == lastText { return }
        lastText = text
        delegate?.qrCodeScanViewController(self, detectedText: text)
    }
    
    func cancelPressed() {
        delegate?.qrCodeScanViewControllerCancel(self)
        qrScannerService.stopScanning()
    }
}

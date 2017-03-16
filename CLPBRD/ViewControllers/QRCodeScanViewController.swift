//
//  QRCodeScanViewController.swift
//  CLPBRD
//
//  Created by Александр Долоз on 14.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit

protocol QRCodeScanViewControllerDelegate: class {
    func qrCodeScanViewControllerCancel(_ viewController: QRCodeScanViewController)
    func qrCodeScanViewController(_ viewController: QRCodeScanViewController, detectedText: String)
}

class QRCodeScanViewController: UIViewController {
    var qrScannerService: QRScannerService
    
    weak var delegate: QRCodeScanViewControllerDelegate?
    
    init(qrScannerService: QRScannerService) {
        self.qrScannerService = qrScannerService
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var previewContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))
        title = "Scan QR code"
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePreviewLayerFrame()
    }
    
    func updatePreviewLayerFrame() {
        qrScannerService.previewLayer?.frame = previewContainer.layer.bounds
    }
    
    func textDetected(text: String) {
        delegate?.qrCodeScanViewController(self, detectedText: text)
    }
    
    func cancelPressed() {
        delegate?.qrCodeScanViewControllerCancel(self)
        qrScannerService.stopScanning()
    }
}

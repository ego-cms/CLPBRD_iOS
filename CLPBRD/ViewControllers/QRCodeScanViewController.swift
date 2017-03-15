//
//  QRCodeScanViewController.swift
//  CLPBRD
//
//  Created by Александр Долоз on 14.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit

protocol QRCodeScanViewControllerDelegate: class {
    func cancelPressed(on viewController: QRCodeScanViewController)
    func textDetected(on viewController: QRCodeScanViewController, string: String)
}

class QRCodeScanViewController: UIViewController {
    var qrScannerService: QRScannerService
    
    weak var delegate: QRCodeScanViewControllerDelegate?
    
    init(qrScannerService: QRScannerService) {
        self.qrScannerService = qrScannerService
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
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
        previewContainer.layer.addSublayer(layer)
        qrScannerService.startScanning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        qrScannerService.previewLayer?.frame = previewContainer.layer.bounds
    }
    
    func textDetected(text: String) {
        delegate?.textDetected(on: self, string: text)
    }
    
    func cancelPressed() {
        delegate?.cancelPressed(on: self)
        qrScannerService.stopScanning()
    }
}

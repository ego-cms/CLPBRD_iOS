//
//  QRCodeDisplayViewController.swift
//  CLPBRD
//
//  Created by Александр Долоз on 14.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

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
            self.qrCodeCreationFinished(text: $0, result: $1)
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))
        title = "QR Code"
        createQRCode()
        
        blurView.effect = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        blurView.effect = nil
        view.backgroundColor = UIColor.white

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5) {
            self.blurView.effect = UIBlurEffect(style: .extraLight)
            self.view.backgroundColor = .clear
        }
    }
    
    func createQRCode() {
        qrDisplayService.text = "blablabla"
    }
    
    func qrCodeCreationFinished(text: String, result: Result<UIImage, QRDisplayError>) {
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

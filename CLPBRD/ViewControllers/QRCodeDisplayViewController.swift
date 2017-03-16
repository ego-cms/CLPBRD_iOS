//
//  QRCodeDisplayViewController.swift
//  CLPBRD
//
//  Created by Александр Долоз on 14.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit


protocol QRCodeDisplayViewControllerDelegate: class {
    func cancelPressed(on viewController: QRCodeDisplayViewController)
}


class QRCodeDisplayViewController: UIViewController {
    var qrDisplayService: QRDisplayService
    @IBOutlet weak var qrImageView: UIImageView!
    weak var delegate: QRCodeDisplayViewControllerDelegate?
    
    init(qrDisplayService: QRDisplayService) {
        self.qrDisplayService = qrDisplayService
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))
        title = "QR Code"
    }
    
    func cancelPressed() {
//        delegate?
    }
}

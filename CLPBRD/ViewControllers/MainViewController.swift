//
//  MainViewController.swift
//  CLPBRD
//
//  Created by Александр Долоз on 14.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit


protocol MainViewControllerDelegate: class {
    func mainViewControllerDisplayQR(_ viewController: MainViewController)
    func mainViewControllerScanQR(_ viewController: MainViewController)
}

class MainViewController: UIViewController {
    @IBOutlet weak var toggleButton: RoundButton!
    @IBOutlet weak var scanQRButton: RoundButton!
    @IBOutlet weak var showQRButton: UIButton!
    
    weak var delegate: MainViewControllerDelegate?
    
    var clipboardSyncClientService: ClipboardSyncClientService
    
    init(clipboardSyncClientService: ClipboardSyncClientService) {
        self.clipboardSyncClientService = clipboardSyncClientService
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func showQRPressed(_ sender: Any) {
        delegate?.mainViewControllerDisplayQR(self)
    }
    
    @IBAction func scanQRPressed(_ sender: Any) {
        delegate?.mainViewControllerScanQR(self)
    }
    
    @IBAction func togglePressed(_ sender: Any) {
//        delegate?.togglePressed(on: self, toggled: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        scanQRButton.highlightColor = Colors.scanQRButtonHighlighted.color
        scanQRButton.normalColor = Colors.scanQRButtonNormal.color
//        clipboardSyncClientService.connect(host: "192.168.0.113")
        
//        clipboardSyncClientService.onDisconnected = { [unowned self](error) in
////            print("Disconnected")
////            print(error)
//        }
    }
    
    
}

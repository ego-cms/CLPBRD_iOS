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
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var controlPanelContainer: UIView!
    
    weak var delegate: MainViewControllerDelegate?
    
    var clipboardSyncClientService: ClipboardSyncClientService
    var controlPanelViewController: ControlPanelViewController
    
    init(controlPanelViewController: ControlPanelViewController, clipboardSyncClientService: ClipboardSyncClientService) {
        self.controlPanelViewController = controlPanelViewController
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
        logo.tintColor = .white

        addChildViewController(controlPanelViewController)
        controlPanelViewController.didMove(toParentViewController: self)
        controlPanelViewController.view.frame = controlPanelContainer.bounds
        controlPanelContainer.addSubview(controlPanelViewController.view)
        
        /*
        */
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}

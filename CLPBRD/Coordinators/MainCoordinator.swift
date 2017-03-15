//
//  MainCoordinator.swift
//  CLPBRD
//
//  Created by Александр Долоз on 14.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit
import Swinject



class MainCoordinator: Coordinator {
    var initialViewController: UIViewController
    var onCompletion: VoidClosure = {}
    let mainViewController: MainViewController
    
    unowned var container: Container
    
    init(container: Container) {
        self.container = container
        self.mainViewController = container.resolve(MainViewController.self)!
        self.initialViewController = mainViewController
        mainViewController.delegate = self
    }
}


extension MainCoordinator: MainViewControllerDelegate {
    func scanQRPressed(on mainViewController: MainViewController) {
        let qrCodeScanViewController = self.container.resolve(QRCodeScanViewController.self)!
        qrCodeScanViewController.delegate = self
        qrCodeScanViewController.modalTransitionStyle = .crossDissolve
        let navigationController = UINavigationController(rootViewController: qrCodeScanViewController)
        navigationController.modalPresentationStyle = .overCurrentContext
        self.mainViewController.present(navigationController, animated: true, completion: nil)
    }
    
    func showQRPressed(on mainViewController: MainViewController) {
        
    }
    
    func togglePressed(on mainViewController: MainViewController, toggled: Bool) {
        
    }
}


extension MainCoordinator: QRCodeScanViewControllerDelegate {
    func cancelPressed(on viewController: QRCodeScanViewController) {
        mainViewController.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func textDetected(on viewController: QRCodeScanViewController, string: String) {
        print("Text: \(string)")
    }
}

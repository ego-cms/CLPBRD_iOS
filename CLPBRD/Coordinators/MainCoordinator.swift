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
    func mainViewControllerScanQR(_ viewController: MainViewController) {
        let qrCodeScanViewController = self.container.resolve(QRCodeScanViewController.self)!
        qrCodeScanViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: qrCodeScanViewController)
        navigationController.modalPresentationStyle = .overCurrentContext
        self.mainViewController.present(navigationController, animated: true, completion: nil)
    }
    
    func mainViewControllerDisplayQR(_ viewController: MainViewController) {
        let qrCodeDisplayViewController = self.container.resolve(QRCodeDisplayViewController.self)!
        qrCodeDisplayViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: qrCodeDisplayViewController)
        navigationController.modalPresentationStyle = .overCurrentContext
        self.mainViewController.present(navigationController, animated: true, completion: nil)
    }
}


extension MainCoordinator: QRCodeScanViewControllerDelegate {
    func qrCodeScanViewControllerCancel(_ viewController: QRCodeScanViewController) {
        mainViewController.presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    func qrCodeScanViewController(_ viewController: QRCodeScanViewController, detectedText text: String) {
        print(text)
    }
}


extension MainCoordinator: QRCodeDisplayViewControllerDelegate {
    func qrCodeDisplayViewControllerCancel(_ viewController: QRCodeDisplayViewController) {
        mainViewController.presentedViewController?.dismiss(animated: true, completion: nil)
    }
}

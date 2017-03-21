//
//  MainCoordinator.swift
//  CLPBRD
//
//  Created by Александр Долоз on 14.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit
import Swinject



class MainCoordinator: NSObject, Coordinator {
    var initialViewController: UIViewController
    var onCompletion: VoidClosure = {}
    let mainViewController: MainViewController
    var currentViewController: UIViewController
    
    unowned var container: Container
    
    init(container: Container) {
        self.container = container
        self.mainViewController = container.resolve(MainViewController.self)!
        self.initialViewController = mainViewController
        self.currentViewController = mainViewController
        super.init()
        mainViewController.delegate = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


extension MainCoordinator: MainViewControllerDelegate {
    func mainViewControllerScanQR(_ viewController: MainViewController) {
        let qrCodeScanViewController = self.container.resolve(QRCodeScanViewController.self)!
        qrCodeScanViewController.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(qrRepositoryUpdated(notification:)), name: repositoryUpdateNotificationName, object: qrCodeScanViewController.resultRepo)
        let navigationController = UINavigationController(rootViewController: qrCodeScanViewController)
        navigationController.modalPresentationStyle = .overCurrentContext
        self.currentViewController = navigationController
        self.mainViewController.present(navigationController, animated: true, completion: nil)
    }
    
    func mainViewControllerDisplayQR(_ viewController: MainViewController) {
        let qrCodeDisplayViewController = self.container.resolve(QRCodeDisplayViewController.self)!
        qrCodeDisplayViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: qrCodeDisplayViewController)
        navigationController.modalPresentationStyle = .overCurrentContext
        self.currentViewController = navigationController
        self.mainViewController.present(navigationController, animated: true, completion: nil)
    }
    
    func qrRepositoryUpdated(notification: Notification) {
        guard
            let repo = notification.object as? Repository<String>,
            repo.items.count > 0
        else {
            return
        }
        NotificationCenter.default.removeObserver(self, name: repositoryUpdateNotificationName, object: nil)
        let connectionViewController = self.container.resolve(ConnectionViewController.self)!
        currentViewController.present(connectionViewController, animated: true, completion: nil)
    }
}


extension MainCoordinator: QRCodeScanViewControllerDelegate {
    func qrCodeScanViewControllerCancel(_ viewController: QRCodeScanViewController) {
        mainViewController.presentedViewController?.dismiss(animated: true, completion: nil)
        currentViewController = mainViewController
    }
    
    func qrCodeScanViewController(_ viewController: QRCodeScanViewController, detectedText text: String) {
        print(text)
    }
}


extension MainCoordinator: QRCodeDisplayViewControllerDelegate {
    func qrCodeDisplayViewControllerCancel(_ viewController: QRCodeDisplayViewController) {
        mainViewController.presentedViewController?.dismiss(animated: true, completion: nil)
        currentViewController = mainViewController
    }
}

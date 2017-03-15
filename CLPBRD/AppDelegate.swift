//
//  AppDelegate.swift
//  CLPBRD
//
//  Created by Александр Долоз on 14.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit
import Swinject

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    lazy var appContainer: Container = {
        let container = Container()
        container.register(MainViewController.self) { _ in
            MainViewController()
        }
        container.register(Coordinator.self) { r in
            MainCoordinator(mainViewController: r.resolve(MainViewController.self)!)
        }.initCompleted { r, c in
            let coordinator = c as! MainCoordinator
            coordinator.qrCodeDisplayViewControllerBuilder = {
                QRCodeDisplayViewController()
            }
            coordinator.qrCodeScanViewControllerBuilder = {
                QRCodeScanViewController()
            }
        }
        return container
    }()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        let rootVC = appContainer.resolve(Coordinator.self)?.initialViewController
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        return true
    }
}


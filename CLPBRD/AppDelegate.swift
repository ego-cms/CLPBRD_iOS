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
        container.register(MainViewController.self) { r in
            MainViewController(clipboardSyncClientService: r.resolve(ClipboardSyncClientService.self)!)
        }
        container.register(Coordinator.self) { [unowned container](_) in
            MainCoordinator(container: container)
        }.inObjectScope(.container)
        
        container.register(QRScannerService.self) { _ in
            QRScanner()
        }.inObjectScope(.transient)
        container.register(QRDisplayService.self) { _ in
            QRDisplay()
        }
        container.register(QRCodeDisplayViewController.self) { r in
            QRCodeDisplayViewController(qrDisplayService: r.resolve(QRDisplayService.self)!)
        }
        container.register(ClipboardSyncClientService.self) { r in
            ClipboardSyncClient(clipboardProviderService: r.resolve(ClipboardProviderService.self)!, socketClientService: r.resolve(SocketClientService.self)!)
        }
        container.register(ClipboardProviderService.self) { _ in
            ClipboardProvider()
        }
        container.register(SocketClientService.self) { _ in
            SocketClient()
        }
        container.register(QRCodeScanViewController.self) { r in
            QRCodeScanViewController(qrScannerService: r.resolve(QRScannerService.self)!)
        }.inObjectScope(.transient)
        return container
    }()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        let rootVC = appContainer.resolve(Coordinator.self)?.initialViewController
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        window?.backgroundColor = .green
        return true
    }
}


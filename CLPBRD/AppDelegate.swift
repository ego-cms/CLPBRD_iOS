//
//  AppDelegate.swift
//  CLPBRD
//
//  Created by Александр Долоз on 14.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit
import Swinject


enum Names {
    static let scannedQR = "scannedQR"
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    lazy var appContainer: Container = {
        let container = Container()
        container.register(ControlPanelViewController.self) { [unowned container](r) in
            ControlPanelViewController(
                container: container,
                socketClientService: r.resolve(SocketClientService.self)!,
                clipboardProviderService: r.resolve(ClipboardProviderService.self)!,
                appStateService: r.resolve(AppStateService.self)!
            )
        }
        container.register(MainViewController.self) { r in
            MainViewController(
                controlPanelViewController: r.resolve(ControlPanelViewController.self)!,
                clipboardSyncClientService: r.resolve(ClipboardSyncClientService.self)!
            )
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
        container.register(AppStateService.self) { _ in
            AppState()
        }
        container.register(ClipboardSyncClientService.self) { r in
            ClipboardSyncClient(
                clipboardProviderService: r.resolve(ClipboardProviderService.self)!,
                socketClientService: r.resolve(SocketClientService.self)!,
                appStateService: r.resolve(AppStateService.self)!
            )
        }
        container.register(ClipboardProviderService.self) { _ in
            ClipboardProvider()
        }
        container.register(SocketClientService.self) { _ in
            SocketClient()
        }
        container.register(QRCodeScanViewController.self) { r in
            QRCodeScanViewController(
                qrScannerService: r.resolve(QRScannerService.self)!,
                resultRepo: r.resolve(Repository<String>.self, name: Names.scannedQR)
            )
        }.inObjectScope(.transient)
        container.register(Repository<String>.self, name: Names.scannedQR) { _ in
            let repo = Repository<String>()
            repo.preprocessor = {
                guard let url = URL(string: $0) else { return nil }
                return url.host
            }
            return repo
        }.inObjectScope(.container)
        container.register(ConnectionViewController.self) { r in
            ConnectionViewController(
                hostRepository: r.resolve(Repository<String>.self, name: Names.scannedQR)!,
                socketClientService: r.resolve(SocketClientService.self)!,
                clipboardProviderService: r.resolve(ClipboardProviderService.self)!
            )
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


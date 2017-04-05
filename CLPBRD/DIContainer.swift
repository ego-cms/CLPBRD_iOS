import Foundation
import Swinject


func createContainer() -> Container {
    let container = Container()
    
    container.register(MainViewController.self) { r in
        MainViewController(
            controlPanelViewController: r.resolve(ControlPanelViewController.self)!
        )
    }

    container.register(ControlPanelViewController.self) { [unowned container](r) in
        ControlPanelViewController(
            container: container,
            socketClientService: r.resolve(SocketClientService.self)!,
            clipboardProviderService: r.resolve(ClipboardProviderService.self)!,
            appStateService: r.resolve(AppStateService.self)!
        )
    }
    
    container.register(QRScannerService.self) { _ in
        QRScanner()
    }.inObjectScope(.transient)
    
    container.register(QRDisplayService.self) { _ in
        QRDisplay()
    }.inObjectScope(.transient)
    
    container.register(QRCodeDisplayViewController.self) { r in
        QRCodeDisplayViewController(qrDisplayService: r.resolve(QRDisplayService.self)!)
    }.inObjectScope(.transient)
    
    container.register(QRCodeScanViewController.self) { r in
        QRCodeScanViewController(
            qrScannerService: r.resolve(QRScannerService.self)!
        )
    }.inObjectScope(.transient)
    
    container.register(AppStateService.self) { _ in
        AppState()
    }
    
    container.register(ClipboardProviderService.self) { _ in
        ClipboardProvider()
    }
    
    container.register(SocketClientService.self) { _ in
        SWSSocketClient()
    }
    return container
}

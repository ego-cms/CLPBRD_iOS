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
            webSocketClientService: r.resolve(WebSocketClientService.self)!,
            clipboardProviderService: r.resolve(ClipboardProviderService.self)!,
            appStateService: r.resolve(AppStateService.self)!,
            clipboardSyncServerService: r.resolve(ClipboardSyncServerService.self)!
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
    
    container.register(WebSocketClientService.self) { _ in
        WebSocketClient()
    }
    
    container.register(HTTPServerService.self) { _ in
        HTTPServer()
    }
    
    container.register(WebSocketServerService.self) { _ in
        WebSocketServer()
    }
    
    container.register(ClipboardSyncServerService.self) { r in
        SyncServer(
            httpServerService: r.resolve(HTTPServerService.self)!,
            webSocketServerService: r.resolve(WebSocketServerService.self)!,
            clipboardProviderService: r.resolve(ClipboardProviderService.self)!,
            appStateService: r.resolve(AppStateService.self)!
        )
    }
    
    container.register(SyncServerDebugViewController.self) { r in
        SyncServerDebugViewController(clipboardSyncServerService: r.resolve(ClipboardSyncServerService.self)!)
    }
    
    container.register(UIViewController.self, name: "root") { r in
        if ProcessInfo.processInfo.arguments.contains("DEBUG_SYNC_SERVER") {
            return r.resolve(SyncServerDebugViewController.self)!
        }
        
        return r.resolve(MainViewController.self)!
    }
    
    return container
}

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
            clipboardSyncServerService: r.resolve(ClipboardSyncServerService.self)!,
            clipboardSyncClientService: r.resolve(ClipboardSyncClientService.self)!
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
    }.inObjectScope(.transient)
    
    container.register(ClipboardProviderService.self) { _ in
        ClipboardProvider()
    }
    
    container.register(WebSocketClientService.self) { _ in
        PocketSocketClient()
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
    
    container.register(ClipboardSyncClientService.self) {
        r in
        SyncClient(
            webSocketClientService: r.resolve(WebSocketClientService.self)!,
            clipboardProviderService: r.resolve(ClipboardProviderService.self)!,
            appStateService: r.resolve(AppStateService.self)!
        )
    }
    
    container.register(SyncServerDebugViewController.self) { r in
        SyncServerDebugViewController(clipboardSyncServerService: r.resolve(ClipboardSyncServerService.self)!)
    }
    
    container.register(SyncClientDebugViewController.self) { r in
        SyncClientDebugViewController(clipboardSyncClientService: r.resolve(ClipboardSyncClientService.self)!)
    }
    
    container.register(UIViewController.self, name: "root") { r in
        
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("DEBUG_SYNC_SERVER") {
            return r.resolve(SyncServerDebugViewController.self)!
        }
        
        if arguments.contains("DEBUG_SYNC_CLIENT") {
            return r.resolve(SyncClientDebugViewController.self)!
        }
        
        return r.resolve(MainViewController.self)!
    }
    
    return container
}

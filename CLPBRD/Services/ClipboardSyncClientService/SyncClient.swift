import Foundation


class SyncClient: NSObject, ClipboardSyncClientService {
    private var webSocketClientService: WebSocketClientService
    private var clipboardProviderService: ClipboardProviderService
    private var appStateService: AppStateService
    
    init(webSocketClientService: WebSocketClientService, clipboardProviderService: ClipboardProviderService, appStateService: AppStateService) {
        self.webSocketClientService = webSocketClientService
        self.clipboardProviderService = clipboardProviderService
        self.appStateService = appStateService
        super.init()
        webSocketClientService.onConnected = webSocketServiceConnected
        webSocketClientService.onDisconnected = webSocketServiceDisconnected
        webSocketClientService.onReceivedText = textReceived
        clipboardProviderService.onContentChanged = clipboardContentChanged
        appStateService.onAppEnterForeground = appEnteredForeground
    }
    
    /// URL of remote server
    var serverURL: URL? {
        return nil
    }
    
    private var lastHost: String?
    private var lastPort: UInt?
    
    private var lastReceivedText: String?
    private var justEnteredForeground: Bool = false
    
    /// Connects to the server
    /// This port is for http, websocket port is returned separately
    /// using GET /clipboard request.
    /// Should be idempotent, i.e. you can call it twice without problems
    func connect(host: String, port: UInt) {
        lastHost = host
        lastPort = port
        webSocketClientService.connect(host: host)
    }
    
    /// Disconnects from the server
    func disconnect() {
        lastHost = nil
        lastPort = nil
        webSocketClientService.disconnect()
    }
    
    private(set) var isConnected: Bool = false
    
    /// Called after successful connection
    var onConnected: (Void) -> Void = { }
    
    /// Called when client was disconnected
    var onDisconnected: (Error?) -> Void = { _ in }
    
    var onUpdatesReceived: (Void) -> Void = { }
    
    func webSocketServiceConnected() {
        isConnected = true
        if justEnteredForeground {
            clipboardContentChanged()
        }
        justEnteredForeground = false
        onConnected()
    }
    
    func webSocketServiceDisconnected(error: Error?) {
        isConnected = false
        onDisconnected(error)
    }
    
    func textReceived(text: String) {
        guard clipboardProviderService.content != text else { return }
        lastReceivedText = text
        onUpdatesReceived()
    }
    
    func clipboardContentChanged() {
        guard let content =  clipboardProviderService.content,
            content != lastReceivedText else { return }
        webSocketClientService.send(text: content)
    }
    
    func appEnteredForeground() {
        guard let lastHost = self.lastHost, let lastPort = self.lastPort else { return }
        justEnteredForeground = true
        connect(host: lastHost, port: lastPort)
    }
    
    /// Store updates in clipboard and send them to all other clients (except the one which sent original updates)
    func takeUpdates() {
        guard let lastUpdate = lastReceivedText else { return }
        clipboardProviderService.content = lastUpdate
        lastReceivedText = nil
    }
}

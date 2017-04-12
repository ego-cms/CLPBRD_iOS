import Foundation


class SyncClient: NSObject, ClipboardSyncClientService {
    private var webSocketClientService: WebSocketClientService
    private var clipboardProviderService: ClipboardProviderService
    private var appStateService: AppStateService
    
    init(webSocketClientService: WebSocketClientService, clipboardProviderService: ClipboardProviderService, appStateService: AppStateService) {
        self.webSocketClientService = webSocketClientService
        self.clipboardProviderService = clipboardProviderService
        self.appStateService = appStateService
    }
    
    /// URL of remote server
    var serverURL: URL? {
        return nil
    }
    
    /// Connects to the server
    /// This port is for http, websocket port is returned separately
    /// using GET /clipboard request.
    /// Should be idempotent, i.e. you can call it twice without problems
    func connect(host: String, port: UInt) {
        
    }
    
    /// Disconnects from the server
    func disconnect() {
        
    }
    
    var isConnected: Bool {
        return false
    }
    
    /// Called after successful connection
    var onConnected: (Void) -> Void = { }
    
    /// Called when client was disconnected
    var onDisconnected: (Error?) -> Void = { _ in }
    
    /// Called when some of the clients
    var onUpdatesReceived: (Void) -> Void = { }
    
    /// Store updates in clipboard and send them to all other clients (except the one which sent original updates)
    func takeUpdates() {
        
    }
}

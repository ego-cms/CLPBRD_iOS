import Foundation


class SyncServer: NSObject, ClipboardSyncServerService {

    /// URL of running HTTP server if any
    var serverURL: URL? {
        return httpServerService.serverURL
    }
    
    /// Current state of the server
    private(set) var state: ServerState = .off {
        didSet {
            onStateChanged(state)
        }
    }
    
    /// Called when state changes
    var onStateChanged: (ServerState) -> Void = { _ in }
    
    /// Called when some of the clients
    var onUpdatesReceived: (Void) -> Void = { }

    
    private var webSocketConfigurationJSON: [String: Any] {
        return [
            "host": serverURL?.host ?? "",
            "port": currentWebSocketPort,
            "text": clipboardProviderService.content ?? ""
        ]
    }
    
    private var currentWebSocketPort: UInt = 0
    
    private func generateNewWebSocketPort() {
        currentWebSocketPort = random(from: 30000, to: 40000)
    }
    
    private var lastActiveClientId: ClientId?
    private var lastContent: String?
    
    
    /// Starts the HTTP server on this port and WebSocket server on autogenerated port
    /// Should be idempotent, i.e. you can call it twice without problems
    func start(port: UInt) {
        httpServerService.startServer(port: port)
        if httpServerService.webSocketConfigurationJSON == nil {
            generateNewWebSocketPort()
            httpServerService.webSocketConfigurationJSON = webSocketConfigurationJSON
//            webSocketListenOnCurrentPort()
        }
    }
    
    func webSocketListenOnCurrentPort() {
        guard let serverURL = self.serverURL, let host = serverURL.host else {
            print("Can't launch websocket server – no server url")
            return
        }
        webSocketServerService.listen(ipAddress: host, port: currentWebSocketPort)
    }
    
    /// Stops the servers
    func stop() {
        webSocketServerService.stop()
        httpServerService.webSocketConfigurationJSON = nil
        httpServerService.stopServer()
    }
    
    /// Store updates in clipboard and send them to all other clients (except the one which sent original updates)
    func takeUpdates() {
        if let lastContent = lastContent {
            clipboardProviderService.content = lastContent
        }
    }
    
    private var httpServerService: HTTPServerService
    private var webSocketServerService: WebSocketServerService
    private var clipboardProviderService: ClipboardProviderService
    private var appStateService: AppStateService
    
    init(
        httpServerService: HTTPServerService,
        webSocketServerService: WebSocketServerService,
        clipboardProviderService: ClipboardProviderService,
        appStateService: AppStateService
    ) {
        self.httpServerService = httpServerService
        self.webSocketServerService = webSocketServerService
        self.clipboardProviderService = clipboardProviderService
        self.appStateService = appStateService
        super.init()
        
        clipboardProviderService.onContentChanged = clipboardContentChanged
        webSocketServerService.onClientConnected = clientConnected
        webSocketServerService.onClientDisconnected = clientDisconnected
        webSocketServerService.onMessageReceived = messageReceived
        httpServerService.onRunningChanged = httpServerIsRunningChanged
        appStateService.onAppEnterForeground = appEnteredForeground
    }
    
    func clipboardContentChanged() {
        guard let content = clipboardProviderService.content else { return }
        httpServerService.webSocketConfigurationJSON = self.webSocketConfigurationJSON
        for clientId in webSocketServerService.clientIds where clientId != lastActiveClientId {
            webSocketServerService.send(message: content, to: clientId)
        }
        lastActiveClientId = nil
    }
    
    func clientConnected(clientId: ClientId) {
        print("\(clientId) connected")
    }
    
    func clientDisconnected(clientId: ClientId, error: Error?) {
        print("\(clientId) disconnected with error \(String(describing: error))")
    }
    
    func messageReceived(clientId: ClientId, message: String) {
        guard message != clipboardProviderService.content else { return }
        lastActiveClientId = clientId
        lastContent = message
        onUpdatesReceived()
    }
    
    func httpServerIsRunningChanged(isRunning: Bool) {
        state = isRunning ? .on : .off
        print("--- http server is running \(isRunning)")
        if isRunning {
            webSocketListenOnCurrentPort()
        } else {
            webSocketServerService.stop()
        }
    }
    
    func appEnteredForeground() {
//        webSocketListenOnCurrentPort()
    }
}

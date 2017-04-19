import Foundation


class WebSocketServer: NSObject, WebSocketServerService {
    fileprivate var pocketSocketServer: PSWebSocketServer?
    fileprivate var openedWebSockets: [ClientId: PSWebSocket] = [:]
    private let pingInterval: TimeInterval = 5.0
    private var timer: Timer?
    private static let pingData = "CLPBRD".data(using: .utf8)!
    
    
    private func schedulePing() {
        log.verbose("Scheduling ping for socket server with interval \(pingInterval)")
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: pingInterval, repeats: true, block: { [weak self](_) in
    
            guard let openedWebSockets = self?.openedWebSockets else {
                return
            }
            for (id, socket) in openedWebSockets {
                socket.ping(WebSocketServer.pingData) { data in
                    if data != WebSocketServer.pingData { // ping failed
                        log.verbose("Socket server ping failed to client \(id)")
                        log.verbose("Ping data - \(WebSocketServer.pingData), received data – data")
                        log.verbose("Client will be disconnected")
                        self?.disconnectClient(withId: id)
                    }
                }
            }
        })
    }
    
    func listen(ipAddress: String, port: UInt) {
        if isRunning {
            return
        }
        log.verbose("Socket server listening port \(port) on \(ipAddress)")
        pocketSocketServer = PSWebSocketServer(host: ipAddress, port: port)
        pocketSocketServer?.delegate = self
        pocketSocketServer?.delegateQueue = .main
        pocketSocketServer?.start()
        schedulePing()
    }
    
    func disconnectClient(withId clientId: ClientId) {
        guard let socket = openedWebSockets[clientId] else {
            log.warning("Client with id \(clientId) doesn't exist.")
            return
        }
        socket.close()
        openedWebSockets[clientId] = nil
        log.verbose("Client with id \(clientId) was disconnected.")
    }
    
    func send(message: String, to clientId: ClientId) {
        guard let socket = openedWebSockets[clientId] else {
            log.warning("Client with id \(clientId) doesn't exist.")
            return
        }
        guard socket.readyState == .open else {
            log.warning("Socket for client \(clientId) is not opened; its state is \(socket.readyState)")
            return
        }
        socket.send(message)
        log.warning("Socket server sent message \(message) to client \(clientId)")
    }
    
    func broadcast(message: String) {
        clientIds.forEach {
            send(message: message, to: $0)
        }
    }
    
    func stop() {
        pocketSocketServer?.stop()
        pocketSocketServer = nil
        openedWebSockets = [:]
        timer?.invalidate()
        timer = nil
        log.verbose("Socket server stopped")
    }
    
    fileprivate func clientId(for webSocket: PSWebSocket) -> ClientId? {
        for (id, socket) in openedWebSockets {
            if socket == webSocket {
                return id
            }
        }
        return nil
    }
    
    fileprivate func disconnect(webSocket: PSWebSocket) {
        guard let id = clientId(for: webSocket) else { return }
        disconnectClient(withId: id)
    }
    
    fileprivate(set) var isRunning: Bool = false
        
    
    var clientIds: Set<ClientId> {
        return Set(openedWebSockets.keys)
    }
    
    deinit {
        pocketSocketServer?.stop()
        pocketSocketServer = nil
        timer?.invalidate()
        timer = nil
    }
    
    var onServerStarted: (Void) -> Void = { }
    var onServerStopped: (Error?) -> Void = { _ in }
    var onClientConnected: (ClientId) -> Void = { _ in }
    var onClientDisconnected: (ClientId, Error?) -> Void = { _ in }
    var onMessageReceived: (ClientId, String) -> Void = { _ in }
}


extension WebSocketServer: PSWebSocketServerDelegate {
    func serverDidStart(_ server: PSWebSocketServer!) {
        log.verbose("PSWebSocketServerDelegate: server did start")
        isRunning = true
        onServerStarted()
    }
    
    func server(_ server: PSWebSocketServer!, didFailWithError error: Error!) {
        log.verbose("PSWebSocketServerDelegate: Websocket server failed with error \(error)")
        isRunning = false
        onServerStopped(error)
    }
    
    func serverDidStop(_ server: PSWebSocketServer!) {
        log.verbose("PSWebSocketServerDelegate: Websocket server did stop")
        isRunning = false
        onServerStopped(nil)
    }
    
    func server(_ server: PSWebSocketServer!, webSocketDidOpen webSocket: PSWebSocket!) {
        log.verbose("PSWebSocketServerDelegate: Websocket server did open socket \(webSocket)")
        let id = ClientId()
        openedWebSockets[id] = webSocket
        onClientConnected(id)
    }
    
    func server(_ server: PSWebSocketServer!, webSocket: PSWebSocket!, didReceiveMessage message: Any!) {
        log.verbose("PSWebSocketServerDelegate: Websocket server did receive message \(message) from socket \(webSocket)")
        guard
            let id = clientId(for: webSocket)
        else {
            print("No client corresponding to web socket \(webSocket)")
            return
        }
        log.verbose("This is client \(id)")
        
        guard let string = message as? String else {
            print("Expected to get string; got something else: \(message)")
            return
        }
        
        onMessageReceived(id, string)
    }
    
    func server(_ server: PSWebSocketServer!, webSocket: PSWebSocket!, didFailWithError error: Error!) {
        log.verbose("PSWebSocketServerDelegate: Socket \(webSocket) failed with error \(error)")
        guard
            let id = clientId(for: webSocket)
        else {
            log.warning("No client corresponding to web socket \(webSocket)")
            return
        }
        disconnectClient(withId: id)
        onClientDisconnected(id, error)
    }
    
    func server(_ server: PSWebSocketServer!, webSocket: PSWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        log.verbose("PSWebSocketServerDelegate: Socket did close with code \(code) reason \(reason) was clean \(wasClean)")
        guard
            let id = clientId(for: webSocket)
        else {
            log.warning("No client corresponding to web socket \(webSocket)")
            return
        }
        disconnectClient(withId: id)
        onClientDisconnected(id, nil)
    }
}


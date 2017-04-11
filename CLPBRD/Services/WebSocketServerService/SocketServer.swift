import Foundation


class SocketServer: NSObject, WebSocketServerService {
    fileprivate var pocketSocketServer: PSWebSocketServer?
    fileprivate var openedWebSockets: [ClientId: PSWebSocket] = [:]
    private let pingInterval: TimeInterval = 5.0
    private var timer: Timer?
    private static let pingData = "CLPBRD".data(using: .utf8)!
    
    
    private func schedulePing() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: pingInterval, repeats: true, block: { [weak self](_) in
            guard let openedWebSockets = self?.openedWebSockets else {
                return
            }
            for (id, socket) in openedWebSockets {
                socket.ping(SocketServer.pingData) { data in
                    if data != SocketServer.pingData { // ping failed
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
        pocketSocketServer = PSWebSocketServer(host: ipAddress, port: port)
        pocketSocketServer?.delegate = self
        pocketSocketServer?.delegateQueue = .main
        pocketSocketServer?.start()
        schedulePing()
    }
    
    func disconnectClient(withId clientId: ClientId) {
        guard let socket = openedWebSockets[clientId] else {
            print("Client with id \(clientId) doesn't exist.")
            return
        }
        socket.close()
        openedWebSockets[clientId] = nil
    }
    
    func send(message: String, to clientId: ClientId) {
        guard let socket = openedWebSockets[clientId] else {
            print("Client with id \(clientId) doesn't exist.")
            return
        }
        guard socket.readyState == .open else {
            return
        }
        socket.send(message)
    }
    
    func broadcast(message: String) {
        clientIds.forEach {
            send(message: message, to: $0)
        }
    }
    
    func stop() {
        pocketSocketServer?.stop()
        pocketSocketServer = nil
        timer?.invalidate()
        timer = nil
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
    
    var onServerStarted: (Void) -> Void = { }
    var onServerStopped: (Error?) -> Void = { _ in }
    var onClientConnected: (ClientId) -> Void = { _ in }
    var onClientDisconnected: (ClientId, Error?) -> Void = { _ in }
    var onMessageReceived: (ClientId, String) -> Void = { _ in }
}


extension SocketServer: PSWebSocketServerDelegate {
    func serverDidStart(_ server: PSWebSocketServer!) {
        print("Server started")
        isRunning = true
        onServerStarted()
    }
    
    func server(_ server: PSWebSocketServer!, didFailWithError error: Error!) {
        print("Failed with error: \(error)")
        isRunning = false
        onServerStopped(error)
    }
    
    func serverDidStop(_ server: PSWebSocketServer!) {
        isRunning = false
        onServerStopped(nil)
    }
    
    func server(_ server: PSWebSocketServer!, webSocketDidOpen webSocket: PSWebSocket!) {
        let id = ClientId()
        openedWebSockets[id] = webSocket
        onClientConnected(id)
    }
    
    func server(_ server: PSWebSocketServer!, webSocket: PSWebSocket!, didReceiveMessage message: Any!) {
        guard
            let id = clientId(for: webSocket)
        else {
            print("No client corresponding to web socket \(webSocket)")
            return
        }
        
        guard let string = message as? String else {
            print("Expected to get string; got something else: \(message)")
            return
        }
        
        onMessageReceived(id, string)
    }
    
    func server(_ server: PSWebSocketServer!, webSocket: PSWebSocket!, didFailWithError error: Error!) {
        print("Socket \(webSocket) failed with error \(error)")
        guard
            let id = clientId(for: webSocket)
        else {
            print("No client corresponding to web socket \(webSocket)")
            return
        }
        disconnectClient(withId: id)
        onClientDisconnected(id, error)
    }
    
    func server(_ server: PSWebSocketServer!, webSocket: PSWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        print("Socket did close with code \(code) reason \(reason) was clean \(wasClean)")
        guard
            let id = clientId(for: webSocket)
        else {
            print("No client corresponding to web socket \(webSocket)")
            return
        }
        disconnectClient(withId: id)
        onClientDisconnected(id, nil)
    }
}


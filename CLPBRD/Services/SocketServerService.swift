import Foundation
import SwiftWebSocket


protocol SocketServerService: class {
    func listen(ipAddress: String, port: UInt)
    func disconnectClient(withId: ClientId)
    func send(message: String, to: ClientId)
    func broadcast(message: String)
    func stop()
    
    var isRunning: Bool { get }
    
    var clientIds: Set<ClientId> { get }
    
    var onClientConnected: (ClientId) -> Void { get set }
    var onClientDisconnected: (ClientId, Error?) -> Void { get set }
    var onMessageReceived: (ClientId, String) -> Void { get set }
}

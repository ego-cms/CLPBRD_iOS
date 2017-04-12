import Foundation
import Result


protocol WebSocketClientService: class {
    var onDisconnected: (Error?) -> Void { get set }
    var onConnected: VoidClosure { get set }
    var onReceivedText: (String) -> Void { get set }
    
    var url: URL? { get }
    
    // should be idempotent
    func connect(host: String)
    func send(text: String)
    
    // should be idempotent
    func disconnect()
}


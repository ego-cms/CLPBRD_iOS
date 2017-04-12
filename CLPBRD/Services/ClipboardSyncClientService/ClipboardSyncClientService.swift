import Foundation


/** This entity is for server mode of application. Its responsibilities:
 - starts HTTP server and serves HTML pages for browser and /clipboard parameters
 - starts WebSocket server, broadcasts content of clipboard to connected clients (automatically) and takes updates from clients into local clipboard (manually)
 - handles generation of port for WebSocket server
 - handles changes of app state (background/foreground) and restarts servers as needed. */
/** Client mode of application. Responsibilities:
 - connects and disconnects to/from server
 - keeps track of connection state
 - automatically gets websocket port from /clipboard http endpoint
 - automatically sends clipboard to the server when it updates
 - manually takes clipboard from the server
*/
protocol ClipboardSyncClientService: class {
    /// URL of remote server
    var serverURL: URL? { get }
    
    /// Connects to the server
    /// This port is for http, websocket port is returned separately 
    /// using GET /clipboard request.
    /// Should be idempotent, i.e. you can call it twice without problems
    func connect(host: String, port: UInt)
    
    /// Disconnects from the server
    func disconnect()
    
    var isConnected: Bool { get }
    
    /// Called after successful connection
    var onConnected: (Void) -> Void { get set }
    
    /// Called when client was disconnected
    var onDisconnected: (Error?) -> Void { get set }
    
    /// Called when some of the clients
    var onUpdatesReceived: (Void) -> Void { get set }
    
    /// Store updates in clipboard and send them to all other clients (except the one which sent original updates)
    func takeUpdates()
}




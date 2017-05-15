import Foundation


/** This entity is for server mode of application. Its responsibilities: 
 - starts HTTP server and serves HTML pages for browser and /clipboard parameters
 - starts WebSocket server, broadcasts content of clipboard to connected clients (automatically) and takes updates from clients into local clipboard (manually)
 - handles generation of port for WebSocket server
 - handles changes of app state (background/foreground) and restarts servers as needed. */
protocol ClipboardSyncServerService: class {
    /// URL of running HTTP server if any
    var serverURL: URL? { get }
    
    /// Starts the HTTP server on this port and WebSocket server on autogenerated port
    /// Should be idempotent, i.e. you can call it twice without problems
    func start(port: UInt)
    
    /// Stops the servers
    func stop()
    
    /// Current state of the server
    var state: ServerState { get }
    
    /// Called when state changes
    var onStateChanged: (ServerState) -> Void { get set }
    
    /// Called when some of the clients
    var onUpdatesReceived: (Void) -> Void { get set }
    
    /// Store updates in clipboard and send them to all other clients (except the one which sent original updates)
    func takeUpdates()
}

enum ServerState {
    case off
    case on
}
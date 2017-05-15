import Foundation
import GCDWebServer


protocol HTTPServerService: class {
    func startServer(port: UInt)
    func stopServer()
    
    var serverURL: URL? { get }
    
    var isRunning: Bool { get }
    
    var onRunningChanged: (Bool) -> Void { get set }
    var webSocketConfigurationJSON: [String: Any]? { get set } // json sent to GET /clipboard request
}

import Foundation
import GCDWebServer
import SwiftWebSocket


protocol HTTPServerService: class {
    func startServer(port: UInt)
    func stopServer()
    
    var serverURL: URL? { get }
    
    var webSocketConfigurationJSON: [String: Any] { get set } // json sent to GET /clipboard request
}

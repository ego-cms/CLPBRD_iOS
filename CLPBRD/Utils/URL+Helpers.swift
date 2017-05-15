import Foundation


extension URL {
    static func createWebSocketURL(with host: String, port: UInt) -> URL? {
        assert(port > 0)
        var components = URLComponents()
        components.scheme = "ws"
        components.host = host
        components.port = Int(port)
        return components.url
    }
    
    static func createParametersURL(with host: String, port: UInt = 8080) -> URL? {
        assert(port > 0)
        var components = URLComponents()
        components.scheme = "http"
        components.host = host
        components.port = Int(port)
        components.path = "/clipboard"
        return components.url
    }
    
    static func createBrowserURL(with host: String, port: UInt = 8080) -> URL? {
        assert(port > 0)
        var components = URLComponents()
        components.scheme = "http"
        components.host = host
        components.port = Int(port)
        return components.url
    }
}

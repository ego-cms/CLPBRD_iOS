import Foundation


extension URL {
    static func createWebSocketURL(with host: String, port: Int) -> URL? {
        assert(port > 0)
        var components = URLComponents()
        components.scheme = "ws"
        components.host = host
        components.port = port
        return components.url
    }
    
    static func createParametersURL(with host: String, port: Int = 8080) -> URL? {
        assert(port > 0)
        var components = URLComponents()
        components.scheme = "http"
        components.host = host
        components.port = port
        components.path = "/clipboard"
        return components.url
    }
}

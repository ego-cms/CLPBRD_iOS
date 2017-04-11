import Foundation
import GCDWebServer


class HTTPServer: NSObject, HTTPServerService {
    fileprivate let webServer = GCDWebServer()!
    var webSocketConfigurationJSON: [String : Any]? = nil
    
    var serverURL: URL? {
        return webServer.serverURL
    }
    
    var onRunningChanged: (Bool) -> Void = { _ in }
    
    fileprivate(set) var isRunning: Bool = false {
        didSet {
            onRunningChanged(isRunning)
        }
    }
    
    override init() {
        super.init()
        webServer.delegate = self
    }
    
    func startServer(port: UInt) {
        guard !webServer.isRunning else { return }
        let folderPath = Bundle.main.resourcePath?.appending("/www")
        webServer.addGETHandler(forBasePath: "/", directoryPath: folderPath, indexFilename: "index.html", cacheAge: 0, allowRangeRequests: true)
        
        webServer.addHandler(forMethod: "GET", path: "/clipboard", request: GCDWebServerRequest.self) { (request) -> GCDWebServerResponse? in
            let response = GCDWebServerDataResponse(jsonObject: self.webSocketConfigurationJSON ?? [:])
            return response
        }
        webServer.start(withPort: port, bonjourName: nil)
    }
    
    func stopServer() {
        if webServer.isRunning {
            webServer.stop()
        }
    }
}


extension HTTPServer: GCDWebServerDelegate {
    func webServerDidStart(_ server: GCDWebServer!) {
        isRunning = server.isRunning
    }
    
    func webServerDidStop(_ server: GCDWebServer!) {
        isRunning = server.isRunning
    }
    
    func webServerDidDisconnect(_ server: GCDWebServer!) {
        isRunning = server.isRunning
    }
}

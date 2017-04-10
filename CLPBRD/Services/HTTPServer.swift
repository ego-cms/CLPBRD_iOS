import Foundation
import GCDWebServer


class HTTPServer: HTTPServerService {
    private let webServer = GCDWebServer()!
    var websocketConfigurationJSON: [String : Any] = [:]
    
    var serverURL: URL? {
        return webServer.serverURL
    }
    
    func startServer(port: UInt) {
        let folderPath = Bundle.main.resourcePath?.appending("/www")
        webServer.addGETHandler(forBasePath: "/", directoryPath: folderPath, indexFilename: "index.html", cacheAge: 0, allowRangeRequests: true)
        
        webServer.addHandler(forMethod: "GET", path: "/clipboard", request: GCDWebServerRequest.self) { (request) -> GCDWebServerResponse? in
//            let json: [String: Any] = [
//                "port": 30000,
//                "text": "Blablabla",
//                "host": webServer?.serverURL.host ?? ""
//            ]
            let response = GCDWebServerDataResponse(jsonObject: self.websocketConfigurationJSON)
            return response
        }
        webServer.start(withPort: port, bonjourName: nil)
    }
    
    func stopServer() {
        webServer.stop()
    }
}

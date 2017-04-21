import Foundation
import Result
import SwiftyJSON


class PocketSocketClient: NSObject, WebSocketClientService {
    private(set) var url: URL?
    var webSocket: PSWebSocket?
    
    var onReceivedText: ((String) -> Void)?
    var onConnected: VoidClosure?
    var onDisconnected: ((Error?) -> Void)?
    
    fileprivate var initialText: String?
    
    func connect(host: String) {
        log.verbose("Connecting socket client to \(host)")
        if let ws = webSocket, ws.readyState == .open { return }
        requestHostParameters(host: host) { [weak self](result) in
            log.verbose("Got http /clipboard response from \(host): \(result)")
            switch result {
            case .success(let json):
                log.verbose("---- JSON: \(json)")
                guard let port = json["port"].int else {
                    call(closure: self?.onDisconnected, parameter: NSError.error(text: "Can't parse the port of server device \(host)"))
                    return
                }
                log.verbose("Received port: \(port)")
                self?.initialText = json["text"].string
                guard let webSocketURL = URL.createWebSocketURL(with: host, port: port) else {
                    call(closure: self?.onDisconnected, parameter: NSError.error(text: "Can't build websocket url"))
                    return
                }
                log.verbose("Websocket url: \(webSocketURL)")
                self?.url = webSocketURL
                let webSocketRequest = URLRequest(url: webSocketURL)
                self?.webSocket = PSWebSocket.clientSocket(with: webSocketRequest)
                self?.webSocket?.delegate = self
                self?.webSocket?.delegateQueue = DispatchQueue.main
                self?.webSocket?.open()
            case .failure(let error):
                log.verbose("---- Error: \(error)")
                call(closure: self?.onDisconnected, parameter: error)
            }
        }
        
    }
    
    private func requestHostParameters(host: String, completion: @escaping (Result<JSON, NSError>) -> Void) {
        guard let httpServerURL = URL.createParametersURL(with: host) else {
            let error = NSError.error(text: "Wrong host \(host)")
            completion(.failure(error))
            return
        }
        URLSession.shared.dataTask(with: httpServerURL) { (data, response, error) in
            if let error = error {
                completion(.failure(NSError.error(from: error)))
                return
            }
            guard let data = data else {
                completion(
                    .failure(
                        NSError.error(text: "Can't get port from clipboard JSON (\(String(describing: response?.url)))")
                    )
                )
                return
            }
            let json = JSON(data: data)
            completion(.success(json))
            }.resume()
    }
    
    func send(text: String) {
        log.verbose("Sending \(text)")
        webSocket?.send(text)
    }
    
    func disconnect() {
        log.verbose("Disconnecting")
        guard let ws = webSocket, ws.readyState != .closed else { return }
        webSocket?.close()
        webSocket = nil
        log.verbose("Socket closed")
    }
}


extension PocketSocketClient: PSWebSocketDelegate {
    func webSocketDidOpen(_ webSocket: PSWebSocket!) {
        log.verbose("PSWebSocketDelegate: Socket did open")
        onConnected?()
        if let initialText = self.initialText {
            onReceivedText?(initialText)
            self.initialText = nil
        }
    }
    
    func webSocket(_ webSocket: PSWebSocket!, didFailWithError error: Error!) {
        log.verbose("PSWebSocketDelegate: Socket did fail with error \(error)")
        onDisconnected?(error)
    }
    
    func webSocket(_ webSocket: PSWebSocket!, didReceiveMessage message: Any!) {
        log.verbose("PSWebSocketDelegate: Socket did receive message \(message)")
        guard let text = message as? String else { return }
        onReceivedText?(text)
    }
    
    func webSocket(_ webSocket: PSWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        log.verbose("PSWebSocketDelegate: Socket did close with code \(code), reason \(reason), was clean \(wasClean)")
    }
}

import Foundation
import SwiftWebSocket
import Result
import SwiftyJSON


class PocketSocketClient: NSObject, WebSocketClientService {
    private(set) var url: URL?
//    var host: String?
    var webSocket: PSWebSocket?
    
    var onReceivedText: (String) -> Void = { _ in }
    var onConnected: VoidClosure = {}
    var onDisconnected: (Error?) -> Void = { _ in }
    
    fileprivate var initialText: String?
    
    func connect(host: String) {
        if let ws = webSocket, ws.readyState == .open { return }
        requestHostParameters(host: host) { [weak self](result) in
            switch result {
            case .success(let json):
                guard let port = json["port"].int else {
                    call(closure: self?.onDisconnected, parameter: NSError.error(text: "Can't parse the port of server device \(host)"))
                    return
                }
                self?.initialText = json["text"].string
                guard let webSocketURL = URL.createWebSocketURL(with: host, port: port) else {
                    call(closure: self?.onDisconnected, parameter: NSError.error(text: "Can't build websocket url"))
                    return
                }
                self?.url = webSocketURL
                let webSocketRequest = URLRequest(url: webSocketURL)
                self?.webSocket = PSWebSocket.clientSocket(with: webSocketRequest)
                self?.webSocket?.delegate = self
                self?.webSocket?.delegateQueue = DispatchQueue.main
                self?.webSocket?.open()
            case .failure(let error):
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
        webSocket?.send(text)
    }
    
    func disconnect() {
        guard let ws = webSocket, ws.readyState != .closed else { return }
        webSocket?.close()
        webSocket = nil
    }
}


extension PocketSocketClient: PSWebSocketDelegate {
    func webSocketDidOpen(_ webSocket: PSWebSocket!) {
        onConnected()
//        host = webSocket.//webSocket?.url
        if let initialText = self.initialText {
            onReceivedText(initialText)
            self.initialText = nil
        }
    }
    
    func webSocket(_ webSocket: PSWebSocket!, didFailWithError error: Error!) {
//        host = nil
        onDisconnected(error)
    }
    
    func webSocket(_ webSocket: PSWebSocket!, didReceiveMessage message: Any!) {
        guard let text = message as? String else { return }
        onReceivedText(text)
    }
    
    func webSocket(_ webSocket: PSWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        
    }
}


/*
extension WebSocketClient: WebSocketDelegate {
    func webSocketOpen() {

    }
    
    func webSocketClose(_ code: Int, reason: String, wasClean: Bool) {}
    func webSocketError(_ error: NSError) {}
    
    func webSocketMessageText(_ text: String) {
 
    }
    
    func webSocketEnd(_ code: Int, reason: String, wasClean: Bool, error: NSError?) {

    }
}

*/

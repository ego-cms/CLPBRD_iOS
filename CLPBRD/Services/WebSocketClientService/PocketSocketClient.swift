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
        print("Connecting socket client to \(host)")
        if let ws = webSocket, ws.readyState == .open { return }
        requestHostParameters(host: host) { [weak self](result) in
            print("Got http /clipboard response from \(host): \(result)")
            switch result {
            case .success(let json):
                print("---- JSON: \(json)")
                guard let port = json["port"].uInt else {
                    call(closure: self?.onDisconnected, parameter: NSError.error(text: "Can't parse the port of server device \(host)"))
                    return
                }
                print("Received port: \(port)")
                self?.initialText = json["text"].string
                guard let webSocketURL = URL.createWebSocketURL(with: host, port: port) else {
                    call(closure: self?.onDisconnected, parameter: NSError.error(text: "Can't build websocket url"))
                    return
                }
                print("Websocket url: \(webSocketURL)")
                self?.url = webSocketURL
                let webSocketRequest = URLRequest(url: webSocketURL)
                self?.webSocket = PSWebSocket.clientSocket(with: webSocketRequest)
                self?.webSocket?.delegate = self
                self?.webSocket?.delegateQueue = DispatchQueue.main
                self?.webSocket?.open()
            case .failure(let error):
                print("---- Error: \(error)")
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
        print("Sending \(text)")
        webSocket?.send(text)
    }
    
    func disconnect() {
        print("Disconnecting")
        guard let ws = webSocket, ws.readyState != .closed else { return }
        webSocket?.close()
        webSocket = nil
        print("Socket closed")
    }
}


extension PocketSocketClient: PSWebSocketDelegate {
    func webSocketDidOpen(_ webSocket: PSWebSocket!) {
        print("PSWebSocketDelegate: Socket did open")
        onConnected?()
        if let initialText = self.initialText {
            onReceivedText?(initialText)
            self.initialText = nil
        }
    }
    
    func webSocket(_ webSocket: PSWebSocket!, didFailWithError error: Error!) {
        print("PSWebSocketDelegate: Socket did fail with error \(error)")
        onDisconnected?(error)
    }
    
    func webSocket(_ webSocket: PSWebSocket!, didReceiveMessage message: Any!) {
        print("PSWebSocketDelegate: Socket did receive message \(message)")
        guard let text = message as? String else { return }
        onReceivedText?(text)
    }
    
    func webSocket(_ webSocket: PSWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        print("PSWebSocketDelegate: Socket did close with code \(code), reason \(reason), was clean \(wasClean)")
    }
}

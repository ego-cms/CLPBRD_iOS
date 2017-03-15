//
//  SocketClient.swift
//  CLPBRD
//
//  Created by Александр Долоз on 15.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import Foundation
import Result
import Starscream


class SocketClient: SocketClientService {
    private(set) var url: URL?
    private var webSocket: WebSocket?
    
    var onReceivedText: (String) -> Void = { _ in }
    var onConnected: VoidClosure = {}
    var onDisconnected: (Error?) -> Void = { _ in }
    
    
    
    func connect(host: String) {
        if let ws = webSocket, ws.isConnected { return }
        requestPort(from: host) { [weak self](result) in
            switch result {
            case .success(let port):
                guard let webSocketURL = URL.createWebSocketURL(with: host, port: port) else {
                    call(closure: self?.onDisconnected, parameter: NSError.error(text: "Can't build websocket url"))
                    return
                }
                self?.webSocket = WebSocket(url: webSocketURL)
                self?.webSocket?.delegate = self
                self?.webSocket?.callbackQueue = .main
                self?.webSocket?.connect()
            case .failure(let error):
                call(closure: self?.onDisconnected, parameter: error)
            }
        }
    }
    
    private func requestPort(from host: String, completion: @escaping (Result<Int, NSError>) -> Void) {
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
            guard
                let data = data,
                let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
                let port = json["port"] as? Int
            else {
                completion(
                    .failure(
                        NSError.error(text: "Can't get port from clipboard JSON (\(response?.url))")
                    )
                )
                return
            }
            completion(.success(port))
        }
    }
    
    func send(text: String) {
        webSocket?.write(string: text)
    }
    
    func disconnect() {
        guard let ws = webSocket, !ws.isConnected else { return }
        webSocket?.disconnect()
        webSocket = nil
    }
}


extension SocketClient: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocket) {
        onConnected()
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        onDisconnected(error)
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        onReceivedText(text)
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("Received data from \(socket.currentURL), it will be discarded – we accept only text")
    }
}

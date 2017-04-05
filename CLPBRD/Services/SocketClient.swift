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
import SwiftyJSON


class SocketClient: SocketClientService {
    private(set) var url: URL?
    var host: String?
    private var webSocket: WebSocket?
    
    var onReceivedText: (String) -> Void = { _ in }
    var onConnected: VoidClosure = {}
    var onDisconnected: (Error?) -> Void = { _ in }
    
    fileprivate var initialText: String?
    
    func connect(host: String) {
        if let ws = webSocket, ws.isConnected { return }
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
                self?.webSocket = WebSocket(url: webSocketURL)
                self?.webSocket?.delegate = self
                self?.webSocket?.callbackQueue = .main
                self?.webSocket?.connect()
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
        host = socket.currentURL.host
        if let initialText = self.initialText {
            onReceivedText(initialText)
            self.initialText = nil
        }
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        host = nil
        onDisconnected(error)
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        onReceivedText(text)
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("Received data from \(socket.currentURL), it will be discarded – we accept only text")
    }
}

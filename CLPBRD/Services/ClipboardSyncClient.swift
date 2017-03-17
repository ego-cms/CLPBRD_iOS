//
//  ClipboardSyncClient.swift
//  CLPBRD
//
//  Created by Александр Долоз on 16.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import Foundation


final class ClipboardSyncClient: ClipboardSyncClientService {
    var clipboardProviderService: ClipboardProviderService
    var socketClientService: SocketClientService
    init(clipboardProviderService: ClipboardProviderService, socketClientService: SocketClientService) {
        self.clipboardProviderService = clipboardProviderService
        self.socketClientService = socketClientService
        socketClientService.onConnected = { [unowned self] in
            self.socketCliendServiceConnected()
        }
        
        socketClientService.onDisconnected = { [unowned self](error) in
            self.onDisconnected(error)
        }
        
        socketClientService.onReceivedText = { [unowned self](text) in
            self.received(text: text)
        }
        
        clipboardProviderService.onContentChanged = { [unowned self] in
            self.clipboardContentChanged()
        }
    }
    
    var onDisconnected: (Error?) -> Void = { _ in }
    
    private var host: String = ""
    private var lastReceivedText = ""
    
    private func socketCliendServiceConnected() {
        print("Connected to \(host)")
    }
        
    private func received(text: String) {
        guard clipboardProviderService.content != text else {
            return
        }
        lastReceivedText = text
        print("\(text) <- \(host)")
        clipboardProviderService.content = text
    }
    
    private func clipboardContentChanged() {
        guard let content = clipboardProviderService.content,
            lastReceivedText != content else {
            return
        }
        print("\(content) -> \(host)")
        socketClientService.send(text: content)
    }
    
    func connect(host: String) {
        socketClientService.connect(host: host)
        self.host = host
    }
}

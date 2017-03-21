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
    var appStateService: AppStateService
    var onDisconnected: (Error?) -> Void = { _ in }
    
    init(clipboardProviderService: ClipboardProviderService, socketClientService: SocketClientService, appStateService: AppStateService) {
        self.clipboardProviderService = clipboardProviderService
        self.socketClientService = socketClientService
        self.appStateService = appStateService
        socketClientService.onConnected = { [unowned self] in
            self.socketClientServiceConnected()
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
        appStateService.onAppEnterForeground = { [unowned self] in
            self.appEnteredForeground()
        }
        self.changeCount = clipboardProviderService.changeCount
    }
    
    private var host: String?
    private var lastReceivedText: String?
    private var changeCount = 0
    
    private func socketClientServiceConnected() {
        print("Connected to \(host!)")
        if changeCount != clipboardProviderService.changeCount {
            clipboardContentChanged()
        }
    }
        
    private func received(text: String) {
        guard clipboardProviderService.content != text else {
            return
        }
        lastReceivedText = text
      //  print("\(text) <- \(host!)")
        clipboardProviderService.content = text
    }
    
    private func clipboardContentChanged() {
        guard
            let content = clipboardProviderService.content,
            lastReceivedText != content
        else {
            return
        }
       // print("\(content) -> \(host!)")
        changeCount = clipboardProviderService.changeCount
        socketClientService.send(text: content)
    }
    
    private func appEnteredForeground() {
        if let host = self.host {
            connect(host: host)
        }
    }
    
    func connect(host: String) {
        socketClientService.connect(host: host)
        self.host = host
    }
    
    func disconnect() {
        self.host = nil
        self.lastReceivedText = nil
        socketClientService.disconnect()
    }
}

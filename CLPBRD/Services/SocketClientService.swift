//
//  SocketClientService.swift
//  CLPBRD
//
//  Created by Александр Долоз on 15.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import Foundation
import Result


protocol SocketClientService: class {
    var onDisconnected: (Error?) -> Void { get set }
    var onConnected: VoidClosure { get set }
    var onReceivedText: (String) -> Void { get set }
    
    var url: URL? { get }
    
    // should be idempotent
    func connect(host: String)
    func send(text: String)
    
    // should be idempotent
    func disconnect()
}


//
//  ClipboardSyncClientService.swift
//  CLPBRD
//
//  Created by Александр Долоз on 16.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import Foundation


protocol ClipboardSyncClientService: class {
    var clipboardProviderService: ClipboardProviderService { get set }
    var socketClientService: SocketClientService { get set }
    init(clipboardProviderService: ClipboardProviderService, socketClientService: SocketClientService)
    
    var onDisconnected: (Error?) -> Void { get set }
    func connect(host: String) 
}

//
//  ClipboardProvider.swift
//  CLPBRD
//
//  Created by Александр Долоз on 16.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit


class ClipboardProvider: NSObject, ClipboardProviderService {
    private let pasteboard = UIPasteboard.general
    
    var content: String? {
        get {
            return pasteboard.string
        }
        
        set {
            pasteboard.string = newValue
        }
    }
    
    var changeCount: Int {
        return pasteboard.changeCount
    }
    
    var onContentChanged: VoidClosure = { }
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(contentChanged), name: Notification.Name.UIPasteboardChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(contentChanged), name: Notification.Name.UIPasteboardRemoved, object: nil)
    }
    
    func contentChanged() {
        onContentChanged()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

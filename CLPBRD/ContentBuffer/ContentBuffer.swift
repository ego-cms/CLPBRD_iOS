//
//  ContentBuffer.swift
//  CLPBRD
//
//  Created by Александр Долоз on 20.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import Foundation


class ContentBuffer: NSObject {
    static let changeNotificationName = Notification.Name(rawValue: "content_buffer_did_change")
    
    var content: String? {
        didSet {
            NotificationCenter.default.post(name: ContentBuffer.changeNotificationName, object: self)
        }
    }
    
    func send(to buffer: ContentBuffer) {
        buffer.content = self.content
    }
}

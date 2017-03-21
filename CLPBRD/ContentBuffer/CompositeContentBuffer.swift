//
//  CompositeContentBuffer.swift
//  CLPBRD
//
//  Created by Александр Долоз on 20.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import Foundation


class CompositeContentBuffer: ContentBuffer {
    private(set) var buffers: [ContentBuffer]
    private var shouldUpdateChildren = true

    override var content: String? {
        didSet {
            if shouldUpdateChildren {
                buffers.forEach { $0.content = content }
            }
            NotificationCenter.default.post(name: ContentBuffer.changeNotificationName, object: self)
        }
    }
    
    init(buffers: [ContentBuffer]) {
        self.buffers = buffers
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(childBuffersChanged(_:)), name: ContentBuffer.changeNotificationName, object: nil)
        performWithoutUpdatingChildren {
            self.content = buffers.last?.content
        }
    }
    
    private func performWithoutUpdatingChildren(closure: VoidClosure) {
        shouldUpdateChildren = false
        closure()
        shouldUpdateChildren = true
    }
    
    func childBuffersChanged(_ notification: Notification) {
        guard
            let buffer = notification.object as? ContentBuffer,
            self.content != buffer.content
        else {
            return
        }
        performWithoutUpdatingChildren {
            self.content = buffer.content
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

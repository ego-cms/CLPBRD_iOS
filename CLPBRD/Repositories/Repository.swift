//
//  Repo.swift
//  CLPBRD
//
//  Created by Александр Долоз on 16.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import Foundation


let repositoryUpdateNotificationName = Notification.Name(rawValue: "REPOSITORY_UPDATE_NOTIFICATION")


class Repository<X> {
    var limit: Int {
        didSet {
            assert(limit >= 1, "Limit must be >= 1")
            items = Array(items.suffix(limit))
        }
    }
    
    private(set) var items: [X] {
        didSet {
            NotificationCenter.default.post(name: repositoryUpdateNotificationName, object: self)
        }
    }
    
    var preprocessor: (X) -> X? = { $0 }
    
    init(limit: Int = 1) {
        assert(limit >= 1, "Limit must be >= 1")
        self.limit = limit
        self.items = []
    }
    
    func push(item: X) {
        guard let preprocessedItem = preprocessor(item) else { return }
        items = Array((items + [preprocessedItem]).suffix(limit))
    }

    func clean() {
        items = []
    }
    
    var last: X? {
        return items.last
    }
}

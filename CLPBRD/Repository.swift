//
//  Repo.swift
//  CLPBRD
//
//  Created by Александр Долоз on 16.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import Foundation


class Repository<X> {
    var limit: Int {
        didSet {
            assert(limit >= 1, "Limit must be >= 1")
            items = Array(items.suffix(limit))
        }
    }
    
    private(set) var items: [X]
    
    init(limit: Int = 1) {
        assert(limit >= 1, "Limit must be >= 1")
        self.limit = limit
        self.items = []
    }
    
    func push(item: X) {
        items.append(item)
        items = Array((items + [item]).suffix(limit))
    }
}

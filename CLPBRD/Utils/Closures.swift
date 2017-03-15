//
//  Closures.swift
//  CLPBRD
//
//  Created by Александр Долоз on 15.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import Foundation


func call<T>(closure: ((T) -> Void)?, parameter: T, on queue: DispatchQueue = .main) {
    guard let closure = closure else {
        return
    }
    queue.async {
        closure(parameter)
    }
}

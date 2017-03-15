//
//  NSError+Errors.swift
//  CLPBRD
//
//  Created by Александр Долоз on 15.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import Foundation


let clpbrdErrorDomain = "CLPBRD Error"


extension NSError {
    static func error(text: String) -> NSError {
        return NSError(domain: clpbrdErrorDomain, code: 1, userInfo: [
            NSLocalizedDescriptionKey: text
        ])
    }
}

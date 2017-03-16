//
//  ClipboardProviderService.swift
//  CLPBRD
//
//  Created by Александр Долоз on 16.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import Foundation


protocol ClipboardProviderService: class {
    var content: String? { get set }
    var onContentChanged: VoidClosure { get set }
}

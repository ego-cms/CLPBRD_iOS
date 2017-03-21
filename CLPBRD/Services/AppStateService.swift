//
//  AppStateService.swift
//  CLPBRD
//
//  Created by Александр Долоз on 17.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import Foundation

//
protocol AppStateService: class {
    var onAppEnterForeground: VoidClosure { get set }
}



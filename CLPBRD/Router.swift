//
//  Router.swift
//  CLPBRD
//
//  Created by Александр Долоз on 16.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit

class Route<VC1: UIViewController, VC2: UIViewController> {
    let routingClosure:  (VC1, VC2) -> Void
    init(routingClosure: @escaping (VC1, VC2) -> Void) {
        self.routingClosure = routingClosure
    }
}

class Router {
    
}

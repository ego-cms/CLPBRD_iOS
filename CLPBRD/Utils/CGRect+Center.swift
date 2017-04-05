//
//  CGRect+Center.swift
//  CLPBRD
//
//  Created by Александр Долоз on 05.04.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit


extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

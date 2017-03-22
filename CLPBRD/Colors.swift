//
//  Colors.swift
//  CLPBRD
//
//  Created by Александр Долоз on 22.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit


enum Colors {
    case scanQRButtonNormal
    case scanQRButtonHighlighted
    
    var color: UIColor {
        switch self {
        case .scanQRButtonNormal: return UIColor(hex: "e2b428")
        case .scanQRButtonHighlighted: return UIColor(hex: "ab881e")
        }
    }
}

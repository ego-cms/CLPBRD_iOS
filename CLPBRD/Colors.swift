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
    case toggleButtonOnNormal
    case toggleButtonOnHighlighted
    case toggleButtonOffNormal
    case toggleButtonOffHighlighted
    case buttonGroupExpanded
    case buttonGroupCollapsed
    
    var color: UIColor {
        switch self {
        case .scanQRButtonNormal: return UIColor(hex: "e2b428")
        case .scanQRButtonHighlighted: return UIColor(hex: "ab881e")
        case .toggleButtonOffNormal: return UIColor(hex: "4fc80d")
        case .toggleButtonOffHighlighted: return UIColor(hex: "388f09")
        case .toggleButtonOnNormal: return UIColor(hex: "c8280d")
        case .toggleButtonOnHighlighted: return UIColor(hex: "8f1d09")
        case .buttonGroupExpanded: return Colors.toggleButtonOffNormal.color.withAlphaComponent(0.24)
        case .buttonGroupCollapsed: return Colors.toggleButtonOnNormal.color.withAlphaComponent(0.24)
        }
    }
}

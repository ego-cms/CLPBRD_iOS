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
    case toggleButtonGotUpdatesNormal
    case toggleButtonGotUpdatesHighlighted
    case buttonGroupExpanded
    case buttonGroupCollapsed
    case buttonGroupGotUpdates
    
    var color: UIColor {
        switch self {
        case .scanQRButtonNormal: return UIColor(hex: "e2b428")
        case .scanQRButtonHighlighted: return UIColor(hex: "ab881e")
        case .toggleButtonOffNormal: return UIColor(hex: "4fc80d")
        case .toggleButtonOffHighlighted: return UIColor(hex: "388f09")
        case .toggleButtonOnNormal: return UIColor(hex: "c8280d")
        case .toggleButtonOnHighlighted: return UIColor(hex: "8f1d09")
        case .toggleButtonGotUpdatesNormal: return #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            
        case .toggleButtonGotUpdatesHighlighted: return #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
            
        case .buttonGroupExpanded: return Colors.toggleButtonOffNormal.color.withAlphaComponent(0.24)
        case .buttonGroupCollapsed: return Colors.toggleButtonOnNormal.color.withAlphaComponent(0.24)
        case .buttonGroupGotUpdates: return Colors.toggleButtonGotUpdatesNormal.color.withAlphaComponent(0.24)
        }
    }
}

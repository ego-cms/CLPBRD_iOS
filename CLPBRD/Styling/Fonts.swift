import UIKit


enum Fonts {
    
    case button
    case regular
//    case text
    case serverURL
    
    var font: UIFont {
        switch self {
        case .serverURL: return UIFont(name: "Ubuntu", size: 24.0)!
        case .button: return UIFont(name: "Raleway-ExtraBold", size: 40.0)!
        case .regular: return UIFont(name: "Ubuntu", size: 14.0)!
        }
    }
    
}

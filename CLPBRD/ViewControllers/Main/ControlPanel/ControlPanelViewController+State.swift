import UIKit


extension ControlPanelViewController {
    enum State {
        case off
        case clientOn
        case clientGotUpdates
        case serverOn
        case serverGotUpdates
        
        var gotUpdates: Bool {
            return self == .clientGotUpdates || self == .serverGotUpdates
        }
        
        var isOff: Bool {
            return self == .off
        }
        
        var isOn: Bool {
            return self == .clientOn || self == .serverOn
        }
        
        var isClient: Bool {
            return self == .clientOn || self == .clientGotUpdates
        }
        
        var isServer: Bool {
            return self == .serverOn || self == .serverGotUpdates
        }
        
        var buttonBackgroundViewState: ButtonBackgroundView.State {
            switch self {
            case .off: return .expanded
            case let x where x.gotUpdates: return .active
            default: return .collapsed
            }
        }
    }
}



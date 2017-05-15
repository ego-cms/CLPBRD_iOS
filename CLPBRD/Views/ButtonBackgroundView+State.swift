import UIKit


extension ButtonBackgroundView {
    enum State {
        case expanded
        case collapsed
        case active
        
        static let expandedOriginalPath: UIBezierPath = loadAndTranslatePath(fileName: "buttons_expanded")
        static let collapsedOriginalPath: UIBezierPath = loadAndTranslatePath(fileName: "buttons_collapsed")
        
        static var expandedPath: UIBezierPath = State.expandedOriginalPath
        static var collapsedPath: UIBezierPath = State.collapsedOriginalPath
        
        var path: UIBezierPath {
            switch self {
            case .expanded: return State.expandedPath
            case .collapsed, .active: return State.collapsedPath
            }
        }
        
        var color: UIColor {
            switch self {
            case .expanded: return Colors.buttonGroupExpanded.color
            case .collapsed: return Colors.buttonGroupCollapsed.color
            case .active: return Colors.buttonGroupGotUpdates.color
            }
        }
        
        func frame(forHeightInExpandedState height: CGFloat, topRightCorner corner: CGPoint) -> CGRect {
            let size = self.size(forHeightInExpandedState: height)
            let origin = CGPoint(x: corner.x - size.width, y: corner.y)
            return CGRect(origin: origin, size: size)
        }
        
        func size(forHeightInExpandedState height: CGFloat) -> CGSize {
            let originalExpandedSize = State.expanded.path.bounds.size
            let originalSizeForState = self.path.bounds.size
            let ratio = height / originalExpandedSize.height
            return CGSize(width: ratio * originalSizeForState.width, height: ratio * originalSizeForState.height)
        }
    }
}

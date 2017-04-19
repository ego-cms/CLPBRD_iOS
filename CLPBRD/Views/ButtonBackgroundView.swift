//
//  ButtonBackgroundView.swift
//  CLPBRD
//
//  Created by Александр Долоз on 18.04.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit


class ButtonBackgroundView: UIView {
    var animationDuration = 0.25
    
    
    private var shapeLayer = CAShapeLayer()
    private(set) var state: State = .expanded
    
    var heightInExpandedState: CGFloat = 240.0 {
        didSet {
            preparePaths()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func preparePaths() {
        print("Expanded original ", State.expandedOriginalPath.bounds)
        print("Collapsed original ", State.collapsedOriginalPath.bounds)
        let translatedCollapsedPath = UIBezierPath(cgPath: State.collapsedOriginalPath.cgPath)//
        let dx = State.expandedOriginalPath.bounds.width - State.collapsedOriginalPath.bounds.width
        translatedCollapsedPath.apply(CGAffineTransform(translationX: dx, y: 0.0))
        print("Translated collapsed ", translatedCollapsedPath.bounds)
        State.expandedPath = State.expandedOriginalPath
        State.collapsedPath = translatedCollapsedPath
        let ratio: CGFloat =  heightInExpandedState / State.expandedOriginalPath.bounds.height
        shapeLayer.transform = CATransform3DMakeScale(ratio, ratio, 1.0)
        let originalExpandedSize = State.expandedOriginalPath.bounds.size
        shapeLayer.frame.size = CGSize(width: originalExpandedSize.width * ratio, height: originalExpandedSize.height * ratio)
        shapeLayer.anchorPoint = CGPoint(x: 1.0, y: 0.0)
        shapeLayer.position = CGPoint(x: bounds.maxX, y: bounds.minX)
        shapeLayer.contentsGravity = kCAGravityTopRight
        log.verbose("In prepare paths")
        log.verbose("shape layer: \(shapeLayer.bounds), \(shapeLayer.anchorPoint), \(shapeLayer.position)")
        log.verbose("height in expanded state: \(heightInExpandedState), ratio: \(ratio)")
    }
    
    func commonInit() {
//        State.alignPaths()
        layer.addSublayer(shapeLayer)
//        shapeLayer.backgroundColor = UIColor.purple.withAlphaComponent(0.25).cgColor
//        backgroundColor = UIColor.cyan.withAlphaComponent(0.25)
        backgroundColor = .clear
        updateShapeLayer()
        log.verbose("In common init: state \(state), fill color \(String(describing: shapeLayer.fillColor)), path \(String(describing: shapeLayer.path))")
        preparePaths()
    }
    
    func updateShapeLayer() {
        CATransaction.begin()
        CATransaction.disableActions()
        shapeLayer.fillColor = state.color.cgColor
        let path = state.path.cgPath
        shapeLayer.path = path
        log.verbose("Updating shape layer")
        CATransaction.commit()
    }
    
    func changeState(to newState: State, animated: Bool = true) {
        log.verbose("Changing state from \(state) to \(newState)")
        log.verbose("view: \(self.frame), shape layer: \(shapeLayer.frame)")
        if newState == .active {
            let otherLayer = CAShapeLayer()
//            otherLayer.backgroundColor = UIColor.red.cgColor
            otherLayer.path = State.collapsedOriginalPath.cgPath
//            let radiusRatio = State.collapsedPath.bounds
            otherLayer.fillColor = State.active.color.cgColor
            let ratio: CGFloat =  heightInExpandedState / State.expandedOriginalPath.bounds.height
            CATransaction.begin()
            CATransaction.disableActions()
            otherLayer.transform = shapeLayer.transform// CATransform3DMakeScale(ratio, ratio, 1.0)
            let side = ratio * State.collapsedOriginalPath.bounds.height
            otherLayer.frame.size = CGSize(width: side, height: side)
            otherLayer.anchorPoint = CGPoint(x: 1.0, y: 0.0)
            otherLayer.position = shapeLayer.position
            let oldFrame = otherLayer.frame
            otherLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            otherLayer.frame = oldFrame
            //otherLayer.frame = shapeLayer.frame// shapeLayer.path!.boundingBox// .frame
            //otherLayer.anchorPoint = CGPoint(x: 0.55, y: 0.5) //shapeLayer.anchorPoint//  CGPoint(x: 0.25, y: 0.25)
            CATransaction.commit()
            layer.addSublayer(otherLayer)
            let expandAnimation = CABasicAnimation(keyPath: "transform")
            let fadeAnimation = CABasicAnimation(keyPath: "opacity")
            let duration = 1.0
            
            expandAnimation.duration = duration
            let scale: CGFloat = 1.1
            expandAnimation.toValue = CATransform3DMakeScale(scale, scale, 1.0)
            fadeAnimation.duration = duration
            fadeAnimation.toValue = 0.0
//            otherLayer.transform = CATransform3DMakeScale(scale, scale, 1.0)
//            otherLayer.opacity = 0.0
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                otherLayer.removeFromSuperlayer()
            }
            otherLayer.add(expandAnimation, forKey: nil)
            otherLayer.add(fadeAnimation, forKey: nil)
            CATransaction.commit()
        }
        guard newState != state else { return }
        let newColor = newState.color.cgColor
        let newPath = newState.path.cgPath
        let morphing = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
        let recolor = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.fillColor))
        shapeLayer.path = newPath
        shapeLayer.fillColor = newColor

        morphing.duration = animationDuration
        recolor.duration = animationDuration

        CATransaction.begin()
        CATransaction.setCompletionBlock { 
        }
        shapeLayer.add(morphing, forKey: nil)
        shapeLayer.add(recolor, forKey: nil)
        CATransaction.commit()
        state = newState
    }
}


extension ButtonBackgroundView {
    enum State {
        case expanded
        case collapsed
        case active
        
        static let expandedOriginalPath: UIBezierPath = loadAndTranslatePath(fileName: "buttons_expanded")
        static let collapsedOriginalPath: UIBezierPath = loadAndTranslatePath(fileName: "buttons_collapsed")
        
        static var expandedPath: UIBezierPath = State.expandedOriginalPath
        static var collapsedPath: UIBezierPath = State.collapsedOriginalPath
        
//        static func alignPaths() {
//            let dx = expandedPath.bounds.width - collapsedPath.bounds.width
//            let translation = CGAffineTransform(translationX: dx, y: 0)
//            collapsedPath.apply(translation)
//        }
        
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

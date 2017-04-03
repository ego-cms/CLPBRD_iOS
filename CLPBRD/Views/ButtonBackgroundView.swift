//
//  ButtonBackgroundView.swift
//  CLPBRD
//
//  Created by Александр Долоз on 03.04.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit

class ButtonBackgroundView: UIView {
    private var backgroundLayer = CAShapeLayer()
    private static var animationDuration: TimeInterval = 6.0
    
    private(set) var state: State = .expanded
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        layer.addSublayer(backgroundLayer)
        updateState(to: .expanded, animated: false)
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        let transform = State.expandedPath.scale(toFit: bounds.size)
        State.expandedPath.apply(transform)
        State.collapsedPath.apply(transform)
    }
    
    
    func updateState(to newState: State, animated: Bool = true) {
        defer {
            self.backgroundLayer.path = newState.path.cgPath
            self.backgroundLayer.fillColor = newState.color.cgColor
        }
        
        guard newState != self.state else {
            return
        }
        
        guard animated else {
            return
        }
        
        let morphing = CABasicAnimation(keyPath: "path")
        morphing.fromValue = state.path.cgPath
        morphing.toValue = newState.path.cgPath
        let changeColor = CABasicAnimation(keyPath: "fillColor")
        changeColor.fromValue = state.color.cgColor
        changeColor.toValue = newState.color.cgColor
        let group = CAAnimationGroup()
        group.duration = ButtonBackgroundView.animationDuration
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        group.animations = [morphing, changeColor]
        backgroundLayer.add(group, forKey: "state_animation")
    }
}


extension ButtonBackgroundView {
    
    enum State {
        fileprivate static var expandedPath = loadSVG(from: "buttons_expanded")
        fileprivate static var collapsedPath = loadSVG(from: "buttons_collapsed")
        
        case expanded
        case collapsed
        
        var path: UIBezierPath {
            switch self {
            case .expanded: return State.expandedPath
            case .collapsed: return State.collapsedPath
            }
        }
        
        var color: UIColor {
            switch self {
            case .expanded: return Colors.buttonGroupExpanded.color
            case .collapsed: return Colors.buttonGroupCollapsed.color
            }
        }
    }
    
}

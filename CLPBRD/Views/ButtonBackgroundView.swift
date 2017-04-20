//
//  ButtonBackgroundView.swift
//  CLPBRD
//
//  Created by Александр Долоз on 18.04.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit


class ButtonBackgroundView: UIView {
    var animationDuration = 0.2
    
    
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
    
    func showCoolAnimation() {
        let otherLayer = CAShapeLayer()
        otherLayer.path = State.collapsedOriginalPath.cgPath
        otherLayer.fillColor = State.active.color.cgColor
        let ratio: CGFloat =  heightInExpandedState / State.expandedOriginalPath.bounds.height
        CATransaction.begin()
        CATransaction.disableActions()
        otherLayer.transform = shapeLayer.transform
        let side = ratio * State.collapsedOriginalPath.bounds.height
        otherLayer.frame.size = CGSize(width: side, height: side)
        otherLayer.anchorPoint = CGPoint(x: 1.0, y: 0.0)
        otherLayer.position = shapeLayer.position
        let oldFrame = otherLayer.frame
        otherLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        otherLayer.frame = oldFrame
        CATransaction.commit()
        layer.addSublayer(otherLayer)
        let expandAnimation = CABasicAnimation(keyPath: "transform")
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        let duration = 1.0
        
        expandAnimation.duration = duration
        expandAnimation.isRemovedOnCompletion = false
        let scale: CGFloat = 1.1
        expandAnimation.toValue = CATransform3DMakeScale(scale, scale, 1.0)
        fadeAnimation.duration = duration
        fadeAnimation.toValue = 0.0
        fadeAnimation.isRemovedOnCompletion = false
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            otherLayer.removeFromSuperlayer()
        }
        otherLayer.add(expandAnimation, forKey: nil)
        otherLayer.add(fadeAnimation, forKey: nil)
        CATransaction.commit()
    }
    
    func changeState(to newState: State, animated: Bool = true) {
        log.verbose("Changing state from \(state) to \(newState)")
        log.verbose("view: \(self.frame), shape layer: \(shapeLayer.frame)")
        if newState == .active {
            showCoolAnimation()
        }
        guard newState != state else { return }
        let newColor = newState.color.cgColor
        let newPath = newState.path.cgPath
        let morphing = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
        let recolor = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.fillColor))
        

        morphing.duration = animationDuration
        morphing.fromValue = shapeLayer.path
        morphing.toValue = newPath
        recolor.duration = animationDuration
        recolor.fromValue = shapeLayer.fillColor
        recolor.toValue = newColor
        CATransaction.begin()
        CATransaction.setAnimationDuration(animationDuration)
        shapeLayer.add(morphing, forKey: nil)
        shapeLayer.add(recolor, forKey: nil)
        shapeLayer.path = newPath
        shapeLayer.fillColor = newColor
        CATransaction.commit()
        state = newState
    }
}


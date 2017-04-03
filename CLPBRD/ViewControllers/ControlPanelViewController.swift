//
//  ControlPanelViewController.swift
//  CLPBRD
//
//  Created by Александр Долоз on 03.04.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit


protocol ControlPanelViewControllerDelegate: class {
    func controlPanelViewController(_ cpVC: ControlPanelViewController, didChangeStateFrom: ControlPanelViewController.State, to: ControlPanelViewController.State)
    func controlPanelViewControllerDidPressOnButton(_ cpVC: ControlPanelViewController)
    func controlPanelViewControllerDidPressQRScanButton(_ cpVC: ControlPanelViewController)
    func controlPanelViewControllerDidPressOffButton(_ cpVC: ControlPanelViewController)
    func controlPanelViewControllerDidPressReceiveButton(_ cpVC: ControlPanelViewController)
}


class ControlPanelViewController: UIViewController {
    var expandedPath = loadSVG(from: "buttons_expanded")
    var collapsedPath = loadSVG(from: "buttons_collapsed")
    var inset: CGFloat = 16.0
    var smallCircleRatio: CGFloat = 0.256 // ratio of small circle radius of shape to width of shape
    var bigCircleRatio: CGFloat = 0.45 // ratio of big circle radius of shape to width of shape
    var shapeRatio: CGFloat = 0.806 // width / height
    var buttonRatio: CGFloat = 0.75 // radius of buttons / radius of shape
    var animationDuration = 0.5
    
    private(set) var state: State = .off
    
    @IBOutlet weak var toggleButton: RoundButton!
    @IBOutlet weak var scanQRButton: RoundButton!
    var buttonBackgroundLayer = CAShapeLayer()
    
    weak var delegate: ControlPanelViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonBackgroundLayer.anchorPoint = CGPoint.zero
        scanQRButton.highlightColor = Colors.scanQRButtonHighlighted.color
        scanQRButton.normalColor = Colors.scanQRButtonNormal.color
        toggleButton.highlightColor = Colors.toggleButtonOffHighlighted.color
        toggleButton.normalColor = Colors.toggleButtonOffNormal.color
        view.layer.addSublayer(buttonBackgroundLayer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resizePaths()
        updateState(to: .off, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizePaths()
        updateState(to: self.state, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resizePaths()
    }
    
    @IBAction func toggleButtonPressed(_ sender: Any) {
        if state == .off {
            updateState(to: .on)
        } else {
            updateState(to: .off)
        }
    }

    func toggleButtonFrame(for state: State) -> CGRect {
        let layerFrame = buttonBackgroundLayerFrame(for: state)
        let bigRadius = layerFrame.width * bigCircleRatio
        return CGRect(center: CGPoint(x: layerFrame.maxX - bigRadius, y: bigRadius + inset), radius: buttonRatio * bigRadius)
    }
    
    func qrButtonFrame(for state: State) -> CGRect {
        switch state {
        case .off:
            let layerFrame = buttonBackgroundLayerFrame(for: state)
            let smallRadius = layerFrame.width * smallCircleRatio
            return CGRect(center: CGPoint(x: view.center.x, y: layerFrame.maxY - smallRadius), radius: buttonRatio * smallRadius)
        default:
            let oldToggleButtonFrame = toggleButtonFrame(for: .off)
            let frame = CGRect(center: CGPoint(x: oldToggleButtonFrame.midX, y: oldToggleButtonFrame.midY), radius: scanQRButton.frame.size.width * 0.5)
            return frame
        }
    }
    
    func qrButtonAlpha(for state: State) -> CGFloat {
        switch state {
        case .off:
            return 1.0
        default:
            return 0.0
        }
    }
    
    func buttonBackgroundLayerPath(for state: State) -> UIBezierPath {
        switch state {
        case .off: return expandedPath
        default: return collapsedPath
        }
    }
    
    func buttonBackgroundLayerFrame(for state: State) -> CGRect {
        switch state {
        case .off:
            let height = view.frame.height - 2 * inset
            let width = shapeRatio * height
            let originX = view.center.x - smallCircleRatio * width
            let originY = inset
            return CGRect(x: originX, y: originY, width: width, height: height)
            
        default:
            let width = (view.frame.height - 2 * inset) * shapeRatio
            let height = width
            let originX = view.center.x - width * 0.5
            let originY = inset
            return CGRect(x: originX, y: originY, width: width, height: height)
        }
    }
    
    func buttonBackgroundLayerColor(for state: State) -> UIColor {
        switch state {
        case .off: return Colors.buttonGroupExpanded.color
        default: return Colors.buttonGroupCollapsed.color
        }
    }
    
    func toggleButtonColor(for state: State) -> UIColor {
        switch state {
        case .off: return Colors.toggleButtonOffNormal.color
        default: return Colors.toggleButtonOnNormal.color
        }
    }
    
    func toggleButtonTitle(for state: State) -> String {
        switch state {
        case .off: return "ВКЛ."
        case .on: return "ВЫКЛ."
        case .gotUpdates: return "↓"
        }
    }
    
    func resizePaths() {
        let transform = expandedPath.scale(toFit: buttonBackgroundLayerFrame(for: .off).size)
        expandedPath.apply(transform)
        collapsedPath.apply(transform)
    }
    
    func updateState(to state: State, animated: Bool = true) {
        let duration = animated ? animationDuration : 0.0
        toggleButton.setTitle(toggleButtonTitle(for: state), for: .normal)
        
        UIView.animate(withDuration: duration) {
            self.scanQRButton.frame = self.qrButtonFrame(for: state)
            self.toggleButton.normalColor = self.toggleButtonColor(for: state)
            self.scanQRButton.alpha = self.qrButtonAlpha(for: state)
        }

        CATransaction.begin()
    //    CATransaction.setAnimationDuration(duration)
        CATransaction.setDisableActions(true)
        buttonBackgroundLayer.path = buttonBackgroundLayerPath(for: state).cgPath
        buttonBackgroundLayer.position = buttonBackgroundLayerFrame(for: state).center
        buttonBackgroundLayer.fillColor = buttonBackgroundLayerColor(for: state).cgColor
//        buttonBackgroundLayer.frame = buttonBackgroundLayerFrame(for: state)
        CATransaction.commit()
        
        let morphing = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
        //morphing.fromValue = buttonBackgroundLayerPath(for: self.state)
        morphing.fromValue = buttonBackgroundLayerPath(for: self.state).cgPath
        morphing.toValue = buttonBackgroundLayerPath(for: state).cgPath
        //morphing.beginTime = duration
        morphing.duration = duration
        let changeColor = CABasicAnimation(keyPath: "fillColor")
        //changeColor.fromValue = state.color.cgColor
        changeColor.toValue = buttonBackgroundLayerColor(for: state).cgColor
        changeColor.duration = duration
        /*let group = CAAnimationGroup()
        group.duration = ButtonBackgroundView.animationDuration
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        group.animations = [morphing, changeColor]*/
        //backgroundLayer.add(group, forKey: "state_animation")
        buttonBackgroundLayer.add(changeColor, forKey: "change_color")
        buttonBackgroundLayer.add(morphing, forKey: "morphing")
        let move = CABasicAnimation(keyPath: "position")
        move.toValue = NSValue(cgPoint: buttonBackgroundLayerFrame(for: state).center)
        move.beginTime = CACurrentMediaTime() + duration
        move.duration = duration
        buttonBackgroundLayer.add(move, forKey: "move")
        UIView.animate(withDuration: duration, delay: duration, options: [], animations: { 
            self.toggleButton.frame = self.toggleButtonFrame(for: state)
        }, completion: nil)
        self.state = state
    }
}


extension ControlPanelViewController {
    enum State {
        case off
        case on
        case gotUpdates
        
    }
}


extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

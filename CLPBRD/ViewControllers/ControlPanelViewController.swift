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


func loadAndTranslatePath(fileName: String) -> UIBezierPath {
    let path = loadSVG(from: fileName)
    let origin = path.bounds.origin
    let transform = CGAffineTransform(translationX: -origin.x, y: -origin.y)
    path.apply(transform)
    return path
}


class ControlPanelViewController: UIViewController {
    lazy var expandedPath: UIBezierPath = loadAndTranslatePath(fileName: "buttons_expanded")
    lazy var collapsedPath: UIBezierPath = loadAndTranslatePath(fileName: "buttons_collapsed")
    var animationDuration = 0.25//5.0
    
    private(set) var state: State = .off {
        didSet {
            updateContainerVisibility()
        }
    }
    
    @IBOutlet weak var toggleButton: RoundButton!
    @IBOutlet weak var scanQRButton: RoundButton!
    var buttonBackgroundLayer = CAShapeLayer()
    
    @IBOutlet weak var buttonBackgroundOffDummy: UIView!
    @IBOutlet weak var buttonBackgroundOnDummy: UIView!
    @IBOutlet weak var scanQROffDummy: UIView!
    @IBOutlet weak var scanQROnDummy: UIView!
    @IBOutlet weak var toggleOffDummy: UIView!
    @IBOutlet weak var toggleOnDummy: UIView!
    
    @IBOutlet weak var serverInfoContainer: UIView!
    @IBOutlet weak var serverAddressLabel: UILabel!
    @IBOutlet weak var offInfoContainer: UIView!
    
    weak var delegate: ControlPanelViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.sendSubview(toBack: scanQRButton)
        view.sendSubview(toBack: buttonBackgroundOffDummy)
//        buttonBackgroundLayer.isHidden = true
        buttonBackgroundOffDummy.isHidden = true
        //buttonBackgroundLayer.anchorPoint = CGPoint.zero
        scanQRButton.highlightColor = Colors.scanQRButtonHighlighted.color
        scanQRButton.normalColor = Colors.scanQRButtonNormal.color
        toggleButton.highlightColor = Colors.toggleButtonOffHighlighted.color
        toggleButton.normalColor = Colors.toggleButtonOffNormal.color
        view.layer.addSublayer(buttonBackgroundLayer)
        buttonBackgroundLayer.zPosition = -1.0
        buttonBackgroundLayer.anchorPoint = CGPoint(x: 1.0, y: 0.0)
        updateContainerVisibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resizePaths()
        setupButtons()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resizePaths()
    }
    
    func updateContainerVisibility() {
        let visible = state == .off ? offInfoContainer : serverInfoContainer
        let invisible = state != .off ? offInfoContainer : serverInfoContainer
        UIView.animate(withDuration: animationDuration) { 
            visible?.alpha = 1.0
            invisible?.alpha = 0.0
        }
    }
    
    func setupButtons() {
        DispatchQueue.main.async {
            self.toggleButton.frame = self.toggleButtonFrame(for: self.state)
            self.scanQRButton.frame = self.qrButtonFrame(for: self.state)
        }
    }
    
    @IBAction func toggleButtonPressed(_ sender: Any) {
        if state == .off {
            updateState(to: .on)
        } else {
            updateState(to: .off)
        }
    }
    
    func dummyFrame(dummy: UIView) -> CGRect {
        return dummy.superview!.convert(dummy.frame, to: self.view)
    }

    func toggleButtonFrame(for state: State) -> CGRect {
        switch state {
        case .off: return dummyFrame(dummy: toggleOffDummy)
        default: return dummyFrame(dummy: toggleOnDummy)
        }
    }
    
    func qrButtonFrame(for state: State) -> CGRect {
        switch state {
        case .off: return dummyFrame(dummy: scanQROffDummy)
        default: return dummyFrame(dummy: scanQROnDummy)
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
            return dummyFrame(dummy: buttonBackgroundOffDummy)
        default:
            return dummyFrame(dummy: buttonBackgroundOnDummy)
        }
    }
    
    func buttonBackgroundLayerPosition(for state: State) -> CGPoint {
        let frame = buttonBackgroundLayerFrame(for: state)
        return CGPoint(x: frame.minX, y: frame.minY)
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
        let transform = expandedPath.scale(toFit: buttonBackgroundOffDummy.frame.size)
        expandedPath.apply(transform)
        collapsedPath.apply(transform)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        buttonBackgroundLayer.path = buttonBackgroundLayerPath(for: state).cgPath
//        buttonBackgroundLayer.frame = buttonBackgroundLayerFrame(for: state)
        buttonBackgroundLayer.position = buttonBackgroundLayerPosition(for: state)
        buttonBackgroundLayer.fillColor = buttonBackgroundLayerColor(for: state).cgColor
        CATransaction.commit()
    }
    
    func animateButtonBackgroundLayer(to state: State) {
        
    }
    
    func updateState(to state: State, animated: Bool = true) {
        let duration = animated ? animationDuration : 0.0
        toggleButton.setTitle(toggleButtonTitle(for: state), for: .normal)
        
        UIView.animate(withDuration: duration, animations: {
            self.scanQRButton.frame = self.qrButtonFrame(for: state)
            self.toggleButton.normalColor = self.toggleButtonColor(for: state)
            self.scanQRButton.alpha = self.qrButtonAlpha(for: state)
        }, completion: { _ in
            self.buttonBackgroundLayer.position = self.buttonBackgroundLayerPosition(for: state)
        })
        buttonBackgroundLayer.path = buttonBackgroundLayerPath(for: state).cgPath
        buttonBackgroundLayer.fillColor = buttonBackgroundLayerColor(for: state).cgColor
        buttonBackgroundLayer.position = buttonBackgroundLayerPosition(for: state)
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
        let move = CABasicAnimation(keyPath: "position")
        move.toValue = NSValue(cgPoint: buttonBackgroundLayerPosition(for: state))
        move.beginTime = CACurrentMediaTime() + duration
        move.duration = duration
        buttonBackgroundLayer.add(changeColor, forKey: "change_color")
        buttonBackgroundLayer.add(morphing, forKey: "morphing")
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

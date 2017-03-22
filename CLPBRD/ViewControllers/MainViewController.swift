//
//  MainViewController.swift
//  CLPBRD
//
//  Created by Александр Долоз on 14.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit


protocol MainViewControllerDelegate: class {
    func mainViewControllerDisplayQR(_ viewController: MainViewController)
    func mainViewControllerScanQR(_ viewController: MainViewController)
}

class MainViewController: UIViewController {
    @IBOutlet weak var toggleButton: RoundButton!
    @IBOutlet weak var scanQRButton: RoundButton!
    @IBOutlet weak var showQRButton: UIButton!
    @IBOutlet weak var logo: UIImageView!
    
    weak var delegate: MainViewControllerDelegate?
    
    var clipboardSyncClientService: ClipboardSyncClientService
    
    init(clipboardSyncClientService: ClipboardSyncClientService) {
        self.clipboardSyncClientService = clipboardSyncClientService
        super.init(nibName: String(describing: type(of: self)), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func showQRPressed(_ sender: Any) {
        delegate?.mainViewControllerDisplayQR(self)
    }
    
    @IBAction func scanQRPressed(_ sender: Any) {
        delegate?.mainViewControllerScanQR(self)
    }
    
    @IBAction func togglePressed(_ sender: Any) {
//        delegate?.togglePressed(on: self, toggled: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        logo.tintColor = .white
        scanQRButton.highlightColor = Colors.scanQRButtonHighlighted.color
        scanQRButton.normalColor = Colors.scanQRButtonNormal.color
        toggleButton.highlightColor = Colors.toggleButtonOffHighlighted.color
        toggleButton.normalColor = Colors.toggleButtonOffNormal.color
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let pathString = try! String(contentsOf: Bundle.main.url(forResource: "buttons_expanded", withExtension: "path")!)
        
        let path = UIBezierPath(svgPath: pathString)
        
        let layer1 = CAShapeLayer()
        
        layer1.path = path.cgPath
        view.layer.addSublayer(layer1)
        let otherPathString = try! String(contentsOf: Bundle.main.url(forResource: "buttons_collapsed", withExtension: "path")!)
        let otherPath = UIBezierPath(svgPath: otherPathString)
//        let layer2 = CAShapeLayer()
//        layer2.path = otherPath.cgPath
//        layer2.fillColor = UIColor.red.cgColor
//        view.layer.addSublayer(layer2)
//        CATransaction.begin()
        let morph = CABasicAnimation(keyPath: "path")
        morph.fromValue = path.cgPath
        morph.toValue   = otherPath.cgPath
        let changeColor = CABasicAnimation(keyPath: "fillColor")
        changeColor.fromValue = Colors.buttonGroupExpanded.color.cgColor
        changeColor.toValue = Colors.buttonGroupCollapsed.color.cgColor
        let group = CAAnimationGroup()
        group.duration = 0.25
        group.repeatCount = 3
        group.autoreverses = true
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        group.animations = [morph, changeColor]
//        CATransaction.setCompletionBlock {
//            layer1.path = otherPath.cgPath
//        }
        layer1.add(group, forKey: "morph")
//        layer1.add(changeColor, forKey: "cc")
        layer1.path = otherPath.cgPath
        layer1.fillColor = Colors.buttonGroupCollapsed.color.cgColor
//        CATransaction.commit()
    }
    
}

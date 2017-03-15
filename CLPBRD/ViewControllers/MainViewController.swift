//
//  MainViewController.swift
//  CLPBRD
//
//  Created by Александр Долоз on 14.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var scanQRButton: UIButton!
    @IBOutlet weak var showQRButton: UIButton!
    
    var onShowQRPressed: VoidClosure = {}
    var onScanQRPressed: VoidClosure = {}
    var onTogglePressed: (Bool) -> Void = { _ in }
    
    @IBAction func showQRPressed(_ sender: Any) {
        onShowQRPressed()
    }
    
    @IBAction func scanQRPressed(_ sender: Any) {
        onScanQRPressed()
    }
    
    @IBAction func togglePressed(_ sender: Any) {
        onTogglePressed(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

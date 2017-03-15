//
//  MainViewController.swift
//  CLPBRD
//
//  Created by Александр Долоз on 14.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit


protocol MainViewControllerDelegate: class {
    func showQRPressed(on mainViewController: MainViewController)
    func scanQRPressed(on mainViewController: MainViewController)
    func togglePressed(on mainViewController: MainViewController, toggled: Bool)
}

class MainViewController: UIViewController {
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var scanQRButton: UIButton!
    @IBOutlet weak var showQRButton: UIButton!
    
    weak var delegate: MainViewControllerDelegate?
    
    @IBAction func showQRPressed(_ sender: Any) {
        delegate?.showQRPressed(on: self)
    }
    
    @IBAction func scanQRPressed(_ sender: Any) {
        delegate?.scanQRPressed(on: self)
    }
    
    @IBAction func togglePressed(_ sender: Any) {
        delegate?.togglePressed(on: self, toggled: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
    }
}

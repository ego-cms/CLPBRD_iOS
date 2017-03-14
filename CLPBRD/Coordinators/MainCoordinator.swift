//
//  MainCoordinator.swift
//  CLPBRD
//
//  Created by Александр Долоз on 14.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit



class MainCoordinator: Coordinator {
    var initialViewController: UIViewController
    var onCompletion: VoidClosure = {}
    
    private let mainViewController: MainViewController
    
    init(mainViewController: MainViewController) {
        self.mainViewController = mainViewController
        self.initialViewController = mainViewController
    }
}

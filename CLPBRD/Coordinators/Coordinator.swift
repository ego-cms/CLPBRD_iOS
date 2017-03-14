//
//  Coordinator.swift
//  CLPBRD
//
//  Created by Александр Долоз on 14.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit


protocol Coordinator {
    var initialViewController: UIViewController { get }
    var onCompletion: VoidClosure { get set }
}

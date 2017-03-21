//
//  SyncParticipantView.swift
//  CLPBRD
//
//  Created by Александр Долоз on 20.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit

class SyncParticipantView: UIView {
    @IBOutlet private weak var hostAddressLabel: UILabel!
    @IBOutlet private weak var container: UIView!
    
    var host: String? {
        didSet {
            hostAddressLabel.text = host
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        container.layer.cornerRadius = frame.width * 0.5
    }
    
    func set(color: UIColor, animated: Bool = true) {
        let closure = {
            self.container.backgroundColor = color
        }
        if animated {
            UIView.animate(withDuration: 0.25, animations: closure)
        } else {
            closure()
        }
    }
}

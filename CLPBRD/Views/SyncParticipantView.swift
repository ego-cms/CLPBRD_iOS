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
    
    private(set) var isSelected: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 3.0
        set(color: .black, animated: false)
        set(selected: false, animated: false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        container.layer.cornerRadius = container.frame.width * 0.5
        layer.cornerRadius = frame.width * 0.5
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

    func set(selected: Bool, animated: Bool = true) {
        let closure = {
            self.layer.borderColor = (selected ? UIColor.blue : UIColor.clear).cgColor
            self.isSelected = selected
        }
        if animated {
            UIView.animate(withDuration: 0.25, animations: closure)
        } else {
            closure()
        }
    }
}

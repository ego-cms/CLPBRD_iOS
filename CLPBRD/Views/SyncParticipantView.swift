//
//  SyncParticipantView.swift
//  CLPBRD
//
//  Created by Александр Долоз on 20.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit

class SyncParticipantView: UIView {
    @IBOutlet weak var hostAddressLabel: UILabel!
    @IBOutlet weak var container: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        container.layer.cornerRadius = frame.width * 0.5
    }
}

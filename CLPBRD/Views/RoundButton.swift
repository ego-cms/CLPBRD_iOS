//
//  RoundButton.swift
//  CLPBRD
//
//  Created by Александр Долоз on 22.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit

class RoundButton: UIButton {
    var normalColor: UIColor = UIColor.clear
    var highlightColor: UIColor = UIColor.lightGray
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(frame.width, frame.height) * 0.5
        updateBackgroundColor()
        imageView?.contentMode = .scaleAspectFit
        setImage(imageView?.image, for: .normal)
    }
    
    override var isHighlighted: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    
    private func updateBackgroundColor() {
        self.backgroundColor = isHighlighted ? highlightColor : normalColor
    }
}

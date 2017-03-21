//
//  ContentBuffer+HashColor.swift
//  CLPBRD
//
//  Created by Александр Долоз on 20.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit


extension ContentBuffer {
    var hashColor: UIColor {
        let colors: [UIColor] = [
            .red,
            .green,
            .blue,
            .orange,
            .cyan,
            .yellow
        ]
        return content != nil ? colors[abs(content!.hashValue) % colors.count] : UIColor.black
    }
}

//
//  ButtonGroupLayer.swift
//  CLPBRD
//
//  Created by Александр Долоз on 22.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit


var originalSize = CGSize(width: 645, height: 800)
var bigCircleOriginalRadius: CGFloat = 580 / 2
var smallCircleOriginalRadius: CGFloat = 330 / 2
var buttonSpacing: CGFloat = 30

func loadPath(from fileName: String) -> UIBezierPath {
    let pathString = try! String(contentsOf: Bundle.main.url(forResource: fileName, withExtension: "path")!)
    
    return UIBezierPath(svgPath: pathString)
}

extension CGRect {
    init(center: CGPoint, radius: CGFloat) {
        origin = CGPoint(x: center.x - radius, y: center.y - radius)
        size = CGSize(width: 2 * radius, height: 2 * radius)
    }
}
//
//func topButtonFrame(for path: UIBezierPath) -> CGRect {
//    
//}

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

func loadSVG(from fileName: String) -> UIBezierPath {
    let pathString = try! String(contentsOf: Bundle.main.url(forResource: fileName, withExtension: "path")!)
    
    return UIBezierPath(svgPath: pathString)
}

extension CGRect {
    init(center: CGPoint, radius: CGFloat) {
        origin = CGPoint(x: center.x - radius, y: center.y - radius)
        size = CGSize(width: 2 * radius, height: 2 * radius)
    }
}

extension UIBezierPath {
    func scale(toFit containerSize: CGSize) -> CGAffineTransform {
        let size = bounds.size
        let (w, h) = (size.width, size.height)
        let (cw, ch) = (containerSize.width, containerSize.height)
        guard w != 0 && h != 0 else { return CGAffineTransform.identity }
        let scale = min(cw / w, ch / h)
        return CGAffineTransform(scaleX: scale, y: scale)
    }
}

func topButtonFrame(in containerRect: CGRect) -> CGRect {
    let centerX = containerRect.width - (containerRect.width / originalSize.width) * bigCircleOriginalRadius
    let centerY = (containerRect.height / originalSize.height) * bigCircleOriginalRadius
    return CGRect(center: CGPoint(x: centerX, y: centerY), radius: (containerRect.width / originalSize.width) * bigCircleOriginalRadius * 0.8)
}

func bottomButtonFrame(in containerRect: CGRect) -> CGRect {
    let centerX = (containerRect.width / originalSize.width) * smallCircleOriginalRadius
    let centerY = containerRect.height - (containerRect.height / originalSize.height) * smallCircleOriginalRadius
    return CGRect(center: CGPoint(x: centerX, y: centerY), radius: (containerRect.width / originalSize.width) * smallCircleOriginalRadius * 0.8)
}



//
//func topButtonFrame(for path: UIBezierPath) -> CGRect {
//    
//}

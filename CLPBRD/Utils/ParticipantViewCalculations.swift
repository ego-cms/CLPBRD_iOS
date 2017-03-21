//
//  ParticipantViewCalculations.swift
//  CLPBRD
//
//  Created by Александр Долоз on 21.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit


func participantViewSide(in bounds: CGRect) -> CGFloat {
    return bounds.width * 0.3
}

func participantViewSize(in bounds: CGRect) -> CGSize {
    let side = participantViewSide(in: bounds)
    return CGSize(width: side, height: side)
}

func participantViewVerticalSpacing(in bounds: CGRect) -> CGFloat {
    return (bounds.height - 2 * participantViewSide(in: bounds)) / 3
}

func participantViewFrames(in bounds: CGRect) -> (CGRect, CGRect) {
    let space = participantViewVerticalSpacing(in: bounds)
    let size = participantViewSize(in: bounds)
    let originX = bounds.midX - size.width * 0.5
    let first = CGRect(origin: CGPoint(x: originX, y: space), size: size)
    let second = CGRect(origin: CGPoint(x: originX, y: size.height + 2 * space), size: size)
    return (first, second)
}

func isFramesCloseEnough(frame1: CGRect, frame2: CGRect) -> Bool {
    let intersection = frame1.intersection(frame2)
    let intersectionArea = intersection.width * intersection.height
    let frame1Area = frame1.width * frame1.height
    guard frame1Area != 0 else {
        return false
    }
    return intersectionArea / frame1Area > 0.3
}

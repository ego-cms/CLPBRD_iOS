//
//  DeviceOrientationToVideoOrientation.swift
//  CLPBRD
//
//  Created by Александр Долоз on 05.04.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import AVFoundation
import UIKit


func deviceOrientationToVideoOrientation(deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
    switch deviceOrientation {
    case .portrait: return .portrait
    case .landscapeLeft: return .landscapeRight
    case .landscapeRight: return .landscapeLeft
    case .portraitUpsideDown: return .portraitUpsideDown
    default: return .portrait
    }
}

//
//  QRDisplayService.swift
//  CLPBRD
//
//  Created by Александр Долоз on 16.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit
import Result


enum QRDisplayError: Error {
    case textError
//    case textTooBig
    case qrGenerationError
}


protocol QRDisplayService: class {
    var side: CGFloat { get set }
    var text: String { get set }
    var onQRCodeReady: (String, Result<UIImage, QRDisplayError>) -> Void { get set }
}

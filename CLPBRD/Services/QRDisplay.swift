//
//  QRDisplay.swift
//  CLPBRD
//
//  Created by Александр Долоз on 16.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import UIKit
import CoreImage
import Result


class QRDisplay: QRDisplayService {
    var text: String = "" {
        didSet {
            prepareQRCode()
        }
    }
    
    var onQRCodeReady: (String, Result<UIImage, QRDisplayError>) -> Void = { _ in }
    
    private func prepareQRCode() {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let data = self.text.data(using: .utf8) else {
                DispatchQueue.main.async {
                    self.onQRCodeReady(self.text, .failure(QRDisplayError.textError))
                }
                return
            }
            let filter = CIFilter(name: "CIQRCodeGenerator")
            filter?.setValue(data, forKey: "inputMessage")
            filter?.setValue("H", forKey: "inputCorrectionLevel")
            guard let image = filter?.outputImage else {
                DispatchQueue.main.async {
                    self.onQRCodeReady(self.text, .failure(QRDisplayError.qrGenerationError))
                }
                return
            }
            let uiimage = UIImage(ciImage: image)
            DispatchQueue.main.async {
                self.onQRCodeReady(self.text, .success(uiimage))
            }
        }
    }
}

//
//  URLHelpersTests.swift
//  CLPBRD
//
//  Created by Александр Долоз on 15.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import XCTest
@testable import CLPBRD


class URLHelpersTests: XCTestCase {
    func testWebSocketsURL() {
        XCTAssertEqual("ws://192.164.0.1:595959", URL.createWebSocketURL(with: "192.164.0.1", port: 595959)?.absoluteString)
    }
    
    func testParametersURL() {
        XCTAssertEqual("http://192.164.0.1:8080/clipboard", URL.createParametersURL(with: "192.164.0.1")?.absoluteString)
    }
}

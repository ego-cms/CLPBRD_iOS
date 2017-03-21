//
//  ContentBufferTests.swift
//  CLPBRD
//
//  Created by Александр Долоз on 20.03.17.
//  Copyright © 2017 Cayugasoft LLC. All rights reserved.
//

import XCTest
@testable import CLPBRD


class ContentBufferTests: XCTestCase {
//    var expectation: XCTestExpectation?
    
    var cb1: ContentBuffer!
    var cb2: ContentBuffer!
    var pb: CompositeContentBuffer!
    
    override func setUp() {
        super.setUp()
        cb1 = ContentBuffer()
        cb1.content = "Initial1"
        cb2 = ContentBuffer()
        cb2.content = "Initial2"
        pb = CompositeContentBuffer(buffers: [cb1, cb2])
    }
    
    private func executeLater(after seconds: Double = 1.0, closure: @escaping VoidClosure) {
        let time = DispatchTime(uptimeNanoseconds: UInt64(seconds) * NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: closure)
    }
    
    func testCompositeBufferOrder() {
        let expectation = self.expectation(description: "On creation composite buffer will have contents of the last child buffer")
        XCTAssertEqual(self.cb1.content, "Initial1")
        XCTAssertEqual(self.cb2.content, "Initial2")
        executeLater(after: 0.1) {
            XCTAssertEqual(self.pb.content, "Initial2")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 0.2) { _ in
        }
    }
    
    func testCompositeBufferUpdate() {
        let expectation = self.expectation(description: "Composite buffer has the same content as last updated child")
        cb1.content = "Updated1"
        executeLater(after: 0.1) {
            XCTAssertEqual(self.pb.content, "Updated1")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 0.2) { _ in
        }
    }
    
//    func testBufferNotifications() {
//        let expectation = self.expectation(forNotification: ContentBuffer.changeNotificationName.rawValue, object: nil) { notification in
//            XCTAssertEqual(self.cb1.content, "NewContent")
//        }
////        NotificationCenter.default.addObserver(forName: ContentBuffer.changeNotificationName, object: nil, queue: nil) { _ in
////
////        }
//        cb1.content = "NewContent"
//        waitForExpectations(timeout: 0.1) { _ in }
//
//    }
//    
//    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}

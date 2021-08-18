//
//  SwiftFileAppUITests.swift
//  SwiftFileAppUITests
//
//  Created by HungNV on 4/12/21.
//  Copyright © 2021 NIFTY Corporation. All rights reserved.
//

import XCTest

class SwiftFileAppUITests: XCTestCase {

    var app: XCUIApplication!
    var toolbar: XCUIElement!
    let cameraMsgErr = "エラーが発生しました"
    let saveMsgErr = "画像がありません"
    
    // MARK: - Setup for UI Test
    override func setUp() {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        app = XCUIApplication()
        toolbar = app.toolbars["Toolbar"]
    }
    
    func testScreen() throws {
        app.launch()
        let image = app.images["image"]
        XCTAssert(image.exists)
        let btnSave = toolbar.buttons["mobile backendに保存"]
        XCTAssert(btnSave.exists)
        btnSave.tap()
        XCTAssert(app.staticTexts[saveMsgErr].exists)
        
        let btnCamera = toolbar.buttons["Camera"]
        XCTAssert(btnCamera.exists)
        btnCamera.tap()
        XCTAssert(app.staticTexts[cameraMsgErr].exists)
    }
}

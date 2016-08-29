//
//  RipelistUITests.swift
//  RipelistUITests
//
//  Created by Aaron Williamson on 1/19/16.
//  Copyright © 2016 Aaron Williamson. All rights reserved.
//

import XCTest

class RipelistUITests: XCTestCase {
    let app = XCUIApplication()
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testHelp() {
        let helpTabText = app.tabBars.staticTexts["Help"]
        XCTAssertTrue(helpTabText.exists, "Should be displayed in the tab bar ")
        
        app.tabs["asdf"].tap()
    }
    
}

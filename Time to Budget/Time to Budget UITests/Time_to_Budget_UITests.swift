//
//  Time_to_Budget_UITests.swift
//  Time to Budget UITests
//
//  Created by Robert Kennedy on 10/21/15.
//  Copyright © 2015 Arrken Games, LLC. All rights reserved.
//

import XCTest

class Time_to_Budget_UITests: XCTestCase {
        
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
        
        let app = XCUIApplication()
        app.tabBars.buttons["Settings"].tap()
        app.tables.staticTexts["Reset All"].tap()
        app.alerts["Are You Sure?"].collectionViews.buttons["Yes"].tap()
        super.tearDown()
    }
    
    func testAddCategory() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        app.tabBars.buttons["Editor"].tap()
        app.navigationBars["168:00"].buttons["+ Category"].tap()
        //app.typeText("Test Category")
        app.alerts["New Category"].collectionViews.buttons["Add"].tap()
        let addCategoryTest = app.tables.staticTexts[""].exists
        XCTAssert(addCategoryTest)
    }
    
    func testAddTask() {
        
        XCTAssert(false)
    }
}

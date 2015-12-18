//
//  core_xUITests.swift
//  core-xUITests
//
//  Created by Ryan Cobelli on 12/12/15.
//  Copyright © 2015 Rybel LLC. All rights reserved.
//

import XCTest

class core_xUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
		
		continueAfterFailure = false
		// UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
		XCUIApplication().launch()
		
		let app = XCUIApplication()
		setupSnapshot(app)
		app.launchArguments = [ "testing" ]
		app.launch()
		

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
		
		let app = XCUIApplication()
		snapshot("1-homeScreen")
		app.tables.staticTexts["Core X"].tap()
		snapshot("2-workoutSetup")
		app.buttons["Start"].tap()
		sleep(12/5)
		snapshot("0-midWorkout")
		
    }
    
}

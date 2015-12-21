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
		
		let app = XCUIApplication()
		setupSnapshot(app)
		app.launchArguments = [ "testing" ]
		app.launch()
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

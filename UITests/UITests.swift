//
//  UITests.swift
//  UITests
//
//  Created by Ryan Cobelli on 6/16/19.
//  Copyright © 2019 Rybel LLC. All rights reserved.
//

import XCTest

class UITests: XCTestCase {

    override func setUp() {
		let app = XCUIApplication()
		app.launchArguments += [ "testing" ]
		setupSnapshot(app)
		app.launch()
    }

    func testExample() {
		let app = XCUIApplication()
		let coreX = app.tables.cells.element(boundBy: 0)
		let myrtl = app.tables.cells.element(boundBy: 1)
		
		snapshot("1-homeScreen")
		myrtl.tap()
		myrtl.children(matching: .textField).element(boundBy: 0).tap()
		snapshot("2-workoutSetup")
		coreX.tap()
		coreX.children(matching: .button).element(boundBy: 0).tap()
		sleep(12/5)
		snapshot("0-midWorkout")
    }

}

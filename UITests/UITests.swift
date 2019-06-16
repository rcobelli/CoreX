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
		snapshot("1-homeScreen")
		app.tables.cells.element(boundBy: 0).tap()
		snapshot("2-workoutSetup")
		app.buttons.element(boundBy: 1).tap()
		sleep(12/5)
		snapshot("0-midWorkout")
    }

}

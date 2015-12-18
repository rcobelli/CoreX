//
//  LastSevenDaysViewController.swift
//  core-x
//
//  Created by Ryan Cobelli on 12/12/15.
//  Copyright © 2015 Rybel LLC. All rights reserved.
//

import UIKit

class LastSevenDaysViewController: UIViewController {

	@IBOutlet weak var oneDayAgo: PreviousDay!
	@IBOutlet weak var twoDaysAgo: PreviousDay!
	@IBOutlet weak var threeDaysAgo: PreviousDay!
	@IBOutlet weak var fourDaysAgo: PreviousDay!
	@IBOutlet weak var fiveDaysAgo: PreviousDay!
	@IBOutlet weak var sixDaysAgo: PreviousDay!
	@IBOutlet weak var sevenDaysAgo: PreviousDay!

	var hasLoaded = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	override func viewDidAppear(animated: Bool) {
		if !hasLoaded {
			oneDayAgo.configView(getDayOfWeek(0), workedOut: didWorkOut(0))
			twoDaysAgo.configView(getDayOfWeek(1), workedOut: didWorkOut(1))
			threeDaysAgo.configView(getDayOfWeek(2), workedOut: didWorkOut(2))
			fourDaysAgo.configView(getDayOfWeek(3), workedOut: didWorkOut(3))
			fiveDaysAgo.configView(getDayOfWeek(4), workedOut: didWorkOut(4))
			sixDaysAgo.configView(getDayOfWeek(5), workedOut: didWorkOut(5))
			sevenDaysAgo.configView(getDayOfWeek(6), workedOut: didWorkOut(6))

			hasLoaded = true
		}
	}

	func didWorkOut(daysAgo: Int)->Bool {
		let today: NSDate = NSDate()

		let daysToAdd : Int = -daysAgo

		// Set up date components
		let dateComponents: NSDateComponents = NSDateComponents()
		dateComponents.day = daysToAdd

		let format = NSDateFormatter()
		format.dateFormat = "MM-dd-yyyy"

		// Create a calendar
		let gregorianCalendar: NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
		let yesterDayDate: NSDate = gregorianCalendar.dateByAddingComponents(dateComponents,
																			toDate: today,
																			options:NSCalendarOptions(rawValue: 0))!

		return NSUserDefaults.standardUserDefaults().boolForKey(format.stringFromDate(yesterDayDate))
	}

	func getDayOfWeek(daysAgo: Int)->String {

		let today: NSDate = NSDate()

		let daysToAdd : Int = -daysAgo

		// Set up date components
		let dateComponents: NSDateComponents = NSDateComponents()
		dateComponents.day = daysToAdd

		let format = NSDateFormatter()
		format.dateFormat = "MM-dd-yyyy"

		// Create a calendar
		let gregorianCalendar: NSCalendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)!
		let yesterDayDate: NSDate = gregorianCalendar.dateByAddingComponents(dateComponents,
																			toDate: today,
																			options:NSCalendarOptions(rawValue: 0))!

		let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
		let myComponents = myCalendar.components(.Weekday, fromDate: yesterDayDate)
		let weekDay = myComponents.weekday

		switch weekDay {
		case 1:
			return "Sun"
		case 2:
			return "Mon"
		case 3:
			return "Tue"
		case 4:
			return "Wed"
		case 5:
			return "Thur"
		case 6:
			return "Fri"
		default:
			return "Sat"
		}
	}
}

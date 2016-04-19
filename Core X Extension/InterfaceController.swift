//
//  InterfaceController.swift
//  Core X Extension
//
//  Created by Ryan Cobelli on 4/18/16.
//  Copyright © 2016 Rybel LLC. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
	
	@IBOutlet weak var table: WKInterfaceTable!
	
	let workouts = ["Core X", "Myrtl", "Leg-Day", "101 Pushups", "Yoga"]

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
		
		NSUserDefaults.standardUserDefaults().setBool(true, forKey: "workout0")
		
		let watchSession = WCSession.defaultSession()
		watchSession.delegate = self
		watchSession.activateSession()
		
        setupTable()
    }

	func setupTable() {
		table.setNumberOfRows(workouts.count, withRowType: "TableRowController")
		
		for (index, workoutName) in workouts.enumerate() {
			let row = table.rowControllerAtIndex(index) as! TableRowController
			row.titleLabel.setText(workoutName)
		}
	}
	
	override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
		if NSUserDefaults.standardUserDefaults().boolForKey("workout" + String(rowIndex)) {
			presentControllerWithName("Workout", context: rowIndex)
		}
		else {
			let action = WKAlertAction(title: "Ok", style: .Cancel) {}
			presentAlertControllerWithTitle("Workout Not Purchased", message: "You can purchase this workout in the iPhone App", preferredStyle: .ActionSheet, actions: [action])
		}
	}
	
	func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
		for item in applicationContext {
			NSUserDefaults.standardUserDefaults().setBool(Bool(item.1 as! NSNumber), forKey: item.0)
		}
		
		print("\(applicationContext)")
		dispatch_async(dispatch_get_main_queue(), {
			self.setupTable()
		})
	}

}

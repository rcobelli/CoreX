//
//  InterfaceController.swift
//  watch Extension
//
//  Created by Ryan Cobelli on 2/23/17.
//  Copyright © 2017 Rybel LLC. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
		UserDefaults.standard.set(true, forKey: "workout0")
		
		let watchSession = WCSession.default()
		watchSession.delegate = self
		watchSession.activate()
		
		setupTable()
    }
	
	func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
		for (key, value) in (applicationContext as! [String : Bool]) {
			UserDefaults.standard.set(value, forKey: key)
		}
	}
	
	@IBOutlet weak var table: WKInterfaceTable!
	
	let workouts = ["Core X", "Myrtl", "Leg-Day", "101 Pushups", "Yoga", "Coach Liz"]
	
	func setupTable() {
		table.setNumberOfRows(workouts.count, withRowType: "TableRowController")
		for (index, workoutName) in workouts.enumerated() {
			let row = table.rowController(at: index) as! TableRowController
			row.titleLabel.setText(workoutName)
		}
	}
	
	override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
		if UserDefaults.standard.bool(forKey: "workout" + String(rowIndex)) {
			pushController(withName: "Workout", context: rowIndex)
			WKInterfaceController.reloadRootControllers(withNames: ["Workout"], contexts: [rowIndex])
		}
		else {
			let action = WKAlertAction(title: "Ok", style: .cancel) {}
			presentAlert(withTitle: "Workout Not Purchased", message: "You can purchase this workout in the iPhone App", preferredStyle: .actionSheet, actions: [action])
		}
	}
	
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		print(error ?? "No Error")
	}
	
	func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
		for item in applicationContext {
			UserDefaults.standard.set(Bool(item.1 as! NSNumber), forKey: item.0)
		}
		
		print("\(applicationContext)")
		DispatchQueue(label: "watchBackground").async {
			self.setupTable()
		}
	}
	
}


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

class InterfaceController: WKInterfaceController {
	
	@IBOutlet weak var table: WKInterfaceTable!
	
	override func awake(withContext context: Any?) {
		super.awake(withContext: context)
		
		let watchSession = WCSession.default
		watchSession.delegate = self
		watchSession.activate()
	}
	
	func setupTable() {
		table.setNumberOfRows(WorkoutDataManager.getWorkoutCount(), withRowType: "TableRowController")
		for index in 0..<WorkoutDataManager.getWorkoutCount() {
			guard let row = table.rowController(at: index) as? TableRowController else {
				return
			}
			row.titleLabel.setText(WorkoutDataManager.getWorkoutName(workoutID: index))
		}
	}
	
	override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
		if UserDefaults.standard.bool(forKey: "workout" + String(rowIndex)) {
			pushController(withName: "Workout", context: rowIndex)
		} else {
			presentAlert(withTitle: "Workout Not Purchased",
						 message: "You can purchase this workout in the iPhone App",
						 preferredStyle: .alert,
						 actions: [WKAlertAction(title: "Ok", style: .default, handler: {})])
		}
	}
}

extension InterfaceController: WCSessionDelegate {
	
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		setupTable()
	}
	
	func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
		print(applicationContext)
		
		for item in applicationContext {
			guard let value = item.1 as? NSNumber else {
				print("Unable to cast value to NSNumber")
				return
			}
			UserDefaults.standard.set(Bool(truncating: value), forKey: item.0)
		}
		
		print("\(applicationContext)")
		DispatchQueue(label: "watchBackground").async {
			self.setupTable()
		}
	}
	
	func session(session: WCSession, didReceiveApplicationContext applicationContext: [String: AnyObject]) {
		print(applicationContext)
		
		guard let appContext = applicationContext as? [String: Bool] else {
			return
		}
		for (key, value) in appContext {
			UserDefaults.standard.set(value, forKey: key)
		}
	}
}

//
//  WorkoutController.swift
//  core-x
//
//  Created by Ryan Cobelli on 4/18/16.
//  Copyright © 2016 Rybel LLC. All rights reserved.
//

import WatchKit
import HealthKit

class WorkoutController: WKInterfaceController, HKWorkoutSessionDelegate {
	
	var timer = Timer()
	
	
	@IBOutlet var timerLabel: WKInterfaceLabel!
	@IBOutlet var workoutTitle: WKInterfaceLabel!
	
	var exercises = NSDictionary()
	
	var workoutID = 0
	
	var timerRunning = true;
	var count = 0
	var exercise = 0
	
	var exerciseDuration = 0
	var restDuration = 0
	
	var exerciseID = -1
	
	var healthStore = HKHealthStore()
	var session : HKWorkoutSession?
	
	override func awake(withContext context: Any?) {
		workoutID = context as! Int
		
		if let path = Bundle.main.path(forResource: "workout" + String(workoutID), ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
			exercises = dict["exercises"] as! NSDictionary
			exerciseDuration = 30
			restDuration = 5
			self.setTitle((dict["workoutName"] as! String))
		}
		else {
			fatalError("Could Not Load .plist")
		}
		UserDefaults.standard.set(exercises, forKey: "exercises")
		
		let configuration = HKWorkoutConfiguration()
		configuration.activityType = .coreTraining
		configuration.locationType = .indoor
		
		do {
			session = try HKWorkoutSession(configuration: configuration)
			
			session!.delegate = self
			healthStore.start(session!)
		}
		catch let error as NSError {
			// Perform proper error handling here...
			fatalError("*** Unable to create the workout session: \(error.localizedDescription) ***")
		}
		
		timer = Timer.scheduledTimer(timeInterval: 1.0,
		                                               target: self,
		                                               selector: #selector(WorkoutController.update),
		                                               userInfo: nil,
		                                               repeats: true)
		
		updateActivity()
	}
	
	@objc func update() {
		count = count + 1
		if count <= exerciseDuration {
			workoutTitle.setTextColor(UIColor.white)
		}
		else if count == exerciseDuration + 1 && exercise < exercises.count {
			exercise = exercise + 1
			if exercise < exercises.count {
				workoutTitle.setTextColor(UIColor.red)
				updateActivity()
			}
			else {
				endWorkout()
			}
			WKInterfaceDevice.current().play(.start)
		}
		else if count < exerciseDuration + restDuration {
			// Just catching something BS from triggering below
		}
		else if (exercise < exercises.count) {
			count = 0
			
			WKInterfaceDevice.current().play(.start)
		}
		else {
			endWorkout()
		}
		if (count > 30) {
			timerLabel.setText(String(0))
		}
		else {
			timerLabel.setText(String(30 - count))
		}
		
	}
	
	func endWorkout() {
		HealthManager().saveWorkout(30.0, workoutNumber: self.workoutID, completion: { (success, error ) -> Void in
			if( success ) {
				print("Workout saved!")
			}
			else if( error != nil ) {
				print("\(String(describing: error))")
			}
		})
		
		
		end()
	}
	
	func updateActivity() {
		exerciseID = exerciseID + 1
		
		let exercises = UserDefaults.standard.dictionary(forKey: "exercises")!
		let currentExercise = exercises["Item " + String(exerciseID)]! as! [String:String]
		
		workoutTitle.setText(String(currentExercise["itemName"]!))
	}
	
	@IBAction func end() {
		timer.invalidate()
		if session != nil {
			healthStore.end(session!)
		}
		WKInterfaceDevice.current().play(.stop)
		WKInterfaceController.reloadRootControllers(withNames: ["main"], contexts: nil)
	}
	
	func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
	}
	
	func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
		print(error)
	}
	
	func workoutSession(_ workoutSession: HKWorkoutSession, didGenerate event: HKWorkoutEvent) {
		print(event)
	}
	
}

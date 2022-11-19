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
	
	@IBOutlet var timerLabel: WKInterfaceLabel!
	@IBOutlet var workoutTitle: WKInterfaceLabel!
	
	var exercises = NSDictionary()

	public var workoutID = 0
	
	var seconds = 0
	var exerciseNumber = 0
	
	var exerciseDuration = 30
	var restDuration = 5
	
	var timer = Timer()
	var healthStore = HKHealthStore()
	var session: HKWorkoutSession?
	
	override func awake(withContext context: Any?) {
		guard let workoutID = context as? Int else {
			fatalError("Invalid workout ID")
		}
		
		let path = Bundle.main.path(forResource: "workout" + String(workoutID), ofType: "plist")
		guard let dict = NSDictionary(contentsOfFile: path!) as? [String: AnyObject],
			  let exercises = dict["exercises"] as? NSDictionary,
			  let workoutName = dict["workoutName"] as? String
		else {
			fatalError("Could Not Load Valid .plist")
		}
		
		// TODO: Pull durations from the iPhone
		
	    self.setTitle(workoutName)
		self.exercises = exercises
		
		let configuration = HKWorkoutConfiguration()
		configuration.activityType = .coreTraining
		configuration.locationType = .indoor
		
		do {
			let healthStore = HKHealthStore()
			session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
			
			session!.delegate = self
			session!.startActivity(with: Date())
		} catch let error as NSError {
			// Perform proper error handling here...
			fatalError("*** Unable to create the workout session: \(error.localizedDescription) ***")
		}
		
		timer = Timer.scheduledTimer(timeInterval: 1.0,
									 target: self,
									 selector: #selector(WorkoutController.everySecond),
									 userInfo: nil,
									 repeats: true)
		
		updateActivity()
	}
	
	@objc func everySecond() {
		seconds += 1
		
		if seconds < exerciseDuration {
			// Still during exercise
			timerLabel.setText(String(30 - seconds))
			workoutTitle.setTextColor(UIColor.white)
		} else if seconds == exerciseDuration {
			// Start rest
			
			timerLabel.setText("0")
			workoutTitle.setTextColor(UIColor.red)
			exerciseNumber += 1
			
			if exerciseNumber < exercises.count {
				WKInterfaceDevice.current().play(.notification)
				updateActivity()
			} else {
				WKInterfaceDevice.current().play(.stop)
				endWorkout()
			}
		} else if seconds == exerciseDuration + restDuration {
			// Start workout
			seconds = 0
			WKInterfaceDevice.current().play(.notification)
		}
	}
	
	func endWorkout() {
		HealthManager().saveWorkout(Double(exerciseDuration),
									workoutNumber: self.workoutID,
									completion: { (_, error ) -> Void in
			if error != nil {
				print("\(String(describing: error))")
			}
		})
		
		session = nil
		pop()
	}
	
	func updateActivity() {
		guard let currentExercise = exercises["Item " + String(exerciseNumber)]! as? [String: String] else {
			return
		}
		
		workoutTitle.setText(String(currentExercise["itemName"]!))
	}
	
	override func didDeactivate() {
		timer.invalidate()
		if session != nil {
			session?.stopActivity(with: Date())
		}
	}
	
	func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {}
	
	func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {}
	
	func workoutSession(_ workoutSession: HKWorkoutSession, didGenerate event: HKWorkoutEvent) {}
}

//
//  WorkoutController.swift
//  core-x
//
//  Created by Ryan Cobelli on 4/18/16.
//  Copyright © 2016 Rybel LLC. All rights reserved.
//

import WatchKit

class WorkoutController: WKInterfaceController {

	var timer = NSTimer()
	
	
	@IBOutlet var group: WKInterfaceGroup!
	@IBOutlet var workoutTitle: WKInterfaceLabel!
	
	var exercises = NSDictionary()
	
	var workoutID = 0
	
	var timerRunning = true;
	var count = 0
	var exercise = 0
	
	var exerciseDuration = 0
	var restDuration = 0
	
	var exerciseID = -1
	
	override func awakeWithContext(context: AnyObject?) {
		
		workoutID = Int((context?.intValue)!)
		
		if let path = NSBundle.mainBundle().pathForResource("workout" + String(workoutID), ofType: "plist"), dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
			exercises = dict["exercises"] as! NSDictionary
			exerciseDuration = 30
			restDuration = 5
		}
		else {
			assertionFailure("Could Not Load .plist")
		}
		NSUserDefaults.standardUserDefaults().setObject(exercises, forKey: "exercises")
		
		timer = NSTimer.scheduledTimerWithTimeInterval(1.0,
		                                               target: self,
		                                               selector: #selector(WorkoutController.update),
		                                               userInfo: nil,
		                                               repeats: true)
		
		updateActivity()
		
		group.setBackgroundImageNamed("single")
		group.startAnimatingWithImagesInRange(NSMakeRange(0, 31), duration: 30.0, repeatCount: 1)
	}
	
	func update() {
		count = count + 1
		if count <= exerciseDuration {
			workoutTitle.setTextColor(UIColor.whiteColor())
		}
		else if count == exerciseDuration + 1 && exercise < exercises.count {
			exercise = exercise + 1
			if exercise < exercises.count {
				workoutTitle.setTextColor(UIColor.redColor())
				updateActivity()
				group.setBackgroundImageNamed("single0.png")
			}
			else {
				endWorkout()
			}
			WKInterfaceDevice.currentDevice().playHaptic(.Start)
		}
		else if count < exerciseDuration + restDuration {
			// Just catching something BS from triggering below
		}
		else if (exercise < exercises.count) {
			count = 0
			
			WKInterfaceDevice.currentDevice().playHaptic(.Start)
			group.setBackgroundImageNamed("single")
			group.startAnimatingWithImagesInRange(NSMakeRange(0, 31), duration: 30.0, repeatCount: 1)
		}
		else {
			endWorkout()
		}
	}
	
	func endWorkout() {
		WKInterfaceDevice.currentDevice().playHaptic(.Stop)
		WKInterfaceController.reloadRootControllersWithNames(["Root"], contexts: nil)
		timer.invalidate()
	}
	
	func updateActivity() {
		exerciseID = exerciseID + 1
		
		let exercises = NSUserDefaults.standardUserDefaults().dictionaryForKey("exercises")!
		let currentExercise = exercises["Item " + String(exerciseID)]!
		
		workoutTitle.setText(String(currentExercise["itemName"]!!))
	}
	
}

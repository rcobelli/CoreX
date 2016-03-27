//
//  WorkoutViewController.swift
//  core-x
//
//  Created by Ryan Cobelli on 1/17/16.
//  Copyright © 2016 Rybel LLC. All rights reserved.
//

import UIKit
import AudioToolbox

class TVWorkoutViewController: UIViewController {

	var workoutID = Int()
	var exerciseDuration = Int()
	var restDuration = Int()
	@IBOutlet weak var exerciseDescription: UILabel!
	@IBOutlet weak var exerciseTitle: UILabel!
	@IBOutlet weak var circleChart: RadialChart!
	@IBOutlet weak var timeLeft: UILabel!
	@IBOutlet weak var imageView: UIImageView!
	
	var timer = NSTimer()
	var timerRunning = true;
	var count = 0
	var exercise = 0
	
	var exerciseID = -1
	var time = 0
	
	var exercises = NSDictionary()
	var workoutName = String()
	
	var pauseAlert = UIAlertController()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		if let path = NSBundle.mainBundle().pathForResource("workout" + String(workoutID), ofType: "plist"), dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
			exercises = dict["exercises"] as! NSDictionary
			workoutName = dict["workoutName"] as! String
		}
		else {
			assertionFailure("Could Not Load .plist")
		}
		NSUserDefaults.standardUserDefaults().setObject(exercises, forKey: "exercises")
		
		if restDuration < 5 {
			restDuration = 5
		}
		
		if exerciseDuration < 3 {
			exerciseDuration = 3
		}
		
		timeLeft.text = String(exerciseDuration)
		circleChart.endArc = 1
		circleChart.arcWidth = 40.0
		circleChart.backgroundColor = UIColor.clearColor()
		exerciseID = exerciseID + 1
		
		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(TVWorkoutViewController.pauseWorkout))
		tapRecognizer.allowedPressTypes = [NSNumber(integer: UIPressType.PlayPause.rawValue)];
		self.view.addGestureRecognizer(tapRecognizer)
		
    }

	override func viewWillAppear(animated: Bool) {
		let exercises = NSUserDefaults.standardUserDefaults().dictionaryForKey("exercises")!
		let currentExercise = exercises["Item " + String(exerciseID)]!
		
		exerciseTitle.text = String(currentExercise["itemName"]!!)
		exerciseDescription.text = String(currentExercise["itemDescription"]!!)
		imageView.image = UIImage(named: String(currentExercise["itemImage"]!!))
	}
	
	override func viewWillDisappear(animated: Bool) {
		UIApplication.sharedApplication().idleTimerDisabled = false
		timer.invalidate()
	}
	
	override func viewDidAppear(animated: Bool) {
		UIApplication.sharedApplication().idleTimerDisabled = true
		
		timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(TVWorkoutViewController.update), userInfo: nil, repeats: true)
		
		self.navigationItem.title = NSLocalizedString("Exercise ", comment: "") + String(exercise+1) + "/" + String(exercises.count)
		NSUserDefaults.standardUserDefaults().setInteger(exercise, forKey: "workoutID")
		NSNotificationCenter.defaultCenter().postNotificationName("updateInfo", object: nil)
	}
	
	func pauseWorkout() {
		pauseAlert.dismissViewControllerAnimated(true, completion: nil)
		if timerRunning {
			pauseAlert = UIAlertController(title: NSLocalizedString("Workout Paused", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.Alert)
			pauseAlert.addAction(UIAlertAction(title: NSLocalizedString("Unpause", comment: ""), style: UIAlertActionStyle.Default, handler: { _ in
				self.pauseWorkout()
			}))
			self.presentViewController(pauseAlert, animated: true, completion: nil)
			timer.invalidate()
		}
		else {
			timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(TVWorkoutViewController.update), userInfo: nil, repeats: true)
		}
		timerRunning = !timerRunning
	}
	
	func update() {
		count = count + 1
		if count <= exerciseDuration {
			updateTime()
		}
		else if count == exerciseDuration + 1 && exercise < exercises.count {
			self.navigationItem.title = NSLocalizedString("REST", comment: "")
			exercise = exercise + 1
			if exercise != exercises.count {
				rest()
				updateImage()
			}
			else {
				endWorkout()
			}
			playSound()
		}
		else if count < exerciseDuration + restDuration {
			// Not really doing much
			self.navigationItem.title = NSLocalizedString("REST", comment: "")
		}
		else if (exercise < exercises.count) {
			count = 0
			self.navigationItem.title = NSLocalizedString("Exercise", comment: "") + " " + String(exercise+1) + "/" + String(exercises.count)
			NSNotificationCenter.defaultCenter().postNotificationName("updateInfo", object: nil)
			updateTime()
			playSound()
		}
		else {
			endWorkout()
		}
	}
	
	func updateImage() {
		let exercises = NSUserDefaults.standardUserDefaults().dictionaryForKey("exercises")!
		let currentExercise = exercises["Item " + String(exercise)]!
		imageView.image = UIImage(named: String(currentExercise["itemImage"]!!))
	}
	
	func playSound() {
		AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
		let systemSoundID: SystemSoundID = 1052
		AudioServicesPlaySystemSound (systemSoundID)
//		print("Ding")
	}
	
	func endWorkout() {
		let today: NSDate = NSDate()
		let format = NSDateFormatter()
		format.dateFormat = "MM-dd-yyyy"
		NSUserDefaults.standardUserDefaults().setBool(true, forKey: format.stringFromDate(today))
		timer.invalidate()
		
		let alert = UIAlertController(title: NSLocalizedString("Workout Completed!", comment: ""), message: NSLocalizedString("Great job!", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "👍", style: UIAlertActionStyle.Default, handler: { _ in
			self.view.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
		}))
		self.presentViewController(alert, animated: true, completion: nil)
	}

	@IBAction func cancel(sender: AnyObject) {
		self.view.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
	}
	
	func rest() {
		time = -1
		circleChart.endArc = 1
		timeLeft.text = String(exerciseDuration)
		
		exerciseID = exerciseID + 1
		
		let exercises = NSUserDefaults.standardUserDefaults().dictionaryForKey("exercises")!
		let currentExercise = exercises["Item " + String(exerciseID)]!
		
		exerciseTitle.text = String(currentExercise["itemName"]!!)
		exerciseDescription.text = String(currentExercise["itemDescription"]!!)
	}
	
	func updateTime() {
		time = time + 1
		if exerciseDuration - time < 0 {
			circleChart.endArc = 0
			timeLeft.text = "0"
		}
		else {
			if NSProcessInfo.processInfo().arguments.contains("testing") {
				circleChart.endArc = 0.75
				timeLeft.text = "28"
			}
			else {
				circleChart.endArc = CGFloat(Float(exerciseDuration - time) / Float(exerciseDuration))
				timeLeft.text = String(exerciseDuration - time)
			}
		}
	}

}

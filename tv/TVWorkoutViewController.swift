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
	
	var workoutID = 0
	var restDuration = GlobalVariables.restDuration
	var workoutName = ""
	var exerciseDuration = GlobalVariables.exerciseDuration
	var exercises = NSDictionary()
	
	var seconds = 0
	var exerciseNumber = 0
	
	var timer : NSTimer?
	
	var workoutPaused = false
	
	@IBOutlet weak var circleChart: RadialChart!
	@IBOutlet weak var exerciseNameLabel: UILabel!
	@IBOutlet weak var nextExerciseImage: UIImageView!
	@IBOutlet weak var currentExerciseImage: UIImageView!
	@IBOutlet weak var timerLabel: UILabel!
	@IBOutlet weak var exerciseDescriptionTextView: UITextView!
	
	
	@IBOutlet weak var nextExerciseImageHeightConstraint: NSLayoutConstraint!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let path = NSBundle.mainBundle().pathForResource("workout" + String(workoutID), ofType: "plist"), dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
			workoutName = dict["workoutName"] as! String
			exercises = dict["exercises"] as! NSDictionary
		}
		else {
			assertionFailure("Could Not Load .plist")
		}
		
		if restDuration < 5 {
			restDuration = 5
		}
		else if restDuration > 60 {
			restDuration = 60
		}
		
		if exerciseDuration < 5 {
			exerciseDuration = 5
		}
		else if exerciseDuration > 60 {
			exerciseDuration = 60
		}
		
		updateExercise()
		timerLabel.text = "0:" + String(format: "%02d", exerciseDuration)
		timerLabel.alpha = 1
		
		
		let playPauseRecognizer = UITapGestureRecognizer(target: self, action: #selector(TVWorkoutViewController.pause))
		playPauseRecognizer.allowedPressTypes = [NSNumber(integer: UIPressType.PlayPause.rawValue)];
		self.view.addGestureRecognizer(playPauseRecognizer)
		
		let menuRecognizer = UITapGestureRecognizer(target: self, action: nil)
		menuRecognizer.allowedPressTypes = [NSNumber(integer: UIPressType.Menu.rawValue)];
		menuRecognizer.numberOfTapsRequired = 1
		self.view.addGestureRecognizer(menuRecognizer)
		
		UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
	}
	
	override func viewDidAppear(animated: Bool) {
		timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(TVWorkoutViewController.second), userInfo: nil, repeats: true)
	}
	
	func second() {
		
		seconds += 1
		
		if seconds < exerciseDuration {
			// Still during exercise
			timerLabel.alpha = 1
			timerLabel.text = "0:" + String(format: "%02d", exerciseDuration-seconds)
			
			circleChart.endArc = CGFloat(Float(seconds) / Float(exerciseDuration))
		}
		else if seconds == exerciseDuration {
			// Start rest
			circleChart.endArc = 0
			
			timerLabel.alpha = 0.33
			timerLabel.text = "0:" + String(format: "%02d", exerciseDuration)
			exerciseNumber += 1
			
			playSound()
			
			if exerciseNumber < exercises.count {
				updateExercise()
			}
			else {
				endWorkout()
			}
		}
		else if seconds == exerciseDuration + restDuration {
			// Start workout
			seconds = 0
			circleChart.endArc = 1
			playSound()
		}
	}
	
	func playSound() {
		AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
		let systemSoundID: SystemSoundID = 1052
		AudioServicesPlaySystemSound (systemSoundID)
	}
	
	
	func endWorkout() {
		timer!.invalidate()
		
		if NSCalendar.currentCalendar().isDateInToday((NSUserDefaults.standardUserDefaults().objectForKey("lastWorkout") as! NSDate)) {
			// Already saved
			print("Already Saved Today")
		}
		else if NSCalendar.currentCalendar().isDateInYesterday((NSUserDefaults.standardUserDefaults().objectForKey("lastWorkout") as! NSDate)) {
			// Update count
			NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "lastWorkout")
			NSUserDefaults.standardUserDefaults().setInteger(NSUserDefaults.standardUserDefaults().integerForKey("workoutCount")+1, forKey: "workoutCount")
			print("Update Count")
		}
		else {
			NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: "lastWorkout")
			NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "workoutCount")
			print("No Streak")
		}
		
		let alert = UIAlertController(title: NSLocalizedString("Workout Completed!", comment: ""), message: NSLocalizedString("Great job!", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "😊", style: UIAlertActionStyle.Default, handler: { _ in
			self.view.window?.rootViewController?.dismissViewControllerAnimated(true, completion:nil)
		}))
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	func updateExercise() {
		let data = exercises["Item " + String(exerciseNumber)] as! NSDictionary
		exerciseNameLabel.text = data["itemName"] as? String
		currentExerciseImage.image = UIImage(named: (data["itemImage"] as? String)!)
		exerciseDescriptionTextView.text = data["itemDescription"] as? String
		
		if let nextData = (exercises["Item " + String(exerciseNumber+1)] as? NSDictionary) {
			nextExerciseImage.image = UIImage(named: (nextData["itemImage"] as? String)!)
		}
		else {
			nextExerciseImageHeightConstraint.constant = 0
			UIView.animateWithDuration(0.25) {
				self.view.layoutIfNeeded()
			}
		}
		
	}
	
	func pause() {
		timer?.invalidate()
		let alert = UIAlertController(title: NSLocalizedString("Workout Paused", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: NSLocalizedString("Resume Workout", comment: ""), style: UIAlertActionStyle.Default, handler: { _ in
			self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(TVWorkoutViewController.second), userInfo: nil, repeats: true)
		}))
		alert.addAction(UIAlertAction(title: NSLocalizedString("Stop Workout", comment: ""), style: UIAlertActionStyle.Default, handler: { _ in
			self.dismissViewControllerAnimated(true, completion: nil)
		}))
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
}

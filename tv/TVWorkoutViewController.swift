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
	
	public var workoutID = 0
	public var restDuration = 0
	public var exerciseDuration = 0
	
	var exercises = NSDictionary()
	
	var seconds = 0
	var exerciseNumber = 0
	
	var timer: Timer?
	
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
		
		let path = Bundle.main.path(forResource: "workout" + String(workoutID), ofType: "plist")
		guard let dict = NSDictionary(contentsOfFile: path!) as? [String: AnyObject],
			  let exercises = dict["exercises"] as? NSDictionary
		else {
			fatalError("Could Not Load Valid .plist")
		}
		
		view.backgroundColor = UIColor(named: "CustomBG")
		
		self.exercises = exercises
		
		updateExercise()
		timerLabel.text = String(format: "%01d:%02d", (exerciseDuration / 60), (exerciseDuration % 60))
		timerLabel.alpha = 1
		
		let playPauseRecognizer = UITapGestureRecognizer(target: self, action: #selector(TVWorkoutViewController.pause))
		playPauseRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue as Int)]
		self.view.addGestureRecognizer(playPauseRecognizer)
		
		let menuRecognizer = UITapGestureRecognizer(target: self, action: #selector(TVWorkoutViewController.menuButton))
		menuRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue as Int)]
		self.view.addGestureRecognizer(menuRecognizer)
		
		UIApplication.shared.beginReceivingRemoteControlEvents()
		
		UIApplication.shared.isIdleTimerDisabled = true
	}
	
	override func viewDidAppear(_ animated: Bool) {
		timer = Timer.scheduledTimer(timeInterval: 1,
									 target: self,
									 selector: #selector(TVWorkoutViewController.second),
									 userInfo: nil,
									 repeats: true)
	}
	
	@objc func second() {
		
		seconds += 1
		
		if seconds < exerciseDuration {
			// Still during exercise
			timerLabel.alpha = 1
			timerLabel.text = String(format: "%01d:%02d", ((exerciseDuration-seconds) / 60), ((exerciseDuration-seconds) % 60))
			
			circleChart.endArc = CGFloat(Float(seconds) / Float(exerciseDuration))
		} else if seconds == exerciseDuration {
			// Start rest
			circleChart.endArc = 0
			
			timerLabel.alpha = 0.33
			timerLabel.text = String(format: "%01d:%02d", (exerciseDuration / 60), (exerciseDuration % 60))
			exerciseNumber += 1
			
			playSound()
			
			if exerciseNumber < exercises.count {
				updateExercise()
			} else {
				endWorkout()
			}
		} else if seconds == exerciseDuration + restDuration {
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
		UIApplication.shared.isIdleTimerDisabled = false
		
		let alert = UIAlertController(title: "Workout Completed!",
									  message: "Great job!",
									  preferredStyle: UIAlertController.Style.alert)
		alert.addAction(UIAlertAction(title: "Finish", style: UIAlertAction.Style.default, handler: { _ in
			self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
		}))
		self.present(alert, animated: true, completion: nil)
	}
	
	func updateExercise() {
		guard let data = exercises["Item " + String(exerciseNumber)] as? NSDictionary else {
			return
		}
		exerciseNameLabel.text = data["itemName"] as? String
		currentExerciseImage.image = UIImage(named: (data["itemImage"] as? String)!)
		exerciseDescriptionTextView.text = data["itemDescription"] as? String
		
		if let nextData = (exercises["Item " + String(exerciseNumber+1)] as? NSDictionary) {
			nextExerciseImage.image = UIImage(named: (nextData["itemImage"] as? String)!)
		} else {
			nextExerciseImageHeightConstraint.constant = 0
			UIView.animate(withDuration: 0.25, animations: {
				self.view.layoutIfNeeded()
			}) 
		}
		
	}
	
	@objc func menuButton() {
		timer?.invalidate()
		UIApplication.shared.isIdleTimerDisabled = false
		self.dismiss(animated: true, completion: nil)
	}
	
	@objc func pause() {
		timer?.invalidate()
		let alert = UIAlertController(title: "Workout Paused",
									  message: nil,
									  preferredStyle: UIAlertController.Style.alert)
		alert.addAction(UIAlertAction(title: "Resume Workout",
									  style: UIAlertAction.Style.default,
									  handler: { _ in
			self.timer = Timer.scheduledTimer(timeInterval: 1,
											  target: self,
											  selector: #selector(TVWorkoutViewController.second),
											  userInfo: nil,
											  repeats: true)
		}))
		alert.addAction(UIAlertAction(title: "Stop Workout" ,
									  style: UIAlertAction.Style.default,
									  handler: { _ in
			UIApplication.shared.isIdleTimerDisabled = false
			self.dismiss(animated: true, completion: nil)
		}))
		self.present(alert, animated: true, completion: nil)
	}
	
}

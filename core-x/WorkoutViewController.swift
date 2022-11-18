//
//  WorkoutViewController.swift
//  core-x
//
//  Created by Ryan Cobelli on 12/12/15.
//  Copyright © 2015 Rybel LLC. All rights reserved.
//

import UIKit
import MediaPlayer

class WorkoutViewController: UIViewController {
	
	var myMusicPlayer = MPMusicPlayerController.systemMusicPlayer
	
	// Passed in from presenting VC
	public var workoutID = 0
	public var restDuration = 0
	public var exerciseDuration = 0
	
	var workoutName = ""
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
	@IBOutlet weak var forwardButton: UIButton!
	@IBOutlet weak var playPauseButton: UIButton!
	@IBOutlet weak var backwardButton: UIButton!
	@IBOutlet weak var seperator: UIView!
	@IBOutlet weak var exerciseDescriptionTextView: UITextView!
	@IBOutlet weak var moreInfoView: UIView! {
		didSet {
			moreInfoView.layer.cornerRadius = 10
		}
	}
	@IBOutlet weak var pauseStopButton: UIButton! {
		didSet {
			pauseStopButton.layer.cornerRadius = 10
			pauseStopButton.titleLabel?.numberOfLines = 2
			pauseStopButton.titleLabel?.textAlignment = .center
		}
	}
	@IBOutlet weak var resumeButton: UIButton! {
		didSet {
			resumeButton.layer.cornerRadius = 10
			resumeButton.titleLabel?.numberOfLines = 2
			resumeButton.titleLabel?.textAlignment = .center
		}
	}
	
	@IBOutlet weak var popupHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var stopButtonWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var nextExerciseImageHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var bottomConstraint: NSLayoutConstraint!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let path = Bundle.main.path(forResource: "workout" + String(workoutID), ofType: "plist")
		guard let dict = NSDictionary(contentsOfFile: path!) as? [String: AnyObject],
			  let workoutName = dict["workoutName"] as? String,
			  let exercises = dict["exercises"] as? NSDictionary
		else {
			fatalError("Could Not Load Valid .plist")
		}
		
		self.workoutName = workoutName
		self.exercises = exercises
		
		moreInfoView.isHidden = true
		moreInfoView.alpha = 0
		
		stopButtonWidthConstraint.constant = 210
		resumeButton.alpha = 0
		
		timerLabel.text = "0:" + String(format: "%02d", exerciseDuration)
		timerLabel.alpha = 1
		
		updateExercise()
		
		UIApplication.shared.isIdleTimerDisabled = true
		navigationItem.hidesBackButton = true
		navigationItem.title = workoutName
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if self.moreInfoView.isHidden {
			UIView.animate(withDuration: 0.125, animations: {
				self.moreInfoView.isHidden = false
				self.moreInfoView.alpha = 1
			}) 
		} else {
			UIView.animate(withDuration: 0.125, animations: {
				self.moreInfoView.alpha = 0
				}, completion: { _ in
					self.moreInfoView.isHidden = true
			})
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		timer = Timer.scheduledTimer(timeInterval: 1,
									 target: self,
									 selector: #selector(WorkoutViewController.second),
									 userInfo: nil,
									 repeats: true)
		
		// Alert the user about the issue with low power mode
		if ProcessInfo.processInfo.isLowPowerModeEnabled {
			let alertController = UIAlertController(title: "Low Power Mode",
													message: "Please turn off Low Power Mode so that we can keep the screen on the whole time",
													preferredStyle: .alert)
			let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
			alertController.addAction(action)
			self.present(alertController, animated: true, completion: nil)
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		timer?.invalidate()
		
		UIApplication.shared.isIdleTimerDisabled = false
	}
	
	@objc func second() {
		seconds += 1
		
		if seconds < exerciseDuration {
			// Still during exercise
			timerLabel.alpha = 1
			timerLabel.text = "0:" + String(format: "%02d", exerciseDuration-seconds)
			
			self.circleChart.endArc = CGFloat(Float(self.seconds) / Float(self.exerciseDuration))
		} else if seconds == exerciseDuration {
			// Start rest
			circleChart.endArc = 0
			
			timerLabel.alpha = 0.33
			timerLabel.text = "0:" + String(format: "%02d", exerciseDuration)
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
		
		let alertController = UIAlertController(title: "Workout Completed!", message: "Great job!", preferredStyle: .alert)
		let action = UIAlertAction(title: "Finish", style: .default) { (_) in
			self.navigationController?.popViewController(animated: true)
		}
		alertController.addAction(action)
		self.present(alertController, animated: true, completion: nil)

		HealthManager().saveWorkout(Double(self.exerciseDuration),
									workoutNumber: self.workoutID,
									completion: { (_, error ) -> Void in
			if error != nil {
				print("\(String(describing: error))")
			}
		})
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
		
		bottomConstraint.constant = 0
		UIView.animate(withDuration: 0.25, animations: {
			self.view.layoutIfNeeded()
		})
		
	}
	
	@IBAction func resumeAction(_ sender: AnyObject) {
		workoutPaused = false
		timer = Timer.scheduledTimer(timeInterval: 1,
									 target: self,
									 selector: #selector(WorkoutViewController.second),
									 userInfo: nil,
									 repeats: true)
		stopButtonWidthConstraint.constant = 210
		self.pauseStopButton.setTitle("Pause Workout", for: UIControl.State())

		UIView.animate(withDuration: 0.125, animations: {
			self.view.layoutIfNeeded()
			self.moreInfoView.alpha = 0
			self.resumeButton.alpha = 0
			}, completion: { _ in
				self.moreInfoView.isHidden = true
		})
		
	}
	
	@IBAction func pauseStopAction(_ sender: AnyObject) {
		workoutPaused = !workoutPaused
		if workoutPaused {
			timer?.invalidate()
			self.stopButtonWidthConstraint.constant = 100
			UIView.animate(withDuration: 0.125, animations: {
				self.pauseStopButton.setTitle("Stop Workout", for: UIControl.State())
				self.resumeButton.alpha = 1
				self.view.layoutIfNeeded()
			}) 
		} else {
			timer?.invalidate()
			navigationController?.popViewController(animated: true)
		}
	}
}

//
//  WorkoutViewController.swift
//  core-x
//
//  Created by Ryan Cobelli on 12/12/15.
//  Copyright © 2015 Rybel LLC. All rights reserved.
//

import UIKit
import Appodeal
import MediaPlayer

class WorkoutViewController: UIViewController, MPMediaPickerControllerDelegate {
	
	var myMusicPlayer: MPMusicPlayerController?
	
	var workoutID = GlobalVariables.exerciseID
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
	@IBOutlet weak var forwardButton: UIButton!
	@IBOutlet weak var backwardButton: UIButton!
	@IBOutlet weak var exerciseDescriptionTextView: UITextView!
	@IBOutlet weak var moreInfoView: UIView! {
		didSet {
			moreInfoView.layer.cornerRadius = 10
		}
	}
	@IBOutlet weak var pauseStopButton: UIButton! {
		didSet {
			pauseStopButton.layer.cornerRadius = 10
		}
	}
	@IBOutlet weak var resumeButton: UIButton! {
		didSet {
			resumeButton.layer.cornerRadius = 10
		}
	}
	
	
	@IBOutlet weak var resumeHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var forwardBottomSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var backwardBottomSpaceConstraint: NSLayoutConstraint!
	@IBOutlet weak var nextExerciseImageHeightConstraint: NSLayoutConstraint!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let myMediaQuery = MPMediaQuery.songsQuery()
		let playlistName = NSUserDefaults.standardUserDefaults().stringForKey("playlistName")
		if (playlistName != nil) {
			let predicateFilter = MPMediaPropertyPredicate(value: playlistName, forProperty: MPMediaPlaylistPropertyName)
			myMediaQuery.filterPredicates = NSSet(object: predicateFilter) as? Set<MPMediaPredicate>
			myMusicPlayer = MPMusicPlayerController()
			myMusicPlayer!.setQueueWithQuery(myMediaQuery)
			myMusicPlayer?.play()
		}
		
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
		
		moreInfoView.hidden = true
		moreInfoView.alpha = 0
		
		
		resumeHeightConstraint.constant = 0
		resumeButton.alpha = 0
		
		updateExercise()
		timerLabel.text = "0:" + String(format: "%02d", exerciseDuration)
		timerLabel.alpha = 1
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if self.moreInfoView.hidden {
			UIView.animateWithDuration(0.25) {
				self.moreInfoView.hidden = false
				self.moreInfoView.alpha = 1
			}
		}
		else {
			UIView.animateWithDuration(0.25, animations: {
				self.moreInfoView.alpha = 0
				}, completion: { _ in
					self.moreInfoView.hidden = true
			})
		}
	}

	override func viewDidAppear(animated: Bool) {
		timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(WorkoutViewController.second), userInfo: nil, repeats: true)
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
		

		let alertView = SCLAlertView()
		alertView.showCloseButton = false
		alertView.addButton(NSLocalizedString("Share On Social Media", comment: "")) {
			NSUserDefaults.standardUserDefaults().setObject(self.workoutName, forKey: "workoutName")
			NSUserDefaults.standardUserDefaults().synchronize()
			self.view.window?.rootViewController?.dismissViewControllerAnimated(true, completion:{
				NSNotificationCenter.defaultCenter().postNotificationName("showMenu", object: nil)
			})
		}
		alertView.addButton(NSLocalizedString("Done", comment: "")) {
			if self.shouldDisplayAd() && Appodeal.isReadyForShowWithStyle(AppodealShowStyle.NonSkippableVideo) {
				Appodeal.showAd(AppodealShowStyle.NonSkippableVideo, rootViewController: self)
			}
			self.view.window?.rootViewController?.dismissViewControllerAnimated(true, completion:nil)
		}
		alertView.showSuccess(NSLocalizedString("Workout Completed!", comment: ""), subTitle: NSLocalizedString("Great job!", comment: ""))


		HealthManager().authorizeHealthKit { (authorized,  error) -> Void in
			if authorized {
				HealthManager().saveWorkout(Double(self.exerciseDuration), workoutNumber: self.workoutID, completion: { (success, error ) -> Void in
					if( success ) {
						print("Workout saved!")
					}
					else if( error != nil ) {
						print("\(error)")
					}
				})
			}
			else {
				print("HealthKit authorization denied!")
				if error != nil {
					print("\(error)")
				}
			}
		}
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
	
	@IBAction func resumeAction(sender: AnyObject) {
		workoutPaused = false
		timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(WorkoutViewController.second), userInfo: nil, repeats: true)
		resumeHeightConstraint.constant = 0
		self.forwardBottomSpaceConstraint.constant = 8
		self.backwardBottomSpaceConstraint.constant = 8
		self.pauseStopButton.setTitle(NSLocalizedString("Pause Workout", comment: ""), forState: UIControlState.Normal)

		UIView.animateWithDuration(0.25, animations: {
			self.view.layoutIfNeeded()
			self.moreInfoView.alpha = 0
			self.resumeButton.alpha = 0
			}, completion: { _ in
				self.moreInfoView.hidden = true
		})
		
	}
	
	@IBAction func pauseStopAction(sender: AnyObject) {
		workoutPaused = !workoutPaused
		if workoutPaused {
			timer?.invalidate()
			self.resumeHeightConstraint.constant = 50
			self.forwardBottomSpaceConstraint.constant = 38
			self.backwardBottomSpaceConstraint.constant = 38
			UIView.animateWithDuration(0.25) {
				self.pauseStopButton.setTitle(NSLocalizedString("Stop Workout", comment: ""), forState: UIControlState.Normal)
				self.resumeButton.alpha = 1
				self.view.layoutIfNeeded()
			}
		}
		else {
			timer?.invalidate()
			dismissViewControllerAnimated(true, completion: nil)
		}
	}
	
	@IBAction func forwardAction(sender: AnyObject) {
		myMusicPlayer?.skipToNextItem()
	}
	
	@IBAction func backwardAction(sender: AnyObject) {
		myMusicPlayer?.skipToPreviousItem()
	}
	
}
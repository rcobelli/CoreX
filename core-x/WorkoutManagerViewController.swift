//
//  WorkoutManagerViewController.swift
//  core-x
//
//  Created by Ryan Cobelli on 12/12/15.
//  Copyright © 2015 Rybel LLC. All rights reserved.
//

import UIKit
import AudioToolbox
import Appodeal

class WorkoutManagerViewController: UIViewController {
	
	var workoutID = Int()
	var exerciseDuration = Int()
	var restDuration = Int()
	
	var timer = NSTimer()
	var timerRunning = true;
	var count = 0
	var exercise = 0
	
	var alert = SweetAlert()
	
	var exercises = NSDictionary()
	var workoutName = String()
	
	@IBOutlet weak var pauseButton: UIBarButtonItem!
	
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
    }
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		let exercises = NSUserDefaults.standardUserDefaults().dictionaryForKey("exercises")!
		let currentExercise = exercises["Item " + String(exercise)]!
		alert.showAlert(String(currentExercise["itemName"]!!), subTitle: String(currentExercise["itemDescription"]!!), style: AlertStyle.CustomImag(imageFile: String(currentExercise["itemImage"]!!)))
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		alert.closeAlert(0)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func viewWillDisappear(animated: Bool) {
		UIApplication.sharedApplication().idleTimerDisabled = false
		timer.invalidate()
	}
	
	override func viewDidAppear(animated: Bool) {
		UIApplication.sharedApplication().idleTimerDisabled = true
		
		timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "update", userInfo: nil, repeats: true)
		
		self.navigationItem.title = NSLocalizedString("Exercise ", comment: "") + String(exercise+1) + "/" + String(exercises.count)
		NSUserDefaults.standardUserDefaults().setInteger(exercise, forKey: "workoutID")
		NSNotificationCenter.defaultCenter().postNotificationName("updateInfo", object: nil)
	}
	
	func update() {
		count = count + 1
		if count <= exerciseDuration {
			NSNotificationCenter.defaultCenter().postNotificationName("updateTime", object: nil)
		}
		else if count == exerciseDuration + 1 && exercise < exercises.count {
			self.navigationItem.title = NSLocalizedString("REST", comment: "")
			exercise = exercise + 1
			if exercise != exercises.count {
				NSNotificationCenter.defaultCenter().postNotificationName("rest", object: nil)
			}
			else {
				endWorkout()
			}
			playSound()
		}
		else if count < exerciseDuration + restDuration {
			self.navigationItem.title = NSLocalizedString("REST", comment: "")
		}
		else if (exercise < exercises.count) {
			count = 0
			self.navigationItem.title = NSLocalizedString("Exercise", comment: "") + " " + String(exercise+1) + "/" + String(exercises.count)
			NSNotificationCenter.defaultCenter().postNotificationName("updateInfo", object: nil)
			NSNotificationCenter.defaultCenter().postNotificationName("updateTime", object: nil)
			playSound()
		}
		else {
			endWorkout()
		}
	}
	
	func playSound() {
		AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
		let systemSoundID: SystemSoundID = 1052
		AudioServicesPlaySystemSound (systemSoundID)
	}
	
	func endWorkout() {
		let today: NSDate = NSDate()
		let format = NSDateFormatter()
		format.dateFormat = "MM-dd-yyyy"
		NSUserDefaults.standardUserDefaults().setBool(true, forKey: format.stringFromDate(today))
		timer.invalidate()
		
		let alertView = SCLAlertView()
		alertView.showCloseButton = false
		alertView.addButton(NSLocalizedString("Share with Friends", comment: "")) {
			NSUserDefaults.standardUserDefaults().setObject(self.workoutName, forKey: "workoutName")
			NSUserDefaults.standardUserDefaults().synchronize()
			self.view.window?.rootViewController?.dismissViewControllerAnimated(true, completion:{
				NSNotificationCenter.defaultCenter().postNotificationName("showMenu", object: nil)
			})
		}
		alertView.addButton(NSLocalizedString("Done", comment: "")) {
			if !NSUserDefaults.standardUserDefaults().boolForKey("removedAds") {
				Appodeal.showAd(AppodealShowStyle.NonSkippableVideo, rootViewController: self)
			}
			else {
				print("Ready for ad:" + String(Appodeal.isReadyForShowWithStyle(AppodealShowStyle.Interstitial)))
				print("Ads IAP:" + String(NSUserDefaults.standardUserDefaults().boolForKey("removedAds")))
			}
			self.view.window?.rootViewController?.dismissViewControllerAnimated(true, completion:nil)
		}
		alertView.showSuccess(NSLocalizedString("Workout Completed!", comment: ""), subTitle: NSLocalizedString("Great job!", comment: ""))
		
	}
	
	@IBAction func pause(sender: AnyObject) {
		if timerRunning {
			let alertView = SCLAlertView()
			alertView.showCloseButton = false
			alertView.addButton(NSLocalizedString("Unpause", comment: ""), target:self, selector:Selector("pause:"))
			alertView.showWait(NSLocalizedString("Workout Paused", comment: ""), subTitle: "")
			
			timer.invalidate()
			pauseButton.title = NSLocalizedString("Unpause", comment: "")
		}
		else {
			timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "update", userInfo: nil, repeats: true)
			pauseButton.title = NSLocalizedString("Pause", comment: "")
		}
		timerRunning = !timerRunning
	}
	
	@IBAction func cancel(sender: AnyObject) {
		self.view.window?.rootViewController?.dismissViewControllerAnimated(true, completion:{
			if !NSUserDefaults.standardUserDefaults().boolForKey("removedAds") {
				Appodeal.showAd(AppodealShowStyle.NonSkippableVideo, rootViewController: self)
			}
			else {
				print("Ready for ad:" + String(Appodeal.isReadyForShowWithStyle(AppodealShowStyle.Interstitial)))
				print("Ads IAP:" + String(NSUserDefaults.standardUserDefaults().boolForKey("removedAds")))
			}
		})
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "exerciseContainer" {
			let destination = segue.destinationViewController as! WorkoutContentViewController
			destination.workoutID = workoutID
			if exerciseDuration < 3 {
				destination.exerciseDuration = 3
			}
			else {
				destination.exerciseDuration = exerciseDuration
			}
		}
	}

}
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
	var count = 0
	var exercise = 0
	
	var alert = SweetAlert()
	
	var exercises = NSDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		if let path = NSBundle.mainBundle().pathForResource("workout" + String(workoutID), ofType: "plist"), dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
			exercises = dict["exercises"] as! NSDictionary
		}
		else {
			print("Could Not Load .plist")
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
		
		self.navigationItem.title = "Exercise " + String(exercise+1) + "/" + String(exercises.count)
		NSUserDefaults.standardUserDefaults().setInteger(exercise, forKey: "workoutID")
		NSNotificationCenter.defaultCenter().postNotificationName("updateInfo", object: nil)
	}
	
	func update() {
		count = count + 1
		if count <= exerciseDuration {
			NSNotificationCenter.defaultCenter().postNotificationName("updateTime", object: nil)
		}
		else if count == exerciseDuration + 1 && exercise < exercises.count-1 {
			self.navigationItem.title = "REST"
			exercise = exercise + 1
			NSNotificationCenter.defaultCenter().postNotificationName("rest", object: nil)
			AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
		}
		else if count < exerciseDuration + restDuration && exercise < exercises.count-1 {
			self.navigationItem.title = "REST"
		}
		else if (exercise < exercises.count-1) {
			count = 0
			self.navigationItem.title = "Exercise " + String(exercise+1) + "/" + String(exercises.count)
			NSNotificationCenter.defaultCenter().postNotificationName("updateInfo", object: nil)
			NSNotificationCenter.defaultCenter().postNotificationName("updateTime", object: nil)
			AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
		}
		else {
			let today: NSDate = NSDate()
			let format = NSDateFormatter()
			format.dateFormat = "MM-dd-yyyy"
			NSUserDefaults.standardUserDefaults().setBool(true, forKey: format.stringFromDate(today))
			timer.invalidate()
			self.view.window?.rootViewController?.dismissViewControllerAnimated(true, completion:{
				SweetAlert().showAlert("Workout Completed", subTitle: "Great job!", style: AlertStyle.Success)
				if !NSUserDefaults.standardUserDefaults().boolForKey("removedAds") {
					Appodeal.showAd(AppodealShowStyle.NonSkippableVideo, rootViewController: self)
				}
				else {
					print("Ready for ad:" + String(Appodeal.isReadyForShowWithStyle(AppodealShowStyle.Interstitial)))
					print("Ads IAP:" + String(NSUserDefaults.standardUserDefaults().boolForKey("removedAds")))
				}
			})
		}
	}
	
	@IBAction func cancel(sender: AnyObject) {
		self.view.window?.rootViewController?.dismissViewControllerAnimated(true, completion:nil)
		if !NSUserDefaults.standardUserDefaults().boolForKey("removedAds") {
			Appodeal.showAd(AppodealShowStyle.NonSkippableVideo, rootViewController: self)
		}
		else {
			print("Ready for ad:" + String(Appodeal.isReadyForShowWithStyle(AppodealShowStyle.Interstitial)))
			print("Ads IAP:" + String(NSUserDefaults.standardUserDefaults().boolForKey("removedAds")))
		}
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
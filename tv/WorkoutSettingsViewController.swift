//
//  WorkoutSettingsViewController.swift
//  core-x
//
//  Created by Ryan Cobelli on 1/17/16.
//  Copyright © 2016 Rybel LLC. All rights reserved.
//

import UIKit

class WorkoutSettingsViewController: UIViewController {

	@IBOutlet weak var exerciseDuration: UITextField!
	@IBOutlet weak var restDuration: UITextField!
	@IBOutlet weak var workoutDescription: UITextView!
	@IBOutlet weak var startButton: UIButton!
	
	var workoutID = Int()
	var dict = NSDictionary()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if let path = NSBundle.mainBundle().pathForResource("workout" + String(workoutID), ofType: "plist"), dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
			self.title = String(dict["workoutName"]!)
			workoutDescription.text = String(dict["workoutDescription"]!)
			exerciseDuration.text = String(dict["defaultExerciseDuration"]!)
			restDuration.text = String(dict["defaultRestDuration"]!)
		}
		else {
			assertionFailure("Could Not Load .plist")
		}
    }
	
	override var preferredFocusedView: UIView? {
		get {
			return self.startButton
		}
	}

	@IBAction func cancel(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	@IBAction func start(sender: AnyObject) {
		print("Start")
		
		guard let exerciseDurationUnwrapped = exerciseDuration.text else {
			let alert = UIAlertController(title: NSLocalizedString("All Fields Required", comment: ""), message: NSLocalizedString("You must provide an exercise duration bigger than 0", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
			alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
			self.presentViewController(alert, animated: true, completion: nil)
			return
		}
		guard let restDurationUnwrapped = restDuration.text else {
			let alert = UIAlertController(title: NSLocalizedString("All Fields Required", comment: ""), message: NSLocalizedString("You must provide a rest duration greater than or equal to 0", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
			alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
			self.presentViewController(alert, animated: true, completion: nil)
			return
		}
		guard Int(exerciseDurationUnwrapped) > 0 else {
			let alert = UIAlertController(title: NSLocalizedString("All Fields Required", comment: ""), message: NSLocalizedString("You must provide an exercise duration bigger than 0", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
			alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
			self.presentViewController(alert, animated: true, completion: nil)
			return
		}
		guard Int(restDurationUnwrapped) >= 0 else {
			let alert = UIAlertController(title: NSLocalizedString("All Fields Required", comment: ""), message: NSLocalizedString("You must provide a rest duration greater than or equal to 0", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
			alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
			self.presentViewController(alert, animated: true, completion: nil)
			return
		}
		
		self.performSegueWithIdentifier("startWorkout", sender: self)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "startWorkout" {
			let navVC = segue.destinationViewController as! UINavigationController
			let tableVC = navVC.topViewController as! TVWorkoutViewController
			tableVC.workoutID = workoutID
			tableVC.exerciseDuration = Int(exerciseDuration.text!)!
			tableVC.restDuration = Int(restDuration.text!)!
		}
		
	}

}

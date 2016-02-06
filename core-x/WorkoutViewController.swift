//
//  WorkoutViewController.swift
//  core-x
//
//  Created by Ryan Cobelli on 12/12/15.
//  Copyright © 2015 Rybel LLC. All rights reserved.
//

import UIKit

class WorkoutViewController: UIViewController, UITextFieldDelegate {

	var workoutID = Int()
	var dict = NSDictionary()

	@IBOutlet weak var workoutName: UILabel!
	@IBOutlet weak var exerciseDuration: UITextField!
	@IBOutlet weak var restDuration: UITextField!
	@IBOutlet weak var startButton: UIButton!
	@IBOutlet weak var workoutDescription: UITextView!
	
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if let path = NSBundle.mainBundle().pathForResource("workout" + String(workoutID), ofType: "plist"), dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
			workoutName.text = String(dict["workoutName"]!)
			workoutDescription.text = String(dict["workoutDescription"]!)
			exerciseDuration.text = String(dict["defaultExerciseDuration"]!)
			restDuration.text = String(dict["defaultRestDuration"]!)
		}
		else {
			assertionFailure("Could Not Load .plist")
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		self.view.endEditing(true)
	}
	
	@IBAction func cancel(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	@IBAction func start(sender: AnyObject) {
		self.view.endEditing(true)
		
		guard let exerciseDurationUnwrapped = exerciseDuration.text else {
			SweetAlert().showAlert(NSLocalizedString("All Fields Required", comment: ""), subTitle: NSLocalizedString("You must provide an exercise duration bigger than 0", comment: ""), style: AlertStyle.Error)
			return
		}
		guard let restDurationUnwrapped = restDuration.text else {
			SweetAlert().showAlert(NSLocalizedString("All Fields Required", comment: ""), subTitle: NSLocalizedString("You must provide a rest duration greater than or equal to 0", comment: ""), style: AlertStyle.Error)
			return
		}
		guard Int(exerciseDurationUnwrapped) > 0 else {
			SweetAlert().showAlert(NSLocalizedString("All Fields Required", comment: ""), subTitle: NSLocalizedString("You must provide an exercise duration bigger than 0", comment: ""), style: AlertStyle.Error)
			return
		}
		guard Int(restDurationUnwrapped) >= 0 else {
			SweetAlert().showAlert(NSLocalizedString("All Fields Required", comment: ""), subTitle: NSLocalizedString("You must provide a rest duration greater than or equal to 0", comment: ""), style: AlertStyle.Error)
			return
		}
		if !NSUserDefaults.standardUserDefaults().boolForKey("firstWorkout") && !NSProcessInfo.processInfo().arguments.contains("testing") {
			SweetAlert().showAlert(NSLocalizedString("See Exercise Demonstration", comment: ""), subTitle: NSLocalizedString("Tap and hold the screen to see an image demonstrating the exercise", comment: ""), style: AlertStyle.None, buttonTitle: NSLocalizedString("Begin Workout", comment: ""), action: {(isOtherButton) -> Void in
				self.performSegueWithIdentifier("startWorkout", sender: self)
				NSUserDefaults.standardUserDefaults().setBool(true, forKey: "firstWorkout")
			})
		}
		else {
			self.performSegueWithIdentifier("startWorkout", sender: self)
		}

		
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "startWorkout" {
			let navVC = segue.destinationViewController as! UINavigationController
			let tableVC = navVC.topViewController as! WorkoutManagerViewController
			tableVC.workoutID = workoutID
			tableVC.exerciseDuration = Int(exerciseDuration.text!)!
			tableVC.restDuration = Int(restDuration.text!)!
		}

	}
}

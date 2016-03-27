//
//  WorkoutContentViewController.swift
//  core-x
//
//  Created by Ryan Cobelli on 12/12/15.
//  Copyright © 2015 Rybel LLC. All rights reserved.
//

import UIKit
import Appodeal

class WorkoutContentViewController: UIViewController, LTMorphingLabelDelegate {
	
	@IBOutlet weak var exerciseTitle: LTMorphingLabel!
	@IBOutlet weak var exerciseDescription: UILabel!
	@IBOutlet weak var exerciseImage: UIImageView!
	@IBOutlet weak var circleChart: RadialChart!
	@IBOutlet weak var timeLeft: LTMorphingLabel!
	
	var workoutID = Int()
	var exerciseDuration = Int()
	
	var exerciseID = -1
	var time = 0

    override func viewDidLoad() {
        super.viewDidLoad()
		timeLeft.text = String(exerciseDuration)
		circleChart.endArc = 1
		exerciseID = exerciseID + 1
		
		exerciseTitle.morphingEffect = .Anvil
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WorkoutContentViewController.updateTime), name: "updateTime", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WorkoutContentViewController.rest), name: "rest", object: nil)
    }

	override func viewWillAppear(animated: Bool) {
		let exercises = NSUserDefaults.standardUserDefaults().dictionaryForKey("exercises")!
		let currentExercise = exercises["Item " + String(exerciseID)]!
		
		exerciseTitle.text = String(currentExercise["itemName"]!!)
		exerciseDescription.text = String(currentExercise["itemDescription"]!!)
	}
	
	override func viewDidAppear(animated: Bool) {
		if !NSUserDefaults.standardUserDefaults().boolForKey("removedAds") && !NSProcessInfo.processInfo().arguments.contains("testing") {
			Appodeal.showAd(AppodealShowStyle.BannerBottom, rootViewController: self)
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
		if exerciseDuration - time == -1 {
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
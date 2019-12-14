//
//  WorkoutViewController.swift
//  core-x
//
//  Created by Ryan Cobelli on 12/12/15.
//  Copyright © 2015 Rybel LLC. All rights reserved.
//

import UIKit
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
	
	var timer : Timer?
	
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
		
		if #available(iOS 13.0, *) {
			isModalInPresentation = true
		}
		
		if !ProcessInfo.processInfo.arguments.contains("testing") {
			let myMediaQuery = MPMediaQuery.songs()
			let playlistName = UserDefaults.standard.string(forKey: "playlistName")
			if (playlistName != nil) {
				let predicateFilter = MPMediaPropertyPredicate(value: playlistName, forProperty: MPMediaPlaylistPropertyName)
				myMediaQuery.filterPredicates = NSSet(object: predicateFilter) as? Set<MPMediaPredicate>
				myMusicPlayer = MPMusicPlayerController.systemMusicPlayer
				myMusicPlayer!.setQueue(with: myMediaQuery)
				if UserDefaults.standard.bool(forKey: "shuffleMusic") {
					myMusicPlayer!.shuffleMode = .songs
				}
				else {
					myMusicPlayer!.shuffleMode = .off
				}
				myMusicPlayer?.play()
				playPauseButton.isHidden = false
				forwardButton.isHidden = false
				backwardButton.isHidden = false
				seperator.isHidden = false
			}
			else {
				playPauseButton.isHidden = true
				forwardButton.isHidden = true
				backwardButton.isHidden = true
				seperator.isHidden = true
				popupHeightConstraint.constant = 163
			}
			
			if myMusicPlayer?.playbackState == .playing {
				playPauseButton.setImage(UIImage(named: "pause.png"), for: .normal)
			}
		}
		
		
		if let path = Bundle.main.path(forResource: "workout" + String(workoutID), ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
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
		
		moreInfoView.isHidden = true
		moreInfoView.alpha = 0
		
		
		stopButtonWidthConstraint.constant = 210
		resumeButton.alpha = 0
		
		updateExercise()
		timerLabel.text = "0:" + String(format: "%02d", exerciseDuration)
		timerLabel.alpha = 1
		
		UIApplication.shared.isIdleTimerDisabled = true
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if self.moreInfoView.isHidden {
			UIView.animate(withDuration: 0.25, animations: {
				self.moreInfoView.isHidden = false
				self.moreInfoView.alpha = 1
			}) 
		}
		else {
			UIView.animate(withDuration: 0.25, animations: {
				self.moreInfoView.alpha = 0
				}, completion: { _ in
					self.moreInfoView.isHidden = true
			})
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(WorkoutViewController.second), userInfo: nil, repeats: true)
		
		// Alert the user about the issue with low power mode
		if ProcessInfo.processInfo.isLowPowerModeEnabled {
			_ = SweetAlert().showAlert("Low Power Mode", subTitle: "You have low power mode turned on, this means that we can't keep the screen on for your whole workout. We recommend you turn off Low Power mode before continuing your workout.", style: AlertStyle.warning)
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
		
		let alertController = UIAlertController(title: NSLocalizedString("Workout Completed!", comment: ""), message: NSLocalizedString("Great job!", comment: ""), preferredStyle: .alert)
		let action = UIAlertAction(title: "Share on Social Media", style: .default) { (_) in
			GlobalVariables.workoutName = self.workoutName
			self.view.window?.rootViewController?.dismiss(animated: true, completion:{
				NotificationCenter.default.post(name: Notification.Name(rawValue: "workoutFinishedShare"), object: nil)
			})
		}
		alertController.addAction(action)
		let action2 = UIAlertAction(title: "Done", style: .default) { (_) in
			self.view.window?.rootViewController?.dismiss(animated: true, completion:{
				NotificationCenter.default.post(name: Notification.Name(rawValue: "workoutFinished"), object: nil)
			})
		}
		alertController.addAction(action2)
		self.present(alertController, animated: true, completion: nil)


		HealthManager().saveWorkout(Double(self.exerciseDuration), workoutNumber: self.workoutID, completion: { (success, error ) -> Void in
			if( success ) {
				print("Workout saved!")
			}
			else if( error != nil ) {
				print("\(String(describing: error))")
			}
		})
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
		timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(WorkoutViewController.second), userInfo: nil, repeats: true)
		stopButtonWidthConstraint.constant = 210
		self.pauseStopButton.setTitle(NSLocalizedString("Pause Workout", comment: ""), for: UIControl.State())

		UIView.animate(withDuration: 0.25, animations: {
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
			UIView.animate(withDuration: 0.25, animations: {
				self.pauseStopButton.setTitle(NSLocalizedString("Stop Workout", comment: ""), for: UIControl.State())
				self.resumeButton.alpha = 1
				self.view.layoutIfNeeded()
			}) 
		}
		else {
			timer?.invalidate()
			dismiss(animated: true, completion: nil)
		}
	}
	
	// MARK: - Music Controls
	
	@IBAction func playPauseAction(_ sender: AnyObject) {
		if myMusicPlayer?.playbackState == .playing {
			playPauseButton.setImage(UIImage(named: "play.png"), for: .normal)
			myMusicPlayer?.pause()
		}
		else {
			playPauseButton.setImage(UIImage(named: "pause.png"), for: .normal)
			myMusicPlayer?.play()
		}
	}
	
	@IBAction func forwardAction(_ sender: AnyObject) {
		myMusicPlayer?.skipToNextItem()
	}
	
	@IBAction func backwardAction(_ sender: AnyObject) {
		myMusicPlayer?.skipToPreviousItem()
	}
	
}

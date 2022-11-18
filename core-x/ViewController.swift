//
//  ViewController.swift
//  core-x
//
//  Created by Ryan Cobelli on 12/12/15.
//  Copyright © 2015 Rybel LLC. All rights reserved.
//

import UIKit
import MessageUI
import AVFoundation
import WatchConnectivity
import HealthKit
import Intents

class ViewController: UIViewController, AVAudioPlayerDelegate {

	@IBOutlet weak var tableView: UITableView!
	
	var selectedCellIndex = 0
	var keyboardHeight: CGFloat = 0.0
	
	var healthManager = HealthManager()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.tableFooterView = UIView()
		tableView.delegate = self
		tableView.dataSource = self
		
		// Register for keyboard notification (get keyboard height)
		NotificationCenter.default.addObserver(self,
											   selector: #selector(ViewController.keyboardWillShow),
											   name: UIResponder.keyboardWillShowNotification,
											   object: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		tableView.reloadData()
		ReviewKitHelper.displayReviewPrompt()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		if !UserDefaults.standard.bool(forKey: "firstLaunch") && !ProcessInfo.processInfo.arguments.contains("testing") {
			UserDefaults.standard.set(true, forKey: "firstLaunch")
			
			if HKHealthStore.isHealthDataAvailable() {
				// Check if they want to use health kit
				let alertController = UIAlertController(title: "Welcome to Core-X!",
														message: "Do you want to save your workouts to the Health app?",
														preferredStyle: .alert)
				let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { _ in
					self.healthManager.authorizeHealthKit()
				})
				alertController.addAction(yesAction)
				
				let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
				alertController.addAction(noAction)
				self.present(alertController, animated: true, completion: nil)
			}
		}
		
		// TODO: Send workout defaults to watch (rest & duration times)
		let data = ["workout1": UserDefaults.standard.bool(forKey: "workout1"),
		            "workout2": UserDefaults.standard.bool(forKey: "workout2"),
		            "workout3": UserDefaults.standard.bool(forKey: "workout3"),
		            "workout4": UserDefaults.standard.bool(forKey: "workout4"),
		            "workout5": UserDefaults.standard.bool(forKey: "workout5")]
		
		if WCSession.isSupported() {
			let watchSession = WCSession.default
			watchSession.delegate = self
			watchSession.activate()
			if watchSession.isPaired && watchSession.isWatchAppInstalled {
				do {
					try watchSession.updateApplicationContext(data)
				} catch let error as NSError {
					print(error.description)
				}
			}
		}
	}
	
	// Check if a workout has been unlocked or a trial is available
	func workoutUnlocked(_ identifier: Int) -> Bool {
		return UserDefaults.standard.bool(forKey: "workout" + String(identifier))
	}
	
	// Check if a trial is available for a workout
	func trialAvailable(identifier: Int) -> Bool {
		return !UserDefaults.standard.bool(forKey: "workout" + String(identifier) + "Trial")
	}
	
	func useTrial(identifier: Int) {
		UserDefaults.standard.set(true, forKey: "workout" + String(identifier) + "Trial")
		tableView.reloadData()
	}
	
	func startMostRecentWorkout() {
		guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? WorkoutCell else {
			return
		}
		cell.start(cell.button)
	}

	func registerSiriShortcut() {
		// Add to siri shortcuts
		let activity = NSUserActivity(activityType: "com.rybel-llc.core-x.startMostRecentWorkout")
		activity.title = "Start Workout"
		activity.isEligibleForSearch = true
		activity.isEligibleForPrediction = true
		activity.persistentIdentifier = NSUserActivityPersistentIdentifier("com.rybel-llc.core-x.startMostRecentWorkout")
		self.view.userActivity = activity
		activity.becomeCurrent()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		self.view.endEditing(true)
		
		if segue.identifier == "startWorkout" {
			guard let destination = segue.destination as? WorkoutViewController,
				  let selectedCell = self.tableView.cellForRow(at: IndexPath(row: selectedCellIndex, section: 0)) as? WorkoutCell
			else {
				return
			}
			
			destination.restDuration = Int(selectedCell.restDuration.text!)!
			destination.exerciseDuration = Int(selectedCell.exerciseDuration.text!)!
			destination.workoutID = selectedCellIndex
		}
	}
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
	// swiftlint:disable function_body_length
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? WorkoutCell else {
			fatalError("Unexpected cell found")
		}
		
		// Set cell information based on the workout
		
		let path = Bundle.main.path(forResource: "workout" + String(indexPath.row), ofType: "plist")
		guard let dict = NSDictionary(contentsOfFile: path!) as? [String: AnyObject],
			  let exercises = dict["exercises"] as? [String: [String: String]]
		else {
			fatalError("Could Not Load Valid .plist")
		}
		
		cell.title.text = String(describing: dict["workoutName"]!)
		cell.exerciseDuration.text = String(describing: dict["defaultExerciseDuration"]!)
		cell.restDuration.text = String(describing: dict["defaultRestDuration"]!)
		cell.itemCount.text = String(exercises.count)
		
		var list = ""
		for item in exercises {
			list += "-" + String((item.value["itemName"]!)) + "\n"
		}
		
		cell.workoutList.text = list
		cell.workoutList.scrollRangeToVisible(NSRange(location: 0, length: 0))
		cell.restDuration.delegate = self
		cell.exerciseDuration.delegate = self
		cell.icon.image = WorkoutDataManager.getWorkoutLogo(workoutID: indexPath.row)
		cell.backgroundColor = WorkoutDataManager.getWorkoutColor(workoutID: indexPath.row)
		cell.title.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
		
		// Style the cell if its unlocked or not
		let unlocked = workoutUnlocked(indexPath.row)
		cell.title.alpha = unlocked ? 1 : 0.5
		cell.icon.alpha = unlocked ? 1 : 0.25
		cell.itemCount.alpha = unlocked ? 1 : 0.25
		cell.itemLabel.alpha = unlocked ? 1 : 0.25
		cell.workoutList.alpha = unlocked ? 1 : 0.25
		cell.restDuration.isEnabled = unlocked
		cell.exerciseDuration.isEnabled = unlocked
		
		if unlocked {
			cell.button.setTitle("Start", for: .normal)
		} else if trialAvailable(identifier: indexPath.row) {
			cell.button.setTitle("Try", for: .normal)
		} else {
			cell.button.setTitle("Purchase", for: .normal)
		}
		
		// Completion block to start the workout
		cell.completion = {
			if self.workoutUnlocked(indexPath.row) {
				self.registerSiriShortcut()
				
				self.performSegue(withIdentifier: "startWorkout", sender: self)
			} else if self.trialAvailable(identifier: indexPath.row) {
				let alertController = UIAlertController(title: "You Don't Own This Workout",
														message: "But there is a free trial available. Do you want to try it?",
														preferredStyle: .alert)
				let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { _ in
					self.useTrial(identifier: indexPath.row)
					self.performSegue(withIdentifier: "startWorkout", sender: self)
				})
				alertController.addAction(yesAction)
				
				let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
				alertController.addAction(noAction)
				self.present(alertController, animated: true, completion: nil)
			} else {
				let alertController = UIAlertController(title: "You Don't Own This Workout",
														message: "Do you want to purchase it?",
														preferredStyle: .alert)
				let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { _ in
					self.buyWorkout(indexPath.row)
				})
				alertController.addAction(yesAction)
				
				let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
				alertController.addAction(noAction)
				self.present(alertController, animated: true, completion: nil)
			}
		}
		
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		// Grow the cell on selection
		if selectedCellIndex != indexPath.row {
			selectedCellIndex = indexPath.row
		}
		
		guard let cell = tableView.cellForRow(at: indexPath) as? WorkoutCell else {
			return
		}
		
		if workoutUnlocked(indexPath.row) {
			cell.button.setTitle("Start", for: .normal)
		} else if trialAvailable(identifier: indexPath.row) {
			cell.button.setTitle("Try", for: .normal)
		} else {
			cell.button.setTitle("Purchase", for: .normal)
		}
		
		self.view.endEditing(true)
		
		tableView.beginUpdates()
		tableView.endUpdates()
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if selectedCellIndex == indexPath.row {
			return 200
		}
		return 66
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return WorkoutDataManager.getWorkoutCount()
	}
}

extension ViewController: UITextFieldDelegate {
	@objc func keyboardWillShow(notification: Notification) {
		let userInfo: NSDictionary = notification.userInfo! as NSDictionary
		guard let keyboardFrame: NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as? NSValue else {
			return
		}
		let keyboardRectangle = keyboardFrame.cgRectValue
		keyboardHeight = keyboardRectangle.height
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		let contentInsets: UIEdgeInsets = UIEdgeInsets.init(top: tableView.contentInset.top,
															left: 0.0,
															bottom: keyboardHeight,
															right: 0.0)
		
		tableView.contentInset = contentInsets
		tableView.scrollIndicatorInsets = contentInsets
		
		var aRect: CGRect = self.view.frame
		aRect.size.height -= keyboardHeight
		if !aRect.contains(textField.frame.origin) {
			self.tableView.scrollRectToVisible(textField.frame, animated: true)
		}
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		let contentInsets: UIEdgeInsets = UIEdgeInsets.init(top: tableView.contentInset.top,
															left: 0.0,
															bottom: 0.0,
															right: 0.0)
		
		UIView.animate(withDuration: 0.2, animations: {
			self.tableView.contentInset = contentInsets
			self.tableView.scrollIndicatorInsets = contentInsets
		})
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
}

extension ViewController: WCSessionDelegate {
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

	func sessionDidBecomeInactive(_ session: WCSession) {}

	func sessionDidDeactivate(_ session: WCSession) {}
}

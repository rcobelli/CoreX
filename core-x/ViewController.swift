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

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate, UIDocumentInteractionControllerDelegate, UITextFieldDelegate, WCSessionDelegate  {

	@IBOutlet weak var tableView: UITableView!
	var workoutIDToSend = Int()
	var indexPath = IndexPath()
	var extendedCell : Int? = nil
	var trialHappening = false
	var keyboardHeight : CGFloat = 0.0
	
	var healthManager = HealthManager()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.tableFooterView = UIView()
		tableView.delegate = self
		tableView.dataSource = self
		
		
		// Register for keyboard notification (get keyboard height)
		NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		
		// Show share menu on completion of workout
		NotificationCenter.default.addObserver(self, selector: #selector(ViewController.postWorkout), name: NSNotification.Name(rawValue: "workoutFinished"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(ViewController.postWorkoutShare), name: NSNotification.Name(rawValue: "workoutFinishedShare"), object: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		tableView.reloadData()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		if trialHappening {
			trialHappening = false
			UserDefaults.standard.set(true, forKey: "workout" + String(GlobalVariables.exerciseID) + "Trial")
			self.performSegue(withIdentifier: "startWorkout", sender: self)
		}
		else if !UserDefaults.standard.bool(forKey: "firstLaunch") && !ProcessInfo.processInfo.arguments.contains("testing") {
			if HKHealthStore.isHealthDataAvailable() {
				// Check if they want to use health kit
				SweetAlert().showAlert(NSLocalizedString("Welcome to Core-X!", comment: ""),
				                       subTitle: NSLocalizedString("Quick question, want to save your workouts to the Health app?", comment: ""), style: AlertStyle.none,
				                       buttonTitle: "Yes", buttonColor: UIColor(red: 0.000, green: 0.718, blue: 0.573, alpha: 1.00),
				                       otherButtonTitle: "No", otherButtonColor:  UIColor(red: 0.933, green: 0.294, blue: 0.169, alpha: 1.00),
				                       action: { response in
										
										UserDefaults.standard.set(true, forKey: "firstLaunch")
										if response { // User taps yes
											self.healthManager.authorizeHealthKit()
										}
				})
			}
		}

		
		// MARK: - WatchConnectivity
		
		let data = ["workout1": UserDefaults.standard.bool(forKey: "workout1"),
		            "workout2": UserDefaults.standard.bool(forKey: "workout2"),
		            "workout3": UserDefaults.standard.bool(forKey: "workout3"),
		            "workout4": UserDefaults.standard.bool(forKey: "workout4"),
		            "workout5": UserDefaults.standard.bool(forKey: "workout5")]
		
		
		if WCSession.isSupported() { //makes sure Watch is supported
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
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		self.view.endEditing(true)
	}
	
	// MARK: - WCSession
	
	func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
		print("Activate session")
	}
	
	func sessionDidBecomeInactive(_ session: WCSession) {
		print("Inactivate session")
	}
	
	func sessionDidDeactivate(_ session: WCSession) {
		print("Deactivate session")
	}
	
	// MARK: - UITextFieldDelegate
	
	@objc func keyboardWillShow(notification: Notification) {
		let userInfo:NSDictionary = notification.userInfo! as NSDictionary
		let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
		let keyboardRectangle = keyboardFrame.cgRectValue
		keyboardHeight = keyboardRectangle.height
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		let contentInsets : UIEdgeInsets = UIEdgeInsets.init(top: tableView.contentInset.top, left: 0.0, bottom: keyboardHeight, right: 0.0)
		
		tableView.contentInset = contentInsets
		tableView.scrollIndicatorInsets = contentInsets
		
		var aRect : CGRect = self.view.frame
		aRect.size.height -= keyboardHeight
		if (!aRect.contains(textField.frame.origin)){
			self.tableView.scrollRectToVisible(textField.frame, animated: true)
		}
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		let contentInsets : UIEdgeInsets = UIEdgeInsets.init(top: tableView.contentInset.top, left: 0.0, bottom: 0.0, right: 0.0)
		
		UIView.animate(withDuration: 0.2, animations: {
			self.tableView.contentInset = contentInsets
			self.tableView.scrollIndicatorInsets = contentInsets
		})
	}
	
	// MARK: - Workout specific methods
	
	// Check if a workout has been unlocked or a trial is available
	func workoutUnlocked(_ identifier: Int) -> Bool {
		return UserDefaults.standard.bool(forKey: "workout" + String(identifier))
	}
	
	// Check if a trial is available for a workout
	func trialAvailable(identifier: Int) -> Bool {
		return !UserDefaults.standard.bool(forKey: "workout" + String(identifier) + "Trial")
	}
	
	// Share on social media
	@objc func postWorkoutShare() {
		let textToShare = NSLocalizedString("I just completed the ", comment: "") +
			GlobalVariables.workoutName + NSLocalizedString(" workout using Core-X (https://rybel-llc.com/core-x)!", comment: "")
		
		let workoutImageNamed = UIImage(named: "core-x")!
		let objectsToShare = [workoutImageNamed, textToShare] as [Any]
		let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
		
		present(activityVC, animated: true, completion: nil)
	}
	
	// Don't share on social media
	@objc func postWorkout() {
	}
	
	func startMostRecentWorkout() {
		let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! WorkoutCell
		cell.start(cell.button)
	}
	
	// MARK: - UITableView Methods

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! WorkoutCell
		
		// Set cell information based on the workout
		if let path = Bundle.main.path(forResource: "workout" + String(indexPath.row), ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
			cell.title.text = String(describing: dict["workoutName"]!)
			cell.exerciseDuration.text = String(describing: dict["defaultExerciseDuration"]!)
			cell.restDuration.text = String(describing: dict["defaultRestDuration"]!)
			cell.itemCount.text = String((dict["exercises"] as! NSDictionary).count)
			
			var list = ""
			for item in (dict["exercises"] as! Dictionary<String, Dictionary<String, String>>) {
				list += "-" + String((item.value["itemName"]!)) + "\n"
			}
			cell.workoutList.text = list
			cell.workoutList.scrollRangeToVisible(NSMakeRange(0, 0))
			
			cell.restDuration.delegate = self
			cell.exerciseDuration.delegate = self
		}
		else {
			assertionFailure("Could Not Load .plist")
		}
		
		switch indexPath.row {
		case 0:
			cell.icon.image = UIImage(named: "core-x")
			cell.backgroundColor = UIColor(red: 0.863, green: 0.820, blue: 0.282, alpha: 1.00) // #DCD148
			break
		case 1:
			cell.icon.image = UIImage(named: "myrtl")
			cell.backgroundColor = UIColor(red: 0.537, green: 0.612, blue: 0.612, alpha: 1.00) // #889C9C
			break
		case 2:
			cell.icon.image = UIImage(named: "leg-day")
			cell.backgroundColor = UIColor(red: 0.106, green: 0.557, blue: 0.839, alpha: 1.00) // #1B8ED5
			break
		case 3:
			cell.icon.image = UIImage(named: "pushup")
			cell.backgroundColor = UIColor(red: 0.173, green: 0.251, blue: 0.325, alpha: 1.00) // #2C4052
			break
		case 4:
			cell.icon.image = UIImage(named: "yoga")
			cell.backgroundColor = UIColor(red: 0.000, green: 0.718, blue: 0.573, alpha: 1.00) // #00B792
			break
		case 5:
			cell.icon.image = UIImage(named: "coachLiz")
			cell.backgroundColor = UIColor(red: 0.580, green: 0.290, blue: 0.675, alpha: 1.00) // #944AAC
			break
		default:
			break
		}

		cell.title.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
		
		// Style the cell if its unlocked or not
		if workoutUnlocked(indexPath.row) {
			cell.title.alpha = 1
			cell.icon.alpha = 1
			cell.itemCount.alpha = 1
			cell.itemLabel.alpha = 1
			cell.workoutList.alpha = 1
			cell.restDuration.isEnabled = true
			cell.exerciseDuration.isEnabled = true
			cell.button.setTitle("Start", for: .normal)
		}
		else {
			cell.title.alpha = 0.5
			cell.icon.alpha = 0.25
			cell.itemCount.alpha = 0.25
			cell.itemLabel.alpha = 0.25
			cell.workoutList.alpha = 0.25
			cell.restDuration.isEnabled = false
			cell.exerciseDuration.isEnabled = false
			if trialAvailable(identifier: indexPath.row) {
				cell.button.setTitle("Try", for: .normal)
			}
			else {
				cell.button.setTitle("Purchase", for: .normal)
			}
		}
		
		// Completion block to start the workout
		cell.completion = {
			
			if self.workoutUnlocked(indexPath.row) {
				
				// Add to siri shortcuts
				if #available(iOS 12.0, *) {
					let activity = NSUserActivity(activityType: "com.rybel-llc.core-x.startMostRecentWorkout")
					activity.title = "Start Workout"
					activity.isEligibleForSearch = true
					activity.isEligibleForPrediction = true
					activity.persistentIdentifier = NSUserActivityPersistentIdentifier("com.rybel-llc.core-x.startMostRecentWorkout")
					self.view.userActivity = activity
					activity.becomeCurrent()
				}
				
				GlobalVariables.exerciseID = indexPath.row
				self.performSegue(withIdentifier: "startWorkout", sender: self)
			}
			else if self.trialAvailable(identifier: indexPath.row) {
				SweetAlert().showAlert("You Don't Own This Workout", subTitle: "But there is a free trial available. Do you want to watch a video to use this workout?", style: AlertStyle.warning,
				                       buttonTitle: "Yes", buttonColor: UIColor(red: 0.000, green: 0.718, blue: 0.573, alpha: 1.00),
				                       otherButtonTitle: "No", otherButtonColor:  UIColor(red: 0.933, green: 0.294, blue: 0.169, alpha: 1.00),
				                       action: { response in
										if response { // User taps yes
											GlobalVariables.exerciseID = indexPath.row
											self.trialHappening = true
										}
				})
			}
			else {
				SweetAlert().showAlert("You Don't Own This Workout", subTitle: "Do you want to purchase it?", style: AlertStyle.warning,
				                       buttonTitle: "Yes", buttonColor: UIColor(red: 0.000, green: 0.718, blue: 0.573, alpha: 1.00),
				                       otherButtonTitle: "No", otherButtonColor:  UIColor(red: 0.933, green: 0.294, blue: 0.169, alpha: 1.00),
				                       action: { response in
										if response { // User taps yes
											self.buyWorkout(indexPath.row)
										}
				})
			}
		}
		
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		// Grow the cell on selection
		if extendedCell != indexPath.row {
			extendedCell = indexPath.row
		}
		
		if workoutUnlocked(indexPath.row) {
			(tableView.cellForRow(at: indexPath) as! WorkoutCell).button.setTitle("Start", for: .normal)
		}
		else if trialAvailable(identifier: indexPath.row) {
			(tableView.cellForRow(at: indexPath) as! WorkoutCell).button.setTitle("Try", for: .normal)
		}
		else {
			(tableView.cellForRow(at: indexPath) as! WorkoutCell).button.setTitle("Purchase", for: .normal)
		}
		
		self.view.endEditing(true)
		
		tableView.beginUpdates()
		tableView.endUpdates()
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if (extendedCell == indexPath.row) {
			return 200
		}
		return 66
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 6
	}

}

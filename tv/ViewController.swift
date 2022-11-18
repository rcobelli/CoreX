//
//  ViewController.swift
//  core-x
//
//  Created by Ryan Cobelli on 12/12/15.
//  Copyright © 2015 Rybel LLC. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyStoreKit

class ViewController: UIViewController, AVAudioPlayerDelegate, UITextFieldDelegate {
	
	@IBOutlet weak var tableView: UITableView!
	
	var selectedCellIndex = 0
	var keyboardHeight: CGFloat = 0.0
	
	var selectedExerciseDuration: String?
	var selectedRestDuration: String?
	
	var redColor = UIColor(named: "CustomRed")
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor(named: "CustomBG")
		
		tableView.tableFooterView = UIView()
		tableView.delegate = self
		tableView.dataSource = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		tableView.reloadData()
	}
	
	@IBAction func restorePurchases(_ sender: Any) {
		SwiftyStoreKit.restorePurchases(atomically: true) { results in
			if results.restoreFailedPurchases.count > 0 {
				print("Restore Failed: \(results.restoreFailedPurchases)")
				let alert = UIAlertController(title: "Restore Purchases",
											  message: "We were unable to restore your purchases. Please try again.",
											  preferredStyle: UIAlertController.Style.alert)
				alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
				self.present(alert, animated: true, completion: nil)
			} else if results.restoredPurchases.count > 0 {
				print("Restore Success: \(results.restoredPurchases)")
				for item in results.restoredPurchases {
					self.deliverProduct(item.productId)
				}
				let alert = UIAlertController(title: "Restore Purchases",
											  message: "Your purchases were successfully restored",
											  preferredStyle: UIAlertController.Style.alert)
				alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
				self.present(alert, animated: true, completion: nil)
			} else {
				let alert = UIAlertController(title: "Restore Purchases",
											  message: "There is nothing to restore",
											  preferredStyle: UIAlertController.Style.alert)
				alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
				self.present(alert, animated: true, completion: nil)
			}
		}
	}
	
	// Check if a workout has been unlocked or a trial is available
	func workoutUnlocked(_ identifier: Int) -> Bool {
		return UserDefaults.standard.bool(forKey: "workout" + String(identifier))
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		self.view.endEditing(true)
		
		if segue.identifier == "startWorkout" {
			guard let destination = segue.destination as? TVWorkoutViewController else {
				return
			}
			
			destination.restDuration = Int(selectedRestDuration!)!
			destination.exerciseDuration = Int(selectedExerciseDuration!)!
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
			  let exercises = dict["exercises"] as? NSDictionary
		else {
			fatalError("Could Not Load Valid .plist")
		}
		
		cell.title.text = String(describing: dict["workoutName"]!)
		cell.itemCount.text = String(exercises.count)
		cell.backgroundColor = WorkoutDataManager.getWorkoutColor(workoutID: indexPath.row)
		cell.icon.image = WorkoutDataManager.getWorkoutLogo(workoutID: indexPath.row)
		cell.icon.image = (cell.icon.image?.withRenderingMode(.alwaysTemplate))!
		cell.icon.tintColor = UIColor.white
		cell.title.textColor = UIColor.white
		
		// Style the cell if its unlocked or not
		let unlocked = workoutUnlocked(indexPath.row)
		cell.title.alpha = unlocked ? 1 : 0.5
		cell.icon.alpha = unlocked ? 1 : 0.25
		cell.itemCount.alpha = unlocked ? 1 : 0.25
		cell.itemLabel.alpha = unlocked ? 1 : 0.25
		
		if unlocked {
			cell.button.setTitle("Start", for: .normal)
		} else {
			cell.button.setTitle("Purchase", for: .normal)
		}
		
		// Completion block to start the workout
		cell.completion = {
			
			if self.workoutUnlocked(indexPath.row) {
				let alert = UIAlertController(title: cell.title.text,
											  message: "Please configure your workout (exercise and rest duration)",
											  preferredStyle: UIAlertController.Style.alert)
				alert.addAction(UIAlertAction(title: "Start Workout",
											  style: UIAlertAction.Style.default,
											  handler: { _ in
					let exerciseDurationTextField = alert.textFields![0] as UITextField
					let restDurationTextField = alert.textFields![1] as UITextField
					
					self.selectedExerciseDuration = exerciseDurationTextField.text!
					self.selectedRestDuration = restDurationTextField.text!
					self.performSegue(withIdentifier: "startWorkout", sender: self)
				}))
				alert.addTextField { (textField) in
					textField.placeholder = "Exercise Duration (sec.)"
					textField.keyboardType = .numberPad
					textField.text = String(describing: dict["defaultExerciseDuration"]!)
				}
				alert.addTextField { (textField) in
					textField.placeholder = "Rest Duration (sec.)"
					textField.keyboardType = .numberPad
					textField.text = String(describing: dict["defaultRestDuration"]!)
				}
				alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (_) in })
				self.present(alert, animated: true, completion: nil)
			} else {
				let alert = UIAlertController(title: "You Don't Own This Workout",
											  message: "Do you want to purchase it?",
											  preferredStyle: UIAlertController.Style.alert)
				alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { _ in
					self.buyWorkout(indexPath.row)
				}))
				alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
				self.present(alert, animated: true, completion: nil)
			}
		}
		
		cell.focusStyle = .custom
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		
		if let prevFocus = context.previouslyFocusedIndexPath {
			guard let cell = tableView.cellForRow(at: prevFocus) as?  WorkoutCell else {
				return
			}
			cell.backgroundColor = WorkoutDataManager.getWorkoutColor(workoutID: prevFocus.row)
			cell.title.textColor = UIColor.white
			cell.workoutList.textColor = UIColor.white
			cell.itemCount.textColor = UIColor.white
			cell.itemLabel.textColor = UIColor.white
			cell.icon.tintColor = UIColor.white
		}
		if let nextFoc = context.nextFocusedIndexPath {
			guard let cell = tableView.cellForRow(at: nextFoc) as? WorkoutCell else {
				return
			}
			cell.backgroundColor = redColor
			cell.title.textColor = UIColor.black
			cell.workoutList.textColor = UIColor.black
			cell.itemCount.textColor = UIColor.black
			cell.itemLabel.textColor = UIColor.black
			cell.icon.tintColor = UIColor.black
		}
		
		let indexPath = context.nextFocusedIndexPath
		
		if indexPath?.row != nil && selectedCellIndex != indexPath?.row {
			// Grow/Shrink the cell on selection
			selectedCellIndex = indexPath!.row
		}
		tableView.beginUpdates()
		tableView.endUpdates()
		
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		if workoutUnlocked(indexPath.row) {
			guard let cell = tableView.cellForRow(at: indexPath) as? WorkoutCell else {
				return
			}
			
			cell.completion()
		} else {
			buyWorkout(indexPath.row)
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if selectedCellIndex == indexPath.row {
			return 300
		}
		return 115
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return WorkoutDataManager.getWorkoutCount()
	}
}

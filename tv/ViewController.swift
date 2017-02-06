//
//  ViewController.swift
//  core-x
//
//  Created by Ryan Cobelli on 12/12/15.
//  Copyright © 2015 Rybel LLC. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate, UITextFieldDelegate  {
	
	@IBOutlet weak var tableView: UITableView!
	var workoutIDToSend = Int()
	var indexPath = IndexPath()
	var extendedCell : Int? = nil
	var keyboardHeight : CGFloat = 0.0
	var redColor = UIColor()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.tableFooterView = UIView()
		tableView.delegate = self
		tableView.dataSource = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		if isDarkMode() {
			view.backgroundColor = UIColor(red: 0.200, green: 0.224, blue: 0.243, alpha: 1.00)
			redColor = UIColor(red: 0.922, green: 0.239, blue: 0.212, alpha: 1.00)
		}
		else {
			view.backgroundColor = UIColor(red: 0.451, green: 0.624, blue: 0.710, alpha: 1.00)
			redColor = UIColor(red: 0.663, green: 0.176, blue: 0.173, alpha: 1.00)
		}
		
		tableView.reloadData()
	}

	
	@IBAction func restorePurchases(_ sender: Any) {
		SwiftyStoreKit.restorePurchases(atomically: true) { results in
			if results.restoreFailedProducts.count > 0 {
				print("Restore Failed: \(results.restoreFailedProducts)")
				let alert = UIAlertController(title: "Restore Purchases", message: "We were unable to restore your purchases. Please try again.", preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
				self.present(alert, animated: true, completion: nil)
			}
			else if results.restoredProducts.count > 0 {
				print("Restore Success: \(results.restoredProducts)")
				for item in results.restoredProducts {
					self.deliverProduct(item.productId)
				}
				let alert = UIAlertController(title: "Restore Purchases", message: "Your purchases were successfully restored", preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
				self.present(alert, animated: true, completion: nil)
			}
			else {
				let alert = UIAlertController(title: "Restore Purchases", message: "There is nothing to restore", preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
				self.present(alert, animated: true, completion: nil)
			}
		}
	}
	
	func cellBackgroundColor(_ indexPath: IndexPath) -> UIColor {
		switch indexPath.row {
		case 0:
			return UIColor(red: 0.863, green: 0.820, blue: 0.282, alpha: 1.00)
		case 1:
			return UIColor(red: 0.537, green: 0.612, blue: 0.612, alpha: 1.00)
		case 2:
			return UIColor(red: 0.106, green: 0.557, blue: 0.839, alpha: 1.00)
		case 3:
			return UIColor(red: 0.173, green: 0.251, blue: 0.325, alpha: 1.00)
		case 4:
			return UIColor(red: 0.000, green: 0.718, blue: 0.573, alpha: 1.00)
		case 5:
			return UIColor(red: 0.580, green: 0.290, blue: 0.675, alpha: 1.00)
		default:
			return UIColor.clear
		}
	}
	
	// Check if a workout has been unlocked or a trial is available
	func workoutUnlocked(_ identifier: Int) -> Bool {
		return UserDefaults.standard.bool(forKey: "workout" + String(identifier))
	}
	
	// MARK: - UITableView Methods
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! WorkoutCell
		
		var exerciseDurationVar : String?
		var restDurationVar : String?
		
		// Set cell information based on the workout
		if let path = Bundle.main.path(forResource: "workout" + String(indexPath.row), ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
			cell.title.text = String(describing: dict["workoutName"]!)
			exerciseDurationVar = String(describing: dict["defaultExerciseDuration"]!)
			restDurationVar = String(describing: dict["defaultRestDuration"]!)
			cell.itemCount.text = String((dict["exercises"] as! NSDictionary).count)
		}
		else {
			assertionFailure("Could Not Load .plist " + String(indexPath.row))
		}
		
		switch indexPath.row {
		case 0:
			cell.icon.image = UIImage(named: "core-x")
			break
		case 1:
			cell.icon.image = UIImage(named: "myrtl")
			break
		case 2:
			cell.icon.image = UIImage(named: "leg-day")
			break
		case 3:
			cell.icon.image = UIImage(named: "pushup")
			break
		case 4:
			cell.icon.image = UIImage(named: "yoga")
			break
		case 5:
			cell.icon.image = UIImage(named: "coachLiz")
			break
		default:
			break
		}
		
		cell.backgroundColor = cellBackgroundColor(indexPath)
		cell.icon.image = (cell.icon.image?.withRenderingMode(.alwaysTemplate))!
		cell.icon.tintColor = UIColor.white
		cell.title.textColor = UIColor.white
		
		// Style the cell if its unlocked or not
		if workoutUnlocked(indexPath.row) {
			cell.title.alpha = 1
			cell.icon.alpha = 1
			cell.itemCount.alpha = 1
			cell.itemLabel.alpha = 1
			cell.button.setTitle("Start Workout", for: .normal)
		}
		else {
			cell.title.alpha = 0.5
			cell.icon.alpha = 0.25
			cell.itemCount.alpha = 0.25
			cell.itemLabel.alpha = 0.25
			cell.button.setTitle("Purchase Workout", for: .normal)
		}
		
		// Completion block to start the workout
		cell.completion = {
			
			if self.workoutUnlocked(indexPath.row) {
				GlobalVariables.exerciseID = indexPath.row
				let alert = UIAlertController(title: cell.title.text, message: NSLocalizedString("Please configure your workout (exercise and rest duration)", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: NSLocalizedString("Start Workout", comment: ""), style: UIAlertActionStyle.default, handler: { _ in
					let exerciseDurationTextField = alert.textFields![0] as UITextField
					let restDurationTextField = alert.textFields![1] as UITextField
					
					GlobalVariables.exerciseDuration = Int(exerciseDurationTextField.text!)!
					GlobalVariables.restDuration = Int(restDurationTextField.text!)!
					self.performSegue(withIdentifier: "startWorkout", sender: self)
				}))
				alert.addTextField { (textField) in
					textField.placeholder = NSLocalizedString("Exercise Duration (sec.)", comment: "")
					textField.keyboardType = .numberPad
					textField.text = exerciseDurationVar
				}
				alert.addTextField { (textField) in
					textField.placeholder = NSLocalizedString("Rest Duration (sec.)", comment: "")
					textField.keyboardType = .numberPad
					textField.text = restDurationVar
				}
				alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (_) in })
				self.present(alert, animated: true, completion: nil)
				self.performSegue(withIdentifier: "startWorkout", sender: self)
			}
			else {
				let alert = UIAlertController(title: "You Don't Own This Workout", message: "Do you want to purchase it?", preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { _ in
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
			let cell = tableView.cellForRow(at: prevFocus) as! WorkoutCell
			cell.backgroundColor = cellBackgroundColor(prevFocus)
			cell.title.textColor = UIColor.white
			cell.workoutList.textColor = UIColor.white
			cell.itemCount.textColor = UIColor.white
			cell.itemLabel.textColor = UIColor.white
			cell.icon.tintColor = UIColor.white
		}
		if let nextFoc = context.nextFocusedIndexPath {
			let cell = tableView.cellForRow(at: nextFoc) as! WorkoutCell
			cell.backgroundColor = redColor
			cell.title.textColor = UIColor.black
			cell.workoutList.textColor = UIColor.black
			cell.itemCount.textColor = UIColor.black
			cell.itemLabel.textColor = UIColor.black
			cell.icon.tintColor = UIColor.black
		}
		
		
		let indexPath = context.nextFocusedIndexPath
		
		extendedCell = nil
		if indexPath?.row != nil && extendedCell != indexPath?.row {
			// Grow/Shrink the cell on selection
			extendedCell = indexPath?.row
		}
		tableView.beginUpdates()
		tableView.endUpdates()
		
		
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		if workoutUnlocked(indexPath.row) {
			(tableView.cellForRow(at: indexPath) as! WorkoutCell).completion()
		}
		else {
			buyWorkout(indexPath.row)
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if (extendedCell == indexPath.row) {
			return 300
		}
		return 115
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 6
	}
	
}

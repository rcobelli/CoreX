//
//  ViewController.swift
//  tv
//
//  Created by Ryan Cobelli on 1/10/16.
//  Copyright © 2016 Rybel LLC. All rights reserved.
//

import UIKit
import StoreKit
import AVFoundation


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver, SKRequestDelegate, AVAudioPlayerDelegate  {
	
	@IBOutlet weak var tableView: UITableView!
	var workoutIDToSend = Int()
	
	var justShowedAd = Bool()
	
	let numOfRows = 6
	
	let productIdentifiers = Set(["com.rybel_llc.core_x.remove_ads", "com.rybel_llc.core_x.myrtl", "com.rybel_llc.core_x.leg_day", "com.rybel_llc.core_x.pushups", "com.rybel_llc.core_x.yoga"])
	var product: SKProduct?
	var productsArray = Array<SKProduct>()
	
	var indexPath = IndexPath()
	
	var extendedCell : Int? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.tableFooterView = UIView()
		tableView.delegate = self
		tableView.dataSource = self
		
		// Init store kit
		SKPaymentQueue.default().add(self)
		requestProductData()
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		tableView.reloadData()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showWorkout" {
			
			let destination = segue.destination as! TVWorkoutViewController
			destination.workoutID = (tableView.indexPathForSelectedRow?.row)!
		}
	}
	
	// Check if a workout has been unlocked or a trial is available
	func workoutUnlocked(_ identifier: Int) -> Bool {
		if UserDefaults.standard.bool(forKey: String(describing: Bundle.main.infoDictionary!["CFBundleShortVersionString"])) {
			return true
		}
		return UserDefaults.standard.bool(forKey: "workout" + String(identifier))
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
	
	// MARK: - UITableView Methods
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		// Check if the barbell needs to be delt with
		if indexPath.row == numOfRows - 1 && !UserDefaults.standard.bool(forKey: "workout5") {
			let cell = tableView.dequeueReusableCell(withIdentifier: "SixPack", for: indexPath) as! SixPackCell
			
			// Check if streak is alive
			if Calendar.current.isDateInToday((UserDefaults.standard.object(forKey: "lastWorkout") as! Date)) || Calendar.current.isDateInYesterday((UserDefaults.standard.object(forKey: "lastWorkout") as! Date)) {
				cell.barbell.image = UIImage(named: String(UserDefaults.standard.integer(forKey: "workoutCount")))
			}
			else {
				cell.barbell.image = UIImage(named: "0")
			}
			
			if UserDefaults.standard.integer(forKey: "workoutCount") >= 5 {
				let alert = UIAlertController(title: NSLocalizedString("Barbell Completed", comment: ""), message: NSLocalizedString("You completed the barbell, tap the barbell anytime from now on to use an exclusive workout routine", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "Sweet", style: UIAlertActionStyle.default, handler: nil))
				self.present(alert, animated: true, completion: nil)
				
				UserDefaults.standard.set(true, forKey: "workout5")
			}
			
			cell.backgroundColor = UIColor.clear
			cell.focusStyle = .custom
			
			
			return cell;
		}
		
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! WorkoutCell
		
		var exerciseDurationVar : String?
		var restDurationVar : String?
		
		// Set cell information based on the workout
		if let path = Bundle.main.path(forResource: "workout" + String(indexPath.row), ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
			cell.title.text = String(describing: dict["workoutName"]!)
			
			exerciseDurationVar = String(describing: dict["defaultExerciseDuration"]!)
			restDurationVar = String(describing: dict["defaultRestDuration"]!)
			
			cell.itemCount.text = String((dict["exercises"] as! NSDictionary).count)
			
			var list = ""
			for item in (dict["exercises"] as! NSDictionary) {
				list += "-" + String((item.value["itemName"]!)!) + "\n"
			}
			cell.workoutList.text = list
			cell.workoutList.scrollRangeToVisible(NSMakeRange(0, 0))
		}
		else {
			assertionFailure("Could Not Load .plist")
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
		}
		else {
			cell.title.alpha = 0.5
			cell.icon.alpha = 0.25
			cell.itemCount.alpha = 0.25
			cell.itemLabel.alpha = 0.25
		}
		
		// Completion block to start the workout
		cell.completion = {
			print("Completion")
			
			
			let alert = UIAlertController(title: cell.title.text, message: NSLocalizedString("Please set how long you would like the workout to last", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
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
		}
		
		cell.focusStyle = .custom
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		
		if let prevFocus = context.previouslyFocusedIndexPath {
			if let cell = tableView.cellForRow(at: prevFocus) as? WorkoutCell {
				cell.backgroundColor = cellBackgroundColor(prevFocus)
				cell.title.textColor = UIColor.white
				cell.workoutList.textColor = UIColor.white
				cell.itemCount.textColor = UIColor.white
				cell.itemLabel.textColor = UIColor.white
				cell.icon.tintColor = UIColor.white
			}
			else if let cell = tableView.cellForRow(at: prevFocus) as? SixPackCell {
				cell.backgroundColor = UIColor.clear
			}
		}
		if let nextFoc = context.nextFocusedIndexPath {
			if let cell = tableView.cellForRow(at: nextFoc) as? WorkoutCell {
				cell.backgroundColor = UIColor(red: 0.922, green: 0.239, blue: 0.212, alpha: 1.00)
				cell.title.textColor = UIColor.black
				cell.workoutList.textColor = UIColor.black
				cell.itemCount.textColor = UIColor.black
				cell.itemLabel.textColor = UIColor.black
				cell.icon.tintColor = UIColor.black
			}
			else if let cell = tableView.cellForRow(at: nextFoc) as? SixPackCell {
				cell.backgroundColor = UIColor(red: 0.922, green: 0.239, blue: 0.212, alpha: 1.00)
			}
		}
		
		
		let indexPath = context.nextFocusedIndexPath
		
		extendedCell = nil
		if indexPath?.row != nil && workoutUnlocked(indexPath!.row) && extendedCell != indexPath?.row {
			// Grow/Shrink the cell on selection
			extendedCell = indexPath?.row
		}
		tableView.beginUpdates()
		tableView.endUpdates()
		
		
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		// Barbell handler
		if indexPath.row == numOfRows - 1 && !UserDefaults.standard.bool(forKey: "workout5") {
			let alert = UIAlertController(title: NSLocalizedString("Complete The Barbell", comment: ""), message: NSLocalizedString("Every consecuative day that you finish a workout, a plate is added to your barbell. Get all 6 plates to unlock an exclusive workout routine", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
			self.present(alert, animated: true, completion: nil)
		}
		else if workoutUnlocked(indexPath.row) {
			(tableView.cellForRow(at: indexPath) as! WorkoutCell).completion()
		}
		else {
			buyWorkout(indexPath.row)
		}
	}
	
	func buyWorkout(_ row: Int) {
		switch row {
		case 1:
			buyProduct(1)
			break
		case 2:
			buyProduct(0)
			break
		case 3:
			buyProduct(2)
			break
		case 4:
			buyProduct(4)
			break
		default:
			break
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == numOfRows - 1 {
			return 105
		}
		else if (extendedCell == indexPath.row) {
			return 300
		}
		return 105
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return numOfRows
	}
	
	
	// MARK: - StoreKit Methods
	
	func requestProductData() {
		if SKPaymentQueue.canMakePayments() {
			let request = SKProductsRequest(productIdentifiers: productIdentifiers as Set<String>)
			request.delegate = self
			request.start()
		}
		else {
			let alert = UIAlertController(title: NSLocalizedString("In-App Purchases Not Enabled", comment: ""),
			                              message: NSLocalizedString("Please enable In App Purchase in Settings", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: UIAlertActionStyle.default, handler: { alertAction in
				alert.dismiss(animated: true, completion: nil)
				
				let url: URL? = URL(string: UIApplicationOpenSettingsURLString)
				if url != nil
				{
					UIApplication.shared.openURL(url!)
				}
				
			}))
			alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { alertAction in
				alert.dismiss(animated: true, completion: nil)
			}))
			self.present(alert, animated: true, completion: nil)
		}
	}
	
	func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
		var products = response.products
		
		if (products.count != 0) {
			for i in 0 ..< products.count {
				product = products[i] as SKProduct
				productsArray.append(product!)
			}
		}
		else {
			print("No products found")
		}
		
		for product in response.invalidProductIdentifiers {
			print("Product not found: \(product)")
		}
	}
	
	func buyProduct(_ productID: Int) {
		if productsArray.count-1 >= productID {
			let payment = SKPayment(product: productsArray[productID])
			SKPaymentQueue.default().add(payment)
		}
		else {
			let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("We could not find the in app purchase you were looking for", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
			self.present(alert, animated: true, completion: nil)
		}
	}
	
	
	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		print("Processing Transaction")
		for transaction in transactions {
			
			switch transaction.transactionState {
				
			case SKPaymentTransactionState.purchased:
				print("Transaction Approved")
				print("Product Identifier: \(transaction.payment.productIdentifier)")
				deliverProduct(transaction.payment.productIdentifier)
				SKPaymentQueue.default().finishTransaction(transaction)
				
			case SKPaymentTransactionState.failed:
				print("Transaction Failed")
				SKPaymentQueue.default().finishTransaction(transaction)
			default:
				break
			}
		}
	}
	
	@IBAction func restorePurchases() {
		print("Restore Purchases")
		SKPaymentQueue.default().restoreCompletedTransactions()
		tableView.reloadData()
	}
	
	func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
		print("Transactions Restored")
		
		for transaction:SKPaymentTransaction in queue.transactions {
			deliverProduct(transaction.payment.productIdentifier)
		}
		
		let alert = UIAlertController(title: NSLocalizedString("Thank You", comment: ""), message: NSLocalizedString("Any purchases were restored.", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
	
}


extension UIViewController {
	func deliverProduct(_ identifier: String) {
		print("Identifier: " + identifier)
		if identifier == "com.rybel_llc.core_x.myrtl" {
			UserDefaults.standard.set(true, forKey: "workout1")
		}
		else if identifier == "com.rybel_llc.core_x.remove_ads" {
			UserDefaults.standard.set(true, forKey: "removedAds")
		}
		else if identifier == "com.rybel_llc.core_x.leg_day" {
			UserDefaults.standard.set(true, forKey: "workout2")
		}
		else if identifier == "com.rybel_llc.core_x.pushups" {
			UserDefaults.standard.set(true, forKey: "workout3")
		}
		else if identifier == "com.rybel_llc.core_x.yoga" {
			UserDefaults.standard.set(true, forKey: "workout4")
		}
		
		UserDefaults.standard.synchronize()
		viewWillAppear(true)
	}
}

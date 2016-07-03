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
	
	var indexPath = NSIndexPath()
	
	var extendedCell : Int? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.tableFooterView = UIView()
		tableView.delegate = self
		tableView.dataSource = self
		
		// Init store kit
		SKPaymentQueue.defaultQueue().addTransactionObserver(self)
		requestProductData()
	}
	
	
	override func viewWillAppear(animated: Bool) {
		tableView.reloadData()
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showWorkout" {
			
			let destination = segue.destinationViewController as! TVWorkoutViewController
			destination.workoutID = (tableView.indexPathForSelectedRow?.row)!
		}
	}
	
	// Check if a workout has been unlocked or a trial is available
	func workoutUnlocked(identifier: Int) -> Bool {
		if NSUserDefaults.standardUserDefaults().boolForKey(String(NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"])) {
			return true
		}
		return NSUserDefaults.standardUserDefaults().boolForKey("workout" + String(identifier))
	}
	
	func cellBackgroundColor(indexPath: NSIndexPath) -> UIColor {
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
			return UIColor.clearColor()
		}
	}
	
	// MARK: - UITableView Methods
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		// Check if the barbell needs to be delt with
		if indexPath.row == numOfRows - 1 && !NSUserDefaults.standardUserDefaults().boolForKey("workout5") {
			let cell = tableView.dequeueReusableCellWithIdentifier("SixPack", forIndexPath: indexPath) as! SixPackCell
			
			// Check if streak is alive
			if NSCalendar.currentCalendar().isDateInToday((NSUserDefaults.standardUserDefaults().objectForKey("lastWorkout") as! NSDate)) || NSCalendar.currentCalendar().isDateInYesterday((NSUserDefaults.standardUserDefaults().objectForKey("lastWorkout") as! NSDate)) {
				cell.barbell.image = UIImage(named: String(NSUserDefaults.standardUserDefaults().integerForKey("workoutCount")))
			}
			else {
				cell.barbell.image = UIImage(named: "0")
			}
			
			if NSUserDefaults.standardUserDefaults().integerForKey("workoutCount") >= 5 {
				let alert = UIAlertController(title: NSLocalizedString("Barbell Completed", comment: ""), message: NSLocalizedString("You completed the barbell, tap the barbell anytime from now on to use an exclusive workout routine", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
				alert.addAction(UIAlertAction(title: "Sweet", style: UIAlertActionStyle.Default, handler: nil))
				self.presentViewController(alert, animated: true, completion: nil)
				
				NSUserDefaults.standardUserDefaults().setBool(true, forKey: "workout5")
			}
			
			cell.backgroundColor = UIColor.clearColor()
			cell.focusStyle = .Custom
			
			
			return cell;
		}
		
		
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! WorkoutCell
		
		var exerciseDurationVar : String?
		var restDurationVar : String?
		
		// Set cell information based on the workout
		if let path = NSBundle.mainBundle().pathForResource("workout" + String(indexPath.row), ofType: "plist"), dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
			cell.title.text = String(dict["workoutName"]!)
			
			exerciseDurationVar = String(dict["defaultExerciseDuration"]!)
			restDurationVar = String(dict["defaultRestDuration"]!)
			
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
		cell.icon.image = (cell.icon.image?.imageWithRenderingMode(.AlwaysTemplate))!
		cell.icon.tintColor = UIColor.whiteColor()
		cell.title.textColor = UIColor.whiteColor()
		
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
			
			
			let alert = UIAlertController(title: cell.title.text, message: NSLocalizedString("Please set how long you would like the workout to last", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
			alert.addAction(UIAlertAction(title: NSLocalizedString("Start Workout", comment: ""), style: UIAlertActionStyle.Default, handler: { _ in
				let exerciseDurationTextField = alert.textFields![0] as UITextField
				let restDurationTextField = alert.textFields![1] as UITextField
				
				GlobalVariables.exerciseDuration = Int(exerciseDurationTextField.text!)!
				GlobalVariables.restDuration = Int(restDurationTextField.text!)!
				self.performSegueWithIdentifier("startWorkout", sender: self)
			}))
			alert.addTextFieldWithConfigurationHandler { (textField) in
				textField.placeholder = NSLocalizedString("Exercise Duration (sec.)", comment: "")
				textField.keyboardType = .NumberPad
				textField.text = exerciseDurationVar
			}
			alert.addTextFieldWithConfigurationHandler { (textField) in
				textField.placeholder = NSLocalizedString("Rest Duration (sec.)", comment: "")
				textField.keyboardType = .NumberPad
				textField.text = restDurationVar
			}
			alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel) { (_) in })
			self.presentViewController(alert, animated: true, completion: nil)
		}
		
		cell.focusStyle = .Custom
		
		return cell
	}
	
	func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
		
		if let prevFocus = context.previouslyFocusedIndexPath {
			if let cell = tableView.cellForRowAtIndexPath(prevFocus) as? WorkoutCell {
				cell.backgroundColor = cellBackgroundColor(prevFocus)
				cell.title.textColor = UIColor.whiteColor()
				cell.workoutList.textColor = UIColor.whiteColor()
				cell.itemCount.textColor = UIColor.whiteColor()
				cell.itemLabel.textColor = UIColor.whiteColor()
				cell.icon.tintColor = UIColor.whiteColor()
			}
			else if let cell = tableView.cellForRowAtIndexPath(prevFocus) as? SixPackCell {
				cell.backgroundColor = UIColor.clearColor()
			}
		}
		if let nextFoc = context.nextFocusedIndexPath {
			if let cell = tableView.cellForRowAtIndexPath(nextFoc) as? WorkoutCell {
				cell.backgroundColor = UIColor(red: 0.922, green: 0.239, blue: 0.212, alpha: 1.00)
				cell.title.textColor = UIColor.blackColor()
				cell.workoutList.textColor = UIColor.blackColor()
				cell.itemCount.textColor = UIColor.blackColor()
				cell.itemLabel.textColor = UIColor.blackColor()
				cell.icon.tintColor = UIColor.blackColor()
			}
			else if let cell = tableView.cellForRowAtIndexPath(nextFoc) as? SixPackCell {
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
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		// Barbell handler
		if indexPath.row == numOfRows - 1 && !NSUserDefaults.standardUserDefaults().boolForKey("workout5") {
			let alert = UIAlertController(title: NSLocalizedString("Complete The Barbell", comment: ""), message: NSLocalizedString("Every consecuative day that you finish a workout, a plate is added to your barbell. Get all 6 plates to unlock an exclusive workout routine", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
			alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
			self.presentViewController(alert, animated: true, completion: nil)
		}
		else if workoutUnlocked(indexPath.row) {
			(tableView.cellForRowAtIndexPath(indexPath) as! WorkoutCell).completion()
		}
		else {
			buyWorkout(indexPath.row)
		}
	}
	
	func buyWorkout(row: Int) {
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
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.row == numOfRows - 1 {
			return 105
		}
		else if (extendedCell == indexPath.row) {
			return 300
		}
		return 105
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
			                              message: NSLocalizedString("Please enable In App Purchase in Settings", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
			alert.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: UIAlertActionStyle.Default, handler: { alertAction in
				alert.dismissViewControllerAnimated(true, completion: nil)
				
				let url: NSURL? = NSURL(string: UIApplicationOpenSettingsURLString)
				if url != nil
				{
					UIApplication.sharedApplication().openURL(url!)
				}
				
			}))
			alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { alertAction in
				alert.dismissViewControllerAnimated(true, completion: nil)
			}))
			self.presentViewController(alert, animated: true, completion: nil)
		}
	}
	
	func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
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
	
	func buyProduct(productID: Int) {
		if productsArray.count-1 >= productID {
			let payment = SKPayment(product: productsArray[productID])
			SKPaymentQueue.defaultQueue().addPayment(payment)
		}
		else {
			let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("We could not find the in app purchase you were looking for", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
			alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
			self.presentViewController(alert, animated: true, completion: nil)
		}
	}
	
	
	func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		print("Processing Transaction")
		for transaction in transactions {
			
			switch transaction.transactionState {
				
			case SKPaymentTransactionState.Purchased:
				print("Transaction Approved")
				print("Product Identifier: \(transaction.payment.productIdentifier)")
				deliverProduct(transaction.payment.productIdentifier)
				SKPaymentQueue.defaultQueue().finishTransaction(transaction)
				
			case SKPaymentTransactionState.Failed:
				print("Transaction Failed")
				SKPaymentQueue.defaultQueue().finishTransaction(transaction)
			default:
				break
			}
		}
	}
	
	@IBAction func restorePurchases() {
		print("Restore Purchases")
		SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
		tableView.reloadData()
	}
	
	func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
		print("Transactions Restored")
		
		for transaction:SKPaymentTransaction in queue.transactions {
			deliverProduct(transaction.payment.productIdentifier)
		}
		
		let alert = UIAlertController(title: NSLocalizedString("Thank You", comment: ""), message: NSLocalizedString("Any purchases were restored.", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
}


extension UIViewController {
	func deliverProduct(identifier: String) {
		print("Identifier: " + identifier)
		if identifier == "com.rybel_llc.core_x.myrtl" {
			NSUserDefaults.standardUserDefaults().setBool(true, forKey: "workout1")
		}
		else if identifier == "com.rybel_llc.core_x.remove_ads" {
			NSUserDefaults.standardUserDefaults().setBool(true, forKey: "removedAds")
		}
		else if identifier == "com.rybel_llc.core_x.leg_day" {
			NSUserDefaults.standardUserDefaults().setBool(true, forKey: "workout2")
		}
		else if identifier == "com.rybel_llc.core_x.pushups" {
			NSUserDefaults.standardUserDefaults().setBool(true, forKey: "workout3")
		}
		else if identifier == "com.rybel_llc.core_x.yoga" {
			NSUserDefaults.standardUserDefaults().setBool(true, forKey: "workout4")
		}
		
		NSUserDefaults.standardUserDefaults().synchronize()
		viewWillAppear(true)
	}
}
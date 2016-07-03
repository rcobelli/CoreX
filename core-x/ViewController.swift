//
//  ViewController.swift
//  core-x
//
//  Created by Ryan Cobelli on 12/12/15.
//  Copyright © 2015 Rybel LLC. All rights reserved.
//

import UIKit
import Appodeal
import StoreKit
import MessageUI
import AVFoundation
import WatchConnectivity
import HealthKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver, AVAudioPlayerDelegate, UIDocumentInteractionControllerDelegate, WCSessionDelegate  {

	@IBOutlet weak var tableView: UITableView!
	var workoutIDToSend = Int()
	
	var justShowedAd = Bool()
	
	var healthManager = HealthManager()
	
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
		
		// Show share menu on completion of workout
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.showMenu), name: "showMenu", object: nil)
	}
	
	
	override func viewWillAppear(animated: Bool) {
		tableView.reloadData()
	}
	
	override func viewDidAppear(animated: Bool) {
		if !NSUserDefaults.standardUserDefaults().boolForKey("firstLaunch") && !NSProcessInfo.processInfo().arguments.contains("testing") {
			// Don't show an ad on first launch
			justShowedAd = !justShowedAd
			
			// Check if they want health kit
			SweetAlert().showAlert(NSLocalizedString("Welcome to Core-X!", comment: ""), subTitle: NSLocalizedString("Quick question, want to save your workouts to the Health app?", comment: ""), style: AlertStyle.None,
			                       buttonTitle: "Yes", buttonColor: UIColor(red: 0.000, green: 0.718, blue: 0.573, alpha: 1.00), otherButtonTitle: "No", otherButtonColor:  UIColor(red: 0.933, green: 0.294, blue: 0.169, alpha: 1.00), action: { button in
				
					NSUserDefaults.standardUserDefaults().setBool(true, forKey: "firstLaunch")
					if button {
						self.healthManager.authorizeHealthKit { (authorized,  error) -> Void in
							if !authorized {
								if error != nil {
									print("\(error)")
								}
							}
					}
				}
			})
		}
		
		// Ads
		if !justShowedAd && Appodeal.isReadyForShowWithStyle(AppodealShowStyle.Interstitial) && shouldDisplayAd() {
			Appodeal.showAd(AppodealShowStyle.Interstitial, rootViewController: self)
		}
		justShowedAd = !justShowedAd
		
		
		
		
//		let data = ["workout1": NSUserDefaults.standardUserDefaults().boolForKey("workout1"),
//		            "workout2": NSUserDefaults.standardUserDefaults().boolForKey("workout2"),
//		            "workout3": NSUserDefaults.standardUserDefaults().boolForKey("workout3"),
//		            "workout4": NSUserDefaults.standardUserDefaults().boolForKey("workout4")]
//		
//		
//		if WCSession.isSupported() { //makes sure Watch is supported
//			let watchSession = WCSession.defaultSession()
//			watchSession.delegate = self
//			watchSession.activateSession()
//			if watchSession.paired && watchSession.watchAppInstalled {
//				do {
//					try watchSession.updateApplicationContext(data)
//				} catch let error as NSError {
//					print(error.description)
//				}
//			}
//		}
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		self.view.endEditing(true)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		self.view.endEditing(true)
	}
	
	// Social media share menu
	func showMenu() {
		let textToShare = NSLocalizedString("I just completed the ", comment: "") +
			NSUserDefaults.standardUserDefaults().stringForKey("workoutName")! + NSLocalizedString(" workout using Core-X (https://rybel-llc.com/core-x)!", comment: "")
		
		let workoutImageNamed = UIImage(named: "core-x")!
		let objectsToShare = [workoutImageNamed, textToShare]
		let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
	
		presentViewController(activityVC, animated: true, completion: nil)
	}
	
	// Check if a workout has been unlocked or a trial is available
	func workoutUnlocked(identifier: Int) -> Bool {
		if NSUserDefaults.standardUserDefaults().boolForKey(String(NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"])) {
			return true
		}
		return NSUserDefaults.standardUserDefaults().boolForKey("workout" + String(identifier))
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
				SweetAlert().showAlert(NSLocalizedString("Barbell Completed", comment: ""), subTitle: NSLocalizedString("You completed the barbell, tap the barbell anytime from now on to use an exclusive workout routine", comment: ""), style: AlertStyle.Success)
				NSUserDefaults.standardUserDefaults().setBool(true, forKey: "workout5")
			}

			cell.backgroundColor = UIColor.clearColor()
			return cell;
		}
		
		
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! WorkoutCell
		
		// Set cell information based on the workout
		if let path = NSBundle.mainBundle().pathForResource("workout" + String(indexPath.row), ofType: "plist"), dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
			cell.title.text = String(dict["workoutName"]!)
			cell.exerciseDuration.text = String(dict["defaultExerciseDuration"]!)
			cell.restDuration.text = String(dict["defaultRestDuration"]!)
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
			cell.backgroundColor = UIColor(red: 0.863, green: 0.820, blue: 0.282, alpha: 1.00)
			break
		case 1:
			cell.icon.image = UIImage(named: "myrtl")
			cell.backgroundColor = UIColor(red: 0.537, green: 0.612, blue: 0.612, alpha: 1.00)
			break
		case 2:
			cell.icon.image = UIImage(named: "leg-day")
			cell.backgroundColor = UIColor(red: 0.106, green: 0.557, blue: 0.839, alpha: 1.00)
			break
		case 3:
			cell.icon.image = UIImage(named: "pushup")
			cell.backgroundColor = UIColor(red: 0.173, green: 0.251, blue: 0.325, alpha: 1.00)
			break
		case 4:
			cell.icon.image = UIImage(named: "yoga")
			cell.backgroundColor = UIColor(red: 0.000, green: 0.718, blue: 0.573, alpha: 1.00)
			break
		case 5:
			cell.icon.image = UIImage(named: "coachLiz")
			cell.backgroundColor = UIColor(red: 0.580, green: 0.290, blue: 0.675, alpha: 1.00)
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
		}
		else {
			cell.title.alpha = 0.5
			cell.icon.alpha = 0.25
			cell.itemCount.alpha = 0.25
			cell.itemLabel.alpha = 0.25
		}
		
		// Completion block to start the workout
		cell.completion = {
			// Check if it needs to reset the trial
			if !NSUserDefaults.standardUserDefaults().boolForKey("workout" + String(indexPath.row)) {
				NSUserDefaults.standardUserDefaults().setBool(false, forKey: String(NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]))
				NSUserDefaults.standardUserDefaults().setBool(true, forKey: String(NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]) + "used")
			}
			
			GlobalVariables.exerciseID = indexPath.row
			
			self.performSegueWithIdentifier("startWorkout", sender: self)
		}
		
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		// Barbell handler
		if indexPath.row == numOfRows - 1 && !NSUserDefaults.standardUserDefaults().boolForKey("workout5") {
			SweetAlert().showAlert(NSLocalizedString("Complete The Barbell", comment: ""), subTitle: NSLocalizedString("Every consecuative day that you finish a workout, a plate is added to your barbell. Get all 6 plates to unlock an exclusive workout routine", comment: ""), style: AlertStyle.None)
		}
		// Grow/Shrink the cell on selection
		else if workoutUnlocked(indexPath.row) {
			if extendedCell == indexPath.row {
				extendedCell = nil
			}
			else {
				extendedCell = indexPath.row
			}
			
			self.view.endEditing(true)
			
			tableView.beginUpdates()
			tableView.endUpdates()
		}
		else {
			// See if a trial is available
			if trialAvailable() {
				SweetAlert().showAlert(NSLocalizedString("Free Trial Available", comment: ""), subTitle: NSLocalizedString("You can get a free trial of any workout routine by leaving a rating on the App Store.", comment: ""), style: AlertStyle.None,
				                       buttonTitle: NSLocalizedString("Leave A Review", comment: ""), buttonColor: UIColor(red: 0.000, green: 0.718, blue: 0.573, alpha: 1.00),
				                       otherButtonTitle: NSLocalizedString("Buy It", comment: ""), otherButtonColor: UIColor(red: 0.000, green: 0.718, blue: 0.573, alpha: 1.00)) { other in
					if !other { //Buy it
						self.buyWorkout(indexPath.row)
					}
					else { // Leave a review
						NSUserDefaults.standardUserDefaults().setBool(true, forKey: String(NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]))
						// Open app store to give a rating
						UIApplication.sharedApplication().openURL(NSURL(string : "https://itunes.apple.com/us/app/core-x/id972403903")!)
					}
				}
			}
			else {
				buyWorkout(indexPath.row)
			}
			
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
			return 50
		}
		else if (extendedCell == indexPath.row) {
			return 200
		}
		return 66
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
		if productsArray.count >= productID {
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
	
	func trialAvailable() -> Bool {
		return !NSUserDefaults.standardUserDefaults().boolForKey(String(NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]) + "used")
	}
	
	func shouldDisplayAd() -> Bool {
		if NSUserDefaults.standardUserDefaults().boolForKey("workout1") || NSUserDefaults.standardUserDefaults().boolForKey("workout2") ||
			NSUserDefaults.standardUserDefaults().boolForKey("workout3") || NSUserDefaults.standardUserDefaults().boolForKey("workout4") ||
			NSUserDefaults.standardUserDefaults().boolForKey("removedAds") || NSProcessInfo.processInfo().arguments.contains("testing") {
			return false
		}
		return true
	}
}


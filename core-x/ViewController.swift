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

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver, AVAudioPlayerDelegate, UIDocumentInteractionControllerDelegate  {

	@IBOutlet weak var tableView: UITableView!
	var workoutIDToSend = Int()
	
	var justShowedAd = Bool()
	
	let productIdentifiers = Set(["com.rybel_llc.core_x.remove_ads", "com.rybel_llc.core_x.myrtl", "com.rybel_llc.core_x.leg_day"])
	var product: SKProduct?
	var productsArray = Array<SKProduct>()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.tableFooterView = UIView()
		tableView.delegate = self
		tableView.dataSource = self
		
		SKPaymentQueue.defaultQueue().addTransactionObserver(self)
		requestProductData()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "showMenu", name: "showMenu", object: nil)
	}
	
	
	
	func showMenu() {
		let textToShare = NSLocalizedString("I just completed the ", comment: "") + NSUserDefaults.standardUserDefaults().stringForKey("workoutName")! + NSLocalizedString(" workout using Core-X (http://appstore.com/corex)!", comment: "")
		
		let workoutImageNamed = UIImage(named: "core-x")!
	
			let objectsToShare = [workoutImageNamed, textToShare]
			let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
		
		
			presentViewController(activityVC, animated: true, completion: nil)
	}
	
	func requestProductData() {
		if SKPaymentQueue.canMakePayments() {
			let request = SKProductsRequest(productIdentifiers: productIdentifiers as Set<String>)
			request.delegate = self
			request.start()
		}
		else {
			let alert = UIAlertController(title: NSLocalizedString("In-App Purchases Not Enabled", comment: ""), message: NSLocalizedString("Please enable In App Purchase in Settings", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
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
		
		print(productIdentifiers)
	}
	
	func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
		
		var products = response.products
		
		if (products.count != 0) {
			for var i = 0; i < products.count; i++
			{
				product = products[i] as SKProduct
				productsArray.append(product!)
			}
		} else {
			print("No products found")
		}
		
		for product in response.invalidProductIdentifiers
		{
			print("Product not found: \(product)")
		}
	}
	
	func buyProduct(productID: Int) {
		let payment = SKPayment(product: productsArray[productID])
		SKPaymentQueue.defaultQueue().addPayment(payment)
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
		
		NSUserDefaults.standardUserDefaults().synchronize()
		viewWillAppear(true)
	}
	
	func restorePurchases() {
		print("Restore Purchases")
		SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
		tableView.reloadData()
	}
	
	func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
		print("Transactions Restored")
		
		for transaction:SKPaymentTransaction in queue.transactions {
			deliverProduct(transaction.payment.productIdentifier)
		}
		
		SweetAlert().showAlert(NSLocalizedString("Thank You", comment: ""), subTitle: NSLocalizedString("Your purchase(s) were restored.", comment: ""), style: AlertStyle.Success)
	}
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewWillAppear(animated: Bool) {
		tableView.reloadData()
	}
	
	override func viewDidAppear(animated: Bool) {
		if !justShowedAd && Appodeal.isReadyForShowWithStyle(AppodealShowStyle.Interstitial) && !NSUserDefaults.standardUserDefaults().boolForKey("removedAds") && !NSProcessInfo.processInfo().arguments.contains("testing") {
			Appodeal.showAd(AppodealShowStyle.Interstitial, rootViewController: self)
		}
		else {
			print("Ready for ad:" + String(Appodeal.isReadyForShowWithStyle(AppodealShowStyle.Interstitial)))
			print("Ads IAP:" + String(NSUserDefaults.standardUserDefaults().boolForKey("removedAds")))
		}
		justShowedAd = !justShowedAd
		
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! WorkoutCell
		
		switch indexPath.row {
		case 0:
			cell.title.text = "Core X"
			cell.backgroundImage.image = UIImage(named: "core-x")
			break
		case 1:
			cell.title.text = "Myrtl"
			cell.backgroundImage.image = UIImage(named: "myrtl")
			break
		case 2:
			cell.title.text = NSLocalizedString("Leg-Day", comment: "")
			cell.backgroundImage.image = UIImage(named: "leg-day")
			
			break
		default:
			break
		}
		
		cell.backgroundColor = UIColor(red: 0.776, green: 0.745, blue: 0.655, alpha: 1.00)
		
		if !NSUserDefaults.standardUserDefaults().boolForKey("workout" + String(indexPath.row)) {
			cell.title.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
			cell.backgroundImage.alpha = 0.25
			print("Cell \(indexPath.row) not purchased")
		}
		else {
			cell.title.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
			cell.backgroundImage.alpha = 1
			print("Cell \(indexPath.row) purchased")
		}
		
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if NSUserDefaults.standardUserDefaults().boolForKey("workout" + String(indexPath.row)) {
			self.performSegueWithIdentifier("showWorkout", sender: self)
		}
		else {
			switch indexPath.row {
			case 1:
				buyProduct(1)
				break
			case 2:
				buyProduct(0)
				break
			default:
				break
			}
			
			
		}
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 150
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showWorkout" {
			let destination = segue.destinationViewController as! WorkoutViewController
			destination.workoutID = (tableView.indexPathForSelectedRow?.row)!
		}
	}

}


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
	
	let productIdentifiers = Set(["com.rybel_llc.core_x.myrtl", "com.rybel_llc.core_x.leg_day"])
	var product: SKProduct?
	var productsArray = Array<SKProduct>()
	
	var request = SKProductsRequest()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.tableFooterView = UIView()
		tableView.delegate = self
		tableView.dataSource = self
		
		SKPaymentQueue.defaultQueue().addTransactionObserver(self)
		requestProductData()
		
	}
	
	func requestProductData() {
		print("Product Identifiers")
		print(productIdentifiers)
		
		if SKPaymentQueue.canMakePayments() {
			request = SKProductsRequest(productIdentifiers: productIdentifiers as Set<String>)
			request.delegate = self
			request.start()
			print("Requesting data")
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
	}
	
	
	func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
		print("products found")
		var products = response.products
		
		if (products.count != 0) {
			for var i = 0; i < products.count; i++
			{
				product = products[i] as SKProduct
				productsArray.append(product!)
			}
		}
		else {
			print("No products found")
		}
		
		for product in response.invalidProductIdentifiers
		{
			print("Product not found: \(product)")
		}
	}
	
	func buyProduct(productID: Int) {
		print(productsArray)
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
		let alert = UIAlertController(title: "Thank You", message: "Purchases restored", preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewWillAppear(animated: Bool) {
		tableView.reloadData()
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! WorkoutCell
		
		switch indexPath.row {
		case 0:
			cell.title.text = "Core X"
			cell.backgroundImage.image = UIImage(named: "core-x.tv.png")
			break
		case 1:
			cell.title.text = "Myrtl"
			cell.backgroundImage.image = UIImage(named: "myrtl.tv.png")
			break
		case 2:
			cell.title.text = NSLocalizedString("Leg-Day", comment: "")
			cell.backgroundImage.image = UIImage(named: "leg-day.tv.png")
			break
		default:
			cell.title.text = NSLocalizedString("Settings", comment: "")
			cell.backgroundImage.image = UIImage(named: "settings.tv.png")
			break
		}
		
		if indexPath.row != 3 {
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
		}
		
		
		
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath.row != 3 {
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
		else {
			self.performSegueWithIdentifier("showSettings", sender: self)
		}
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 200
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3+1
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showWorkout" {
			let navVC = segue.destinationViewController as! UINavigationController
			let destination = navVC.topViewController as! WorkoutSettingsViewController
			destination.workoutID = (tableView.indexPathForSelectedRow?.row)!
		}
	}


}


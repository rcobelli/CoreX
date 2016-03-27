//
//  SettingsViewController.swift
//  core-x
//
//  Created by Ryan Cobelli on 1/17/16.
//  Copyright © 2016 Rybel LLC. All rights reserved.
//

import UIKit
import StoreKit

class SettingsViewController: UITableViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
	
	let productIdentifiers = Set(["com.rybel_llc.core_x.remove_ads"])
	var product: SKProduct?
	var productsArray = Array<SKProduct>()
	
	var request = SKProductsRequest()
	
	@IBOutlet weak var doneButton: UIBarButtonItem!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		print("Settings")
		SKPaymentQueue.defaultQueue().addTransactionObserver(self)
		requestProductData()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func requestProductData() {
		if SKPaymentQueue.canMakePayments() {
			request = SKProductsRequest(productIdentifiers: productIdentifiers as Set<String>)
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
			for i in 0 ..< products.count
			{
				product = products[i] as SKProduct
				productsArray.append(product!)
			}
			productsArray = productsArray.sort({ $0.productIdentifier < $1.productIdentifier })
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
		
		let alert = UIAlertController(title: NSLocalizedString("Any purchases were restored", comment: ""), message: nil, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { alertAction in
			alert.dismissViewControllerAnimated(true, completion: nil)
		}))
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	@IBAction func done(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	// MARK: - Table view data source
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		switch indexPath.row {
		case 0:
			restorePurchases()
		default:
			break
		}
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		
		switch indexPath.row {
		case 0:
			cell.textLabel?.text = "Restore Purchases"
			break
		case 1:
			cell.textLabel?.text = "Email us at rybelllc@gmail.com"
			break
		default:
			cell.textLabel?.text = NSLocalizedString("Version ", comment:"") + String(stringInterpolationSegment: NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]!)
			cell.selectionStyle = .None
			break
		}
		
		return cell
	}
	
	override func viewDidDisappear(animated: Bool) {
		SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
	}
	
}
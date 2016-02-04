//
//  SettingsTableViewController.swift
//  core-x
//
//  Created by Ryan Cobelli on 1/3/16.
//  Copyright © 2016 Rybel LLC. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI

class SettingsTableViewController: UITableViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver, MFMailComposeViewControllerDelegate {
	
	let productIdentifiers = Set(["com.rybel_llc.core_x.remove_ads"])
	var product: SKProduct?
	var productsArray = Array<SKProduct>()

	@IBOutlet weak var doneButton: UIBarButtonItem!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        requestProductData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
		
		SweetAlert().showAlert(NSLocalizedString("Thank You", comment: ""), subTitle: NSLocalizedString("Your purchase(s) were restored.", comment: ""), style: AlertStyle.Success)
	}
	
	@IBAction func done(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	
	func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
		dismissViewControllerAnimated(true, completion: nil)
	}

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		switch indexPath.row {
		case 0:
			buyProduct(0)
		case 1:
			restorePurchases()
		case 2:
			if MFMailComposeViewController.canSendMail() {
				let picker = MFMailComposeViewController()
				picker.mailComposeDelegate = self
				picker.setSubject("New Workout Suggestion")
				picker.setMessageBody(NSLocalizedString("Let us know of a new workout you would like to see in the app!", comment: ""), isHTML: false)
				
				presentViewController(picker, animated: true, completion: nil)
			}
			else {
				SweetAlert().showAlert(NSLocalizedString("Can't Send Mail", comment: ""), subTitle: NSLocalizedString("Mail isn't working. Email us at rybelllc@gmail.com", comment: ""), style: AlertStyle.Error)
			}
		case 3:
			SweetAlert().showAlert(NSLocalizedString("Feedback:", comment: ""), subTitle: NSLocalizedString("What do you think of Core-X?", comment: ""), style: AlertStyle.None, buttonTitle:NSLocalizedString("It Stinks", comment: ""), buttonColor:UIColor.redColor() , otherButtonTitle:  NSLocalizedString("I like it", comment: ""), otherButtonColor: UIColor.greenColor()) { (isOtherButton) -> Void in
				// It Sucks
				if isOtherButton == false {
					// Open app store to give a rating
					UIApplication.sharedApplication().openURL(NSURL(string : "https://itunes.apple.com/us/app/core-x/id972403903")!)
				}
				// I like it
				else {
					// Open email dialogue
					if MFMailComposeViewController.canSendMail() {
						let picker = MFMailComposeViewController()
						picker.mailComposeDelegate = self
						picker.setSubject("Core-X Feedback")
						picker.setMessageBody(NSLocalizedString("Tell us what you really think about Core-X", comment: ""), isHTML: false)
						self.presentViewController(picker, animated: true, completion: nil)
					}
					else {
						SweetAlert().showAlert(NSLocalizedString("Can't Send Mail", comment: ""), subTitle: NSLocalizedString("Mail isn't working. Email us at rybelllc@gmail.com", comment: ""), style: AlertStyle.Error)
					}
				}
			}
		default:
			break
		}
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = UITableViewCell()

		switch indexPath.row {
		case 0:
			cell.textLabel?.text = "Remove Ads"
			if NSUserDefaults.standardUserDefaults().boolForKey("removedAds") {
				cell.userInteractionEnabled = false
				cell.textLabel?.alpha = 0.5
			}
			else {
				cell.userInteractionEnabled = true
				cell.textLabel?.alpha = 1.0
			}
		case 1:
			cell.textLabel?.text = "Restore Purchases"
		case 2:
			cell.textLabel?.text = "Submit New Workout Idea"
		case 3:
			cell.textLabel?.text = "Leave Feedback"
		default:
			cell.textLabel?.text = NSLocalizedString("Version ", comment:"") + String(stringInterpolationSegment: NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]!)
			cell.selectionStyle = .None
			break
		}
		
		cell.textLabel?.font = UIFont.systemFontOfSize(18)
		cell.backgroundColor = UIColor(red: 0.776, green: 0.745, blue: 0.655, alpha: 1.00)

        return cell
    }
	
	override func viewDidDisappear(animated: Bool) {
		SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
	}

}

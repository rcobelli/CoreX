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
import MediaPlayer

class SettingsTableViewController: UITableViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver, MFMailComposeViewControllerDelegate {
	
	var product: SKProduct?
	var productsArray = Array<SKProduct>()

	@IBOutlet weak var doneButton: UIBarButtonItem!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		SKPaymentQueue.defaultQueue().addTransactionObserver(self)
		
		tableView.tableFooterView = UIView()
    }
	
	@IBAction func done(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	
	func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	// MARK:- Store Kit Methods
	
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
		
		SweetAlert().showAlert(NSLocalizedString("Thank You", comment: ""), subTitle: NSLocalizedString("Any purchases were restored.", comment: ""), style: AlertStyle.Success)
	}

    // MARK: - UITableView Methods

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		switch indexPath.row {
		case 0:
			restorePurchases()
		case 1:
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
		case 2:
			// See if the user already left a review
			if !trialAvailable() {
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
			else {
				SweetAlert().showAlert(NSLocalizedString("Feedback:", comment: ""), subTitle: NSLocalizedString("What do you think of Core-X?", comment: ""), style: AlertStyle.None, buttonTitle:NSLocalizedString("It Stinks", comment: ""), buttonColor:UIColor(red: 0.933, green: 0.294, blue: 0.169, alpha: 1.00) , otherButtonTitle:  NSLocalizedString("I like it", comment: ""), otherButtonColor: UIColor(red: 0.000, green: 0.718, blue: 0.573, alpha: 1.00)) { (isOtherButton) -> Void in
					// It Sucks
					if isOtherButton == false {
						SweetAlert().showAlert(NSLocalizedString("App Store Review", comment: ""), subTitle: NSLocalizedString("Can you please leave us a review on the App Store? (We'll even throw in a free workout routine", comment: ""), style: AlertStyle.None, buttonTitle: NSLocalizedString("Sure!", comment: ""), buttonColor: UIColor(red: 0.000, green: 0.718, blue: 0.573, alpha: 1.00), otherButtonTitle: NSLocalizedString("No", comment: ""), otherButtonColor: UIColor(red: 0.000, green: 0.718, blue: 0.573, alpha: 1.00)) { other in
							if other {
								NSUserDefaults.standardUserDefaults().setBool(true, forKey: String(NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]))
								// Open app store to give a rating
								UIApplication.sharedApplication().openURL(NSURL(string : "https://itunes.apple.com/us/app/core-x/id972403903")!)
							}
						}
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
			}
		case 3:
			let optionMenu = UIAlertController(title: nil, message: NSLocalizedString("Choose a playlist for your workouts", comment: ""), preferredStyle: .ActionSheet)
			
			let myMediaQuery = MPMediaQuery.playlistsQuery()
			let array = myMediaQuery.collections!
			for item in array {
				let value = item.valueForProperty(MPMediaPlaylistPropertyName) as! String
				optionMenu.addAction(UIAlertAction(title: value, style: .Default, handler: {
					(alert: UIAlertAction!) -> Void in
					NSUserDefaults.standardUserDefaults().setObject(value, forKey: "playlistName")
					self.tableView.reloadData()
				}))
			}
			
			let cancelAction = UIAlertAction(title: NSLocalizedString("No Music", comment: ""), style: .Cancel, handler: {
				(alert: UIAlertAction!) -> Void in
				NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "playlistName")
				self.tableView.reloadData()
			})
			
			 optionMenu.addAction(cancelAction)
			
			self.presentViewController(optionMenu, animated: true, completion: nil)
		default:
			break
		}
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = UITableViewCell()

		switch indexPath.row {
		case 0:
			cell.textLabel?.text = NSLocalizedString("Restore Purchases", comment: "")
		case 1:
			cell.textLabel?.text = NSLocalizedString("Submit New Workout Idea", comment: "")
		case 2:
			cell.textLabel?.text = NSLocalizedString("Leave Feedback", comment: "")
		case 3:
			var name = NSUserDefaults.standardUserDefaults().stringForKey("playlistName")
			if name == nil {
				name = NSLocalizedString("Unset", comment: "")
			}
			cell.textLabel?.text = NSLocalizedString("Music Playlist", comment: "") + ": " + name!
		default:
			cell.textLabel?.text = NSLocalizedString("Version ", comment:"") + String(stringInterpolationSegment: NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]!)
			cell.selectionStyle = .None
			break
		}
		
		cell.textLabel?.font = UIFont.systemFontOfSize(18)
		cell.textLabel?.textColor = UIColor.whiteColor()
		cell.separatorInset = UIEdgeInsetsZero
		cell.backgroundColor = UIColor(red: 0.173, green: 0.251, blue: 0.325, alpha: 1.00)

        return cell
    }
	
	override func viewDidDisappear(animated: Bool) {
		SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
	}

}

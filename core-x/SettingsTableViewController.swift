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
import Eureka
import SwiftyStoreKit

class SettingsViewController: FormViewController {

	@IBOutlet weak var doneButton: UIBarButtonItem!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		form +++ ButtonRow() { (row: ButtonRow) -> Void in
				row.title = "Restore Purchases"
				}
				.onCellSelection { (_, _) in
					self.restorePurchasesAction()
			}
			<<< ButtonRow() { (row: ButtonRow) -> Void in
				row.title = "Submit New Workout Idea"
				if !MFMailComposeViewController.canSendMail() {
					row.disabled = true
				}
				}
				.onCellSelection { (_, _) in
					if MFMailComposeViewController.canSendMail() {
						let picker = MFMailComposeViewController()
						picker.mailComposeDelegate = self
						picker.setToRecipients(["info@rybel-llc.com"])
						picker.setSubject("New Workout Suggestion")
						picker.setMessageBody("Let us know of a new workout you would like to see in the app!", isHTML: false)
						
						self.present(picker, animated: true, completion: nil)
					}
			}
			
			+++ Section(header: "Send Feedback",
						footer: "Version " + String(describing: Bundle.main.infoDictionary!["CFBundleShortVersionString"]!))
			<<< ButtonRow() { (row: ButtonRow) -> Void in
				row.title = "Email"
				if !MFMailComposeViewController.canSendMail() {
					row.disabled = true
				}
				}
				.onCellSelection { (_, _) in
					if MFMailComposeViewController.canSendMail() {
						let picker = MFMailComposeViewController()
						picker.setToRecipients(["info@rybel-llc.com"])
						picker.mailComposeDelegate = self
						picker.setSubject("Core-X Feedback")
						picker.setMessageBody(NSLocalizedString("Tell us what you really think about Core-X", comment: ""), isHTML: false)
						self.present(picker, animated: true, completion: nil)
					}
			}
			<<< ButtonRow() { (row: ButtonRow) -> Void in
				row.title = "Leave App Store Review"
				}
				.onCellSelection { (_, _) in
					ReviewKitHelper.forceDisplayReviewPrompt()
			}
    }
	
	@IBAction func done(_ sender: AnyObject) {
		self.dismiss(animated: true, completion: nil)
	}
	
	func restorePurchasesAction() {
		SwiftyStoreKit.restorePurchases(atomically: true) { results in
			var message = "There was nothing to restore"
			
			if results.restoreFailedPurchases.count > 0 {
				print("Restore Failed: \(results.restoreFailedPurchases)")
				
				message = "We were unable to restore your purchases. Please try again."
			} else if results.restoredPurchases.count > 0 {
				print("Restore Success: \(results.restoredPurchases)")
				for item in results.restoredPurchases {
					self.deliverProduct(item.productId)
				}
				
				message = "Your purchases have been restored"
			}
			
			let alertController = UIAlertController(title: "Restore Purchases", message: message, preferredStyle: .alert)
			let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
			alertController.addAction(action)
			self.present(alertController, animated: true, completion: nil)
		}
	}

}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		dismiss(animated: true, completion: nil)
	}
}

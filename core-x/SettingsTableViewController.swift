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

class SettingsViewController: FormViewController, MFMailComposeViewControllerDelegate {

	@IBOutlet weak var doneButton: UIBarButtonItem!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		form +++ ButtonRow() { (row: ButtonRow) -> Void in
				row.title = "Restore Purchases"
				}
				.onCellSelection { (cell, row) in
					SwiftyStoreKit.restorePurchases(atomically: true) { results in
						if results.restoreFailedProducts.count > 0 {
							print("Restore Failed: \(results.restoreFailedProducts)")
							_ = SweetAlert().showAlert("Restore Purchases", subTitle: "We were unable to restore your purchases. Please try again.", style: AlertStyle.error)
						}
						else if results.restoredProducts.count > 0 {
							print("Restore Success: \(results.restoredProducts)")
							for item in results.restoredProducts {
								self.deliverProduct(item.productId)
							}
							_ = SweetAlert().showAlert("Restore Purchases", subTitle: "Your purchases have been restored", style: AlertStyle.success)
						}
						else {
							_ = SweetAlert().showAlert("Restore Purchases", subTitle: "There was nothing to restore", style: AlertStyle.success)
						}
					}
			}
			<<< ButtonRow() { (row: ButtonRow) -> Void in
				row.title = "Submit New Workout Idea"
				if !MFMailComposeViewController.canSendMail() {
					row.disabled = true
				}
				}
				.onCellSelection { (cell, row) in
					if MFMailComposeViewController.canSendMail() {
						let picker = MFMailComposeViewController()
						picker.mailComposeDelegate = self
						picker.setSubject("New Workout Suggestion")
						picker.setMessageBody(NSLocalizedString("Let us know of a new workout you would like to see in the app!", comment: ""), isHTML: false)
						
						self.present(picker, animated: true, completion: nil)
					}
					else {
						_ = SweetAlert().showAlert(NSLocalizedString("Can't Send Mail", comment: ""), subTitle: NSLocalizedString("The mail app is not configured. You can email us at rybelllc@gmail.com instead", comment: ""), style: AlertStyle.error)
					}
			}
			
			+++ Section(header: "Music", footer: "")
			<<< PickerInlineRow<String>("PickerInlineRow") { (row : PickerInlineRow<String>) -> Void in
				row.title = "Select Music Playlist"
				row.options = ["No Music"]
				
				if UserDefaults.standard.string(forKey: "playlistName") != nil {
					row.value = UserDefaults.standard.string(forKey: "playlistName")
				}
				
				let myMediaQuery = MPMediaQuery.playlists()
				for item in myMediaQuery.collections! {
					let value = item.value(forProperty: MPMediaPlaylistPropertyName) as! String
					row.options.append(value)
				}
				
				}.onChange({ row in
					if row.value! == "No Music" {
						UserDefaults.standard.set(nil, forKey: "playlistName")
					}
					else {
						UserDefaults.standard.set(row.value!, forKey: "playlistName")
					}
				})
			<<< SwitchRow("set_none") {
				$0.title = "Shuffle"
				$0.value = UserDefaults.standard.bool(forKey: "shuffleMusic")
				}.onChange { cell in
					if cell.value ?? false {
						UserDefaults.standard.set(true, forKey: "shuffleMusic")
					}
					else {
						UserDefaults.standard.set(false, forKey: "shuffleMusic")
					}
			}
			
			
			+++ Section(header: "Send Feedback", footer: "Version " + String(stringInterpolationSegment: Bundle.main.infoDictionary!["CFBundleShortVersionString"]!))
			<<< ButtonRow() { (row: ButtonRow) -> Void in
				row.title = "Email"
				if !MFMailComposeViewController.canSendMail() {
					row.disabled = true
				}
				}
				.onCellSelection { (cell, row) in
					if MFMailComposeViewController.canSendMail() {
						let picker = MFMailComposeViewController()
						picker.mailComposeDelegate = self
						picker.setSubject("Core-X Feedback")
						picker.setMessageBody(NSLocalizedString("Tell us what you really think about Core-X", comment: ""), isHTML: false)
						self.present(picker, animated: true, completion: nil)
					}
					else {
						_ = SweetAlert().showAlert(NSLocalizedString("Can't Send Mail", comment: ""), subTitle: NSLocalizedString("The mail app is not configured. You can email us at rybelllc@gmail.com instead", comment: ""), style: AlertStyle.error)
					}
			}
			<<< ButtonRow() { (row: ButtonRow) -> Void in
				row.title = "App Store Review"
				}
				.onCellSelection { (cell, row) in
					UIApplication.shared.openURL(URL(string : "https://itunes.apple.com/us/app/core-x/id972403903")!)
			}
    }
	
	@IBAction func done(_ sender: AnyObject) {
		self.dismiss(animated: true, completion: nil)
	}
	
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		dismiss(animated: true, completion: nil)
	}

}

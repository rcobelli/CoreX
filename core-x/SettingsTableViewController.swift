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

class SettingsTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
	
	var product: SKProduct?
	var productsArray = Array<SKProduct>()

	@IBOutlet weak var doneButton: UIBarButtonItem!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.tableFooterView = UIView()
    }
	
	@IBAction func done(_ sender: AnyObject) {
		self.dismiss(animated: true, completion: nil)
	}
	
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		dismiss(animated: true, completion: nil)
	}
	
	
    // MARK: - UITableView Methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.row {
		case 0:
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
		case 1:
			if MFMailComposeViewController.canSendMail() {
				let picker = MFMailComposeViewController()
				picker.mailComposeDelegate = self
				picker.setSubject("New Workout Suggestion")
				picker.setMessageBody(NSLocalizedString("Let us know of a new workout you would like to see in the app!", comment: ""), isHTML: false)
				
				present(picker, animated: true, completion: nil)
			}
			else {
				_ = SweetAlert().showAlert(NSLocalizedString("Can't Send Mail", comment: ""), subTitle: NSLocalizedString("The mail app is not configured. You can email us at rybelllc@gmail.com instead", comment: ""), style: AlertStyle.error)
			}
		case 2:
			SweetAlert().showAlert(NSLocalizedString("Feedback:", comment: ""), subTitle: NSLocalizedString("How to you want to leave feedback?", comment: ""), style: AlertStyle.none, buttonTitle:NSLocalizedString("Email", comment: ""), buttonColor:UIColor(red: 0.000, green: 0.718, blue: 0.573, alpha: 1.00) , otherButtonTitle:  NSLocalizedString("App Review", comment: ""), otherButtonColor: UIColor(red: 0.000, green: 0.718, blue: 0.573, alpha: 1.00)) { (isOtherButton) -> Void in
				if isOtherButton == false {
					UIApplication.shared.openURL(URL(string : "https://itunes.apple.com/us/app/core-x/id972403903")!)
				}
				else {
					// Open email dialogue
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
			}
		case 3:
			let optionMenu = UIAlertController(title: nil, message: NSLocalizedString("Choose a playlist for your workouts", comment: ""), preferredStyle: .actionSheet)
			
			let myMediaQuery = MPMediaQuery.playlists()
			let array = myMediaQuery.collections!
			for item in array {
				let value = item.value(forProperty: MPMediaPlaylistPropertyName) as! String
				optionMenu.addAction(UIAlertAction(title: value, style: .default, handler: {
					(alert: UIAlertAction!) -> Void in
					UserDefaults.standard.set(value, forKey: "playlistName")
					self.tableView.reloadData()
				}))
			}
			
			let cancelAction = UIAlertAction(title: NSLocalizedString("No Music", comment: ""), style: .cancel, handler: {
				(alert: UIAlertAction!) -> Void in
				UserDefaults.standard.set(nil, forKey: "playlistName")
				self.tableView.reloadData()
			})
			
			 optionMenu.addAction(cancelAction)
			
			self.present(optionMenu, animated: true, completion: nil)
		default:
			break
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell()

		switch indexPath.row {
		case 0:
			cell.textLabel?.text = NSLocalizedString("Restore Purchases", comment: "")
		case 1:
			cell.textLabel?.text = NSLocalizedString("Submit New Workout Idea", comment: "")
		case 2:
			cell.textLabel?.text = NSLocalizedString("Leave Feedback", comment: "")
		case 3:
			var name = UserDefaults.standard.string(forKey: "playlistName")
			if name == nil {
				name = NSLocalizedString("Unset", comment: "")
			}
			cell.textLabel?.text = NSLocalizedString("Music Playlist", comment: "") + ": " + name!
		default:
			cell.textLabel?.text = NSLocalizedString("Version ", comment:"") + String(stringInterpolationSegment: Bundle.main.infoDictionary!["CFBundleShortVersionString"]!)
			cell.selectionStyle = .none
			break
		}
		
		cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
		cell.textLabel?.textColor = UIColor.white
		cell.separatorInset = UIEdgeInsets.zero
		cell.backgroundColor = UIColor(red: 0.173, green: 0.251, blue: 0.325, alpha: 1.00)

        return cell
    }

}

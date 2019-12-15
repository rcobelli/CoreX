//
//  StoreManager.swift
//  core-x
//
//  Created by Ryan Cobelli on 2/5/17.
//  Copyright © 2017 Rybel LLC. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit

extension UIViewController {
	
	func buyWorkout(_ row: Int) {
		var id = ""
		switch row {
		case 1:
			id = "com.rybel_llc.core_x.myrtl"
			break
		case 2:
			id = "com.rybel_llc.core_x.leg_day"
			break
		case 3:
			id = "com.rybel_llc.core_x.pushups"
			break
		case 4:
			id = "com.rybel_llc.core_x.yoga"
			break
		case 5:
			id = "com.rybel_llc.core_x.coach_liz"
			break
		default:
			return
		}
		
		SwiftyStoreKit.purchaseProduct(id, atomically: true) { result in
			switch result {
			case .success(let product):
				print("Purchase Success: \(product.productId)")
				self.deliverProduct(product.productId)
			case .error(let error):
				SweetAlert().showAlert("Purchasing Workout", subTitle: "Something went wrong. Please try again", style: AlertStyle.error)
				print("Purchase Failed: \(error)")
			}
		}
	}
	
	func deliverProduct(_ identifier: String) {
		print("Identifier: " + identifier)
		if identifier == "com.rybel_llc.core_x.myrtl" {
			UserDefaults.standard.set(true, forKey: "workout1")
		}
		else if identifier == "com.rybel_llc.core_x.leg_day" {
			UserDefaults.standard.set(true, forKey: "workout2")
		}
		else if identifier == "com.rybel_llc.core_x.pushups" {
			UserDefaults.standard.set(true, forKey: "workout3")
		}
		else if identifier == "com.rybel_llc.core_x.yoga" {
			UserDefaults.standard.set(true, forKey: "workout4")
		}
		else if identifier == "com.rybel_llc.core_x.coach_liz" {
			UserDefaults.standard.set(true, forKey: "workout5")
		}
		
		SweetAlert().showAlert("Purchased Workout", subTitle: "Success!", style: AlertStyle.success)
		
		UserDefaults.standard.synchronize()
		viewWillAppear(true)
	}
	
	func shouldDisplayAd() -> Bool {
		if UserDefaults.standard.bool(forKey: "workout1") || UserDefaults.standard.bool(forKey: "workout2") ||
			UserDefaults.standard.bool(forKey: "workout3") || UserDefaults.standard.bool(forKey: "workout4") ||
			UserDefaults.standard.bool(forKey: "workout5") ||
			UserDefaults.standard.bool(forKey: "removedAds") || ProcessInfo.processInfo.arguments.contains("testing") {
			return false
		}
		return true
	}
}

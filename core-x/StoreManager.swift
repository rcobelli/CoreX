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
		SwiftyStoreKit.purchaseProduct(WorkoutDataManager.getWorkoutStoreID(workoutID: row), atomically: true) { result in
			switch result {
			case .success(let product):
				print("Purchase Success: \(product.productId)")
				
				self.deliverProduct(product.productId)
			case .error(let error):
				print("Purchase Failed: \(error)")
				
				let alertController = UIAlertController(title: "Purchasing Workout",
														message: "Something went wrong. Please try again",
														preferredStyle: .alert)
				let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
				alertController.addAction(action)
				self.present(alertController, animated: true, completion: nil)
			}
		}
	}
	
	func deliverProduct(_ identifier: String) {
		print("Identifier: " + identifier)
		UserDefaults.standard.set(true, forKey: "workout\(WorkoutDataManager.getWorkoutId(storeID: identifier))")
		
		let alertController = UIAlertController(title: "Purchased Workout", message: "Success!", preferredStyle: .alert)
		let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
		alertController.addAction(action)
		self.present(alertController, animated: true, completion: nil)
		
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

struct ReviewKitHelper {
	static let numberOfTimesLaunchedKey = "numberOfTimesLaunched"
	
	static func displayReviewPrompt() {
		guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String else {
			return
		}
		
		let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: "lastVersion")
		let numberOfTimesLaunched = UserDefaults.standard.integer(forKey: numberOfTimesLaunchedKey)
		
		if numberOfTimesLaunched > 2 && currentVersion != lastVersionPromptedForReview
			&& !ProcessInfo.processInfo.arguments.contains("testing") {
			
			forceDisplayReviewPrompt()
			UserDefaults.standard.set(currentVersion, forKey: "lastVersion")
		}
	}
	
	static func forceDisplayReviewPrompt() {
		if let scene = UIApplication.shared.connectedScenes
			.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
			
			SKStoreReviewController.requestReview(in: scene)
		}
	}
	
	static func incrementNumberOfTimesLaunched() {
		let numberOfTimesLaunched = UserDefaults.standard.integer(forKey: numberOfTimesLaunchedKey) + 1
		UserDefaults.standard.set(numberOfTimesLaunched, forKey: numberOfTimesLaunchedKey)
	}
}

//
//  ReviewKitHelper.swift
//  tv
//
//  Created by Ryan Cobelli on 11/18/22.
//  Copyright © 2022 Rybel LLC. All rights reserved.
//

import UIKit
import StoreKit

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

 //
//  AppDelegate.swift
//  core-x
//
//  Created by Ryan Cobelli on 12/12/15.
//  Copyright © 2015 Rybel LLC. All rights reserved.
//

import UIKit
import Appodeal
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		if let fileUrl = Bundle.main.url(forResource: "Creds", withExtension: "plist"), let myDict = NSDictionary(contentsOf: fileUrl) as? [String:Any] {
			// Init Appodeal
			Appodeal.initialize(withApiKey: myDict["AppodealAPIKey"] as! String, types: [.interstitial, .banner, .nonSkippableVideo])
			Appodeal.setLogLevel(.warning)
		}
		
		// Make sure Core X is always available
		UserDefaults.standard.set(true, forKey: "workout0")
		
		// Complete any outstanding transactions
		SwiftyStoreKit.completeTransactions(atomically: true) { products in
			for product in products {
				if product.transaction.transactionState == .purchased || product.transaction.transactionState == .restored {
					
					if product.needsFinishTransaction {
						// Deliver content from server, then:
						SwiftyStoreKit.finishTransaction(product.transaction)
					}
					print("purchased: \(product)")
					UIViewController().deliverProduct(product.productId)
				}
			}
		}
		
		return true
	}

	func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
		// Handle the siri shortcut
		let viewController = window?.rootViewController as! ViewController
		viewController.startMostRecentWorkout()
		
		return true
	}
	
	func applicationWillResignActive(_ application: UIApplication) {}

	func applicationDidEnterBackground(_ application: UIApplication) {}

	func applicationWillEnterForeground(_ application: UIApplication) {}

	func applicationDidBecomeActive(_ application: UIApplication) {}

	func applicationWillTerminate(_ application: UIApplication) {}


}

struct GlobalVariables {
	static var restDuration = 0
	static var exerciseDuration = 0
	static var exerciseID = 0
	static var workoutName = ""
}

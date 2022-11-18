//
//  AppDelegate.swift
//  tv
//
//  Created by Ryan Cobelli on 1/10/16.
//  Copyright © 2016 Rybel LLC. All rights reserved.
//

import UIKit
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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

	func applicationWillResignActive(_ application: UIApplication) {}

	func applicationDidEnterBackground(_ application: UIApplication) {}

	func applicationWillEnterForeground(_ application: UIApplication) {}

	func applicationDidBecomeActive(_ application: UIApplication) {}

	func applicationWillTerminate(_ application: UIApplication) {}

}

extension UIViewController {
	func isDarkMode() -> Bool {
		guard traitCollection.responds(to: #selector(getter: UITraitCollection.userInterfaceStyle))
			else { return true }
	
		let style = traitCollection.userInterfaceStyle
		switch style {
		case .light:
			return false
		case .dark:
			return true
		default:
			return false
		}
	}
}

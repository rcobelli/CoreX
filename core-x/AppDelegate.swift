//
//  AppDelegate.swift
//  core-x
//
//  Created by Ryan Cobelli on 12/12/15.
//  Copyright © 2015 Rybel LLC. All rights reserved.
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
		
		// Style the app
		let appearance = UINavigationBarAppearance()
		appearance.configureWithOpaqueBackground()
		appearance.backgroundColor = UIColor(red: 0.92, green: 0.24, blue: 0.21, alpha: 1.00)
		appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
		UINavigationBar.appearance().standardAppearance = appearance
		UINavigationBar.appearance().scrollEdgeAppearance = UINavigationBar.appearance().standardAppearance
		UINavigationBar.appearance().tintColor = UIColor.white
		
		UNUserNotificationCenter.current().delegate = self
		
		NSSetUncaughtExceptionHandler { exception in
		   print(exception)
		   print(exception.callStackSymbols)
		}
		
		ReviewKitHelper.incrementNumberOfTimesLaunched()
		
		return true
	}

	func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
		// Handle the siri shortcut
		guard let viewController = window?.rootViewController as? ViewController else {
			return false
		}
		viewController.startMostRecentWorkout()
		
		return true
	}
	
	func applicationWillResignActive(_ application: UIApplication) {}

	func applicationDidEnterBackground(_ application: UIApplication) {}

	func applicationWillEnterForeground(_ application: UIApplication) {}

	func applicationDidBecomeActive(_ application: UIApplication) {}

	func applicationWillTerminate(_ application: UIApplication) {}

}

extension AppDelegate: UNUserNotificationCenterDelegate {
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler([.banner, .list, .badge, .sound])
	}
}

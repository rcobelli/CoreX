 //
//  AppDelegate.swift
//  core-x
//
//  Created by Ryan Cobelli on 12/12/15.
//  Copyright © 2015 Rybel LLC. All rights reserved.
//

import UIKit
import Appodeal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
//		Appodeal.initializeWithApiKey("4c2593c394cb46d2059b6795109441e867ccbfe1b859b99a", types: [.Interstitial, .Banner, .NonSkippableVideo])

		NSUserDefaults.standardUserDefaults().setBool(true, forKey: "workout0")
		
		return true
	}
	
	@available(iOS 9, *)
	func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
		print(shortcutItem.type)
	}

	func applicationWillResignActive(application: UIApplication) {}

	func applicationDidEnterBackground(application: UIApplication) {}

	func applicationWillEnterForeground(application: UIApplication) {}

	func applicationDidBecomeActive(application: UIApplication) {}

	func applicationWillTerminate(application: UIApplication) {}


}

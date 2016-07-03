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
		// Init Appodeal
		Appodeal.initializeWithApiKey("4c2593c394cb46d2059b6795109441e867ccbfe1b859b99a", types: [.Interstitial, .Banner, .NonSkippableVideo])
		
		if !NSUserDefaults.standardUserDefaults().boolForKey("firstLaunch") {
			NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "workoutCount")
			NSUserDefaults.standardUserDefaults().setObject(NSDate(timeIntervalSince1970: 0), forKey: "lastWorkout")
		}
		
		NSUserDefaults.standardUserDefaults().setBool(true, forKey: "workout0")
		
		return true
	}

	func applicationWillResignActive(application: UIApplication) {}

	func applicationDidEnterBackground(application: UIApplication) {}

	func applicationWillEnterForeground(application: UIApplication) {}

	func applicationDidBecomeActive(application: UIApplication) {}

	func applicationWillTerminate(application: UIApplication) {}


}

struct GlobalVariables {
	static var restDuration = 0
	static var exerciseDuration = 0
	static var exerciseID = 0
}
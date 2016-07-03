//
//  AppDelegate.swift
//  tv
//
//  Created by Ryan Cobelli on 1/10/16.
//  Copyright © 2016 Rybel LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		
		if !NSUserDefaults.standardUserDefaults().boolForKey("firstLaunch") {
			NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "workoutCount")
			NSUserDefaults.standardUserDefaults().setObject(NSDate(timeIntervalSince1970: 0), forKey: "lastWorkout")
			
			NSUserDefaults.standardUserDefaults().setBool(true, forKey: "firstLaunch")
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
}



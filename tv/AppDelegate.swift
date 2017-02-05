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


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		if !UserDefaults.standard.bool(forKey: "firstLaunch") {
			UserDefaults.standard.set(0, forKey: "workoutCount")
			UserDefaults.standard.set(Date(timeIntervalSince1970: 0), forKey: "lastWorkout")
			
			UserDefaults.standard.set(true, forKey: "firstLaunch")
		}
		
		UserDefaults.standard.set(true, forKey: "workout0")

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
}



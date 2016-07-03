//
//  HealthManager.swift
//  HKTutorial
//
//  Created by ernesto on 18/10/14.
//  Copyright (c) 2014 raywenderlich. All rights reserved.
//

import Foundation
import HealthKit

class HealthManager {
  let healthKitStore:HKHealthStore = HKHealthStore()
  

  func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!) {

    // 2. Set the types you want to write to HK Store
    let healthKitTypesToWrite = Set(arrayLiteral:
      HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!,
      HKQuantityType.workoutType()
      )

    // 3. If the store is not available (for instance, iPad) return an error and don't go on.
    if !HKHealthStore.isHealthDataAvailable()
    {
      let error = NSError(domain: "com.raywenderlich.tutorials.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
      if( completion != nil )
      {
        completion(success:false, error:error)
      }
      return;
    }

    // 4.  Request HealthKit authorization
    healthKitStore.requestAuthorizationToShareTypes(healthKitTypesToWrite, readTypes: nil) { (success, error) -> Void in

      if( completion != nil )
      {
        completion(success:success,error:error)
      }
    }
  }


  
	func saveWorkout(duration:Double, workoutNumber: Int, completion: ( (Bool, NSError!) -> Void)!) {
		
		var calories = 0.0
		var workoutName = ""
		var totalDuration = 0.0
		
		switch workoutNumber {
		case 0:
			workoutName = "Core X"
			calories = 10.0 * (duration * 8.0)
			totalDuration = duration * 10.0
		case 1:
			workoutName = "Myrtl"
			calories = 14.0 * (duration * 4.0)
			totalDuration = duration * 14.0
		case 2:
			workoutName = "Leg-Day"
			calories = 9.0 * (duration * 2.0)
			totalDuration = duration * 9.0
		case 3:
			workoutName = "101 Pushups"
			calories = 20.0 * (duration * 20.0)
			totalDuration = duration * 20.0
		case 4:
			workoutName = "Yogata Be Kidding Me"
			calories = 11.0 * (duration * 2.0)
			totalDuration = duration * 11.0
		default:
			workoutName = "Coach Liz Stretch Routine"
			calories = 6.0 * (duration * 2.0)
			totalDuration = duration * 8.0
		}
	
      let caloriesQuantity = HKQuantity(unit: HKUnit.kilocalorieUnit(), doubleValue: calories)
      
      // 2. Save Running Workout
	let workout = HKWorkout(activityType: HKWorkoutActivityType.CrossTraining, startDate: NSDate().dateByAddingTimeInterval(-totalDuration), endDate: NSDate(), duration: totalDuration, totalEnergyBurned: caloriesQuantity, totalDistance: HKQuantity(unit: HKUnit.mileUnit(), doubleValue: 0.0), metadata: ["Workout Name": workoutName])
	healthKitStore.saveObject(workout, withCompletion: { (success, error) -> Void in
		completion(success,error)
	})
  }
  
}
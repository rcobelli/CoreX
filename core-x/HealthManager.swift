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
	let healthKitStore: HKHealthStore = HKHealthStore()
	
	func authorizeHealthKit() {
		if !HKHealthStore.isHealthDataAvailable() {
			print("Error saving HealthKit data, not available in this Device")
		}
		
		let healthKitTypesToWrite: Set = [
			HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!,
			HKQuantityType.workoutType()
		]
		
		healthKitStore.requestAuthorization(toShare: healthKitTypesToWrite, read: nil) { (success, error) -> Void in
			if success {
				print("HealthKit: Authorized")
			} else {
				print("HealthKit: Denied")
			}
			
			if let error = error { print(error) }
		}
	}
	
	func saveWorkout(_ duration: Double, workoutNumber: Int, completion: ( (Bool, NSError?) -> Void)!) {
		
		let calories = WorkoutDataManager.getWorkoutCalories(workoutID: workoutNumber, duration: duration)
		let totalDuration = duration * Double(WorkoutDataManager.getExerciseCountForWorkout(workoutID: workoutNumber))
		
		if HKHealthStore.isHealthDataAvailable() {
			let workout = HKWorkout(activityType: WorkoutDataManager.getWorkoutType(workoutID: workoutNumber),
									start: Date().addingTimeInterval(-totalDuration),
									end: Date(),
									duration: totalDuration,
									totalEnergyBurned: HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: calories),
									totalDistance: HKQuantity(unit: HKUnit.mile(), doubleValue: 0.0),
									metadata: nil)
			healthKitStore.save(workout, withCompletion: { (success, error) -> Void in
				if !success {
					print(error!)
				}
			})
		}
	}
	
}

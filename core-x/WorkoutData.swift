//
//  WorkoutData.swift
//  core-x
//
//  Created by Ryan Cobelli on 11/17/22.
//  Copyright © 2022 Rybel LLC. All rights reserved.
//

import UIKit
import HealthKit

struct WorkoutDataManager {
	static func getWorkoutLogo(workoutID: Int) -> UIImage {
		switch workoutID {
		case 1:
			return UIImage(named: "myrtl")!
		case 2:
			return UIImage(named: "leg-day")!
		case 3:
			return UIImage(named: "pushup")!
		case 4:
			return UIImage(named: "yoga")!
		case 5:
			return UIImage(named: "coachLiz")!
		default:
			return UIImage(named: "core-x")!
		}
	}
	
	static func getWorkoutType(workoutID: Int) -> HKWorkoutActivityType {
		switch workoutID {
		case 1:
			return HKWorkoutActivityType.flexibility
		case 2:
			return HKWorkoutActivityType.crossTraining
		case 3:
			return HKWorkoutActivityType.functionalStrengthTraining
		case 4:
			return HKWorkoutActivityType.yoga
		case 5:
			return HKWorkoutActivityType.flexibility
		default:
			return HKWorkoutActivityType.coreTraining
		}
	}
	
	static func getWorkoutCalories(workoutID: Int, duration: Double) -> Double {
		switch workoutID {
		case 0:
			return 10.0 * ((duration / 30.0) * 8.0)
		case 1:
			return 14.0 * ((duration / 20.0) * 4.0)
		case 2:
			return 9.0 * ((duration / 30.0) * 2.0)
		case 3:
			return 20.0 * ((duration / 20.0) * 20.0)
		case 4:
			return 11.0 * ((duration / 25.0) * 2.0)
		case 5:
			return 6.0 * ((duration / 25.0) * 2.0)
		default:
			return 0.0
		}
	}
	
	static func getExerciseCountForWorkout(workoutID: Int) -> Int {
		switch workoutID {
		case 0:
			return 10
		case 1:
			return 14
		case 2:
			return 9
		case 3:
			return 20
		case 4:
			return 11
		case 5:
			return 8
		default:
			return 0
		}
	}

	static func getWorkoutStoreID(workoutID: Int) -> String {
		switch workoutID {
		case 1:
			return "com.rybel_llc.core_x.myrtl"
		case 2:
			return "com.rybel_llc.core_x.leg_day"
		case 3:
			return "com.rybel_llc.core_x.pushups"
		case 4:
			return "com.rybel_llc.core_x.yoga"
		case 5:
			return "com.rybel_llc.core_x.coach_liz"
		default:
			return ""
		}
	}

	static func getWorkoutId(storeID: String) -> Int {
		switch storeID {
		case "com.rybel_llc.core_x.myrtl":
			return 1
		case "com.rybel_llc.core_x.leg_day":
			return 2
		case "com.rybel_llc.core_x.pushups":
			return 3
		case "com.rybel_llc.core_x.yoga":
			return 4
		case "com.rybel_llc.core_x.coach_liz":
			return 5
		default:
			return 0
		}
	}

	static func getWorkoutColor(workoutID: Int) -> UIColor {
		switch workoutID {
		case 0:
			return UIColor(red: 0.863, green: 0.820, blue: 0.282, alpha: 1.00) // #DCD148
		case 1:
			return UIColor(red: 0.537, green: 0.612, blue: 0.612, alpha: 1.00) // #889C9C
		case 2:
			return UIColor(red: 0.106, green: 0.557, blue: 0.839, alpha: 1.00) // #1B8ED5
		case 3:
			return UIColor(red: 0.173, green: 0.251, blue: 0.325, alpha: 1.00) // #2C4052
		case 4:
			return UIColor(red: 0.000, green: 0.718, blue: 0.573, alpha: 1.00) // #00B792
		case 5:
			return UIColor(red: 0.580, green: 0.290, blue: 0.675, alpha: 1.00) // #944AAC
		default:
			return UIColor.white
		}
	}

	static func getWorkoutCount() -> Int {
		return 6
	}
}

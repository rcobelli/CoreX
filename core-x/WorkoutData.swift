//
//  WorkoutData.swift
//  core-x
//
//  Created by Ryan Cobelli on 11/17/22.
//  Copyright © 2022 Rybel LLC. All rights reserved.
//

import UIKit
#if os(iOS) || os(watchOS)
import HealthKit
#endif

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
		case 6:
			return UIImage(named: "hannah")!
		default:
			return UIImage(named: "core-x")!
		}
	}
	
	#if os(iOS) || os(watchOS)
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
		case 6:
			return HKWorkoutActivityType.coreTraining
		default:
			return HKWorkoutActivityType.coreTraining
		}
	}
	#endif
	
	static func getWorkoutCalories(workoutID: Int, duration: Double) -> Double {
		switch workoutID {
		case 0:
			return Double(getExerciseCountForWorkout(workoutID: workoutID)) * ((duration / 30.0) * 8.0)
		case 1:
			return Double(getExerciseCountForWorkout(workoutID: workoutID)) * ((duration / 20.0) * 4.0)
		case 2:
			return Double(getExerciseCountForWorkout(workoutID: workoutID)) * ((duration / 30.0) * 2.0)
		case 3:
			return Double(getExerciseCountForWorkout(workoutID: workoutID)) * ((duration / 20.0) * 20.0)
		case 4:
			return Double(getExerciseCountForWorkout(workoutID: workoutID)) * ((duration / 25.0) * 2.0)
		case 5:
			return Double(getExerciseCountForWorkout(workoutID: workoutID)) * ((duration / 25.0) * 2.0)
		case 6:
			return Double(getExerciseCountForWorkout(workoutID: workoutID)) * ((duration / 28.0) * 2.0)
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
		case 6:
			return 7
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
		case 6:
			return "com.rybel_llc.core_x.coach_hannah"
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
		case "com.rybel_llc.core_x.coach_hannah":
			return 6
		default:
			return 0
		}
	}
	
	static func getWorkoutName(workoutID: Int) -> String {
		switch workoutID {
		case 0:
			return "Core X"
		case 1:
			return "Myrtl"
		case 2:
			return "Leg-Day"
		case 3:
			return "101 Pushups"
		case 4:
			return "Yogata Be Kidding Me"
		case 5:
			return "Coach Liz Stretch Routine"
		case 6:
			return "Coach Hannah Core Routine"
		default:
			return ""
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
		case 6:
			return UIColor(red: 0.07, green: 0.52, blue: 0.48, alpha: 1.00) // #11857B
		default:
			return UIColor.white
		}
	}

	static func getWorkoutCount() -> Int {
		return 7
	}
}

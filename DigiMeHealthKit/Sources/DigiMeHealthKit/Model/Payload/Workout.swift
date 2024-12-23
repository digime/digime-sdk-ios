//
//  Workout.swift
//  DigiMeHealthKit
//
//  Created on 25.09.20.
//

import CryptoKit
import DigiMeCore
import HealthKit

public struct Workout: PayloadIdentifiable, Sample {
    public struct Harmonized: Codable, Hashable {
        public let value: Int
        public let description: String
        public let totalEnergyBurned: Double?
        public let totalEnergyBurnedUnit: String
        public let totalDistance: Double?
        public let totalDistanceUnit: String
        public let totalSwimmingStrokeCount: Double?
        public let totalSwimmingStrokeCountUnit: String
        public let totalFlightsClimbed: Double?
        public let totalFlightsClimbedUnit: String
        public let metadata: Metadata?

		public init(value: Int,
					description: String,
					totalEnergyBurned: Double?,
					totalEnergyBurnedUnit: String,
					totalDistance: Double?,
					totalDistanceUnit: String,
					totalSwimmingStrokeCount: Double?,
					totalSwimmingStrokeCountUnit: String,
					totalFlightsClimbed: Double?,
					totalFlightsClimbedUnit: String,
					metadata: Metadata?) {
			
            self.value = value
            self.description = description
            self.totalEnergyBurned = totalEnergyBurned
            self.totalEnergyBurnedUnit = totalEnergyBurnedUnit
            self.totalDistance = totalDistance
            self.totalDistanceUnit = totalDistanceUnit
            self.totalSwimmingStrokeCount = totalSwimmingStrokeCount
            self.totalSwimmingStrokeCountUnit = totalSwimmingStrokeCountUnit
            self.totalFlightsClimbed = totalFlightsClimbed
            self.totalFlightsClimbedUnit = totalFlightsClimbedUnit
            self.metadata = metadata
        }

		public func copyWith(value: Int? = nil,
							 description: String? = nil,
							 totalEnergyBurned: Double? = nil,
							 totalEnergyBurnedUnit: String? = nil,
							 totalDistance: Double? = nil,
							 totalDistanceUnit: String? = nil,
							 totalSwimmingStrokeCount: Double? = nil,
							 totalSwimmingStrokeCountUnit: String? = nil,
							 totalFlightsClimbed: Double? = nil,
							 totalFlightsClimbedUnit: String? = nil,
							 metadata: Metadata? = nil) -> Harmonized {
            
			return Harmonized(
                value: value ?? self.value,
                description: description ?? self.description,
                totalEnergyBurned: totalEnergyBurned ?? self.totalEnergyBurned,
                totalEnergyBurnedUnit: totalEnergyBurnedUnit ?? self.totalEnergyBurnedUnit,
                totalDistance: totalDistance ?? self.totalDistance,
                totalDistanceUnit: totalDistanceUnit ?? self.totalDistanceUnit,
                totalSwimmingStrokeCount: totalSwimmingStrokeCount ?? self.totalSwimmingStrokeCount,
                totalSwimmingStrokeCountUnit: totalSwimmingStrokeCountUnit ?? self.totalSwimmingStrokeCountUnit,
                totalFlightsClimbed: totalFlightsClimbed ?? self.totalFlightsClimbed,
                totalFlightsClimbedUnit: totalFlightsClimbedUnit ?? self.totalFlightsClimbedUnit,
                metadata: metadata ?? self.metadata
            )
        }
    }

    public let id: String
    public let identifier: String
    public let startTimestamp: Double
    public let endTimestamp: Double
    public let device: Device?
    public let sourceRevision: SourceRevision
    public let duration: Double
    public let workoutEvents: [WorkoutEvent]
    public let harmonized: Harmonized

    init(workout: HKWorkout) throws {
        self.id = workout.uuid.uuidString
        self.identifier = workout.sampleType.identifier
        self.startTimestamp = workout.startDate.timeIntervalSince1970
        self.endTimestamp = workout.endDate.timeIntervalSince1970
        self.device = Device(device: workout.device)
        self.sourceRevision = SourceRevision(sourceRevision: workout.sourceRevision)
        self.duration = workout.duration
        var workoutEvents = [WorkoutEvent]()
        if let events = workout.workoutEvents {
            for element in events {
                do {
                    let workoutEvent = try WorkoutEvent(workoutEvent: element)
                    workoutEvents.append(workoutEvent)
                }
				catch {
                    continue
                }
            }
        }
        self.workoutEvents = workoutEvents
        self.harmonized = try workout.harmonize()
    }

	public init(identifier: String,
				startTimestamp: Double,
				endTimestamp: Double,
				device: Device?,
				sourceRevision: SourceRevision,
				duration: Double,
				workoutEvents: [WorkoutEvent],
				harmonized: Harmonized) {
		
        self.identifier = identifier
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.device = device
        self.sourceRevision = sourceRevision
        self.duration = duration
        self.workoutEvents = workoutEvents
        self.harmonized = harmonized
        self.id = Self.generateHashId(
            identifier: identifier,
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp,
            device: device,
            sourceRevision: sourceRevision,
            duration: duration,
            workoutEvents: workoutEvents,
            harmonized: harmonized
        )
    }

	public func copyWith(identifier: String? = nil,
						 startTimestamp: Double? = nil,
						 endTimestamp: Double? = nil,
						 device: Device? = nil,
						 sourceRevision: SourceRevision? = nil,
						 duration: Double? = nil,
						 workoutEvents: [WorkoutEvent]? = nil,
						 harmonized: Harmonized? = nil) -> Workout {
		
		return Workout(identifier: identifier ?? self.identifier,
					   startTimestamp: startTimestamp ?? self.startTimestamp,
					   endTimestamp: endTimestamp ?? self.endTimestamp,
					   device: device ?? self.device,
					   sourceRevision: sourceRevision ?? self.sourceRevision,
					   duration: duration ?? self.duration,
					   workoutEvents: workoutEvents ?? self.workoutEvents,
					   harmonized: harmonized ?? self.harmonized)
	}

    private static func generateHashId(identifier: String,
                                       startTimestamp: Double,
                                       endTimestamp: Double,
                                       device: Device?,
                                       sourceRevision: SourceRevision,
                                       duration: Double,
                                       workoutEvents: [WorkoutEvent],
                                       harmonized: Harmonized) -> String {
        let deviceId = device?.id ?? "no_device"
        let workoutEventsHash = workoutEvents.map { $0.id }.joined(separator: "_")
        let idString = "\(identifier)_\(startTimestamp)_\(endTimestamp)_\(deviceId)_\(sourceRevision.id)_\(duration)_\(workoutEventsHash)_\(harmonized.hashValue)"
        let inputData = Data(idString.utf8)
        let hashed = SHA256.hash(data: inputData)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()

        return String(format: "%@-%@-%@-%@-%@",
                      String(hashString.prefix(8)),
                      String(hashString.dropFirst(8).prefix(4)),
                      String(hashString.dropFirst(12).prefix(4)),
                      String(hashString.dropFirst(16).prefix(4)),
                      String(hashString.dropFirst(20).prefix(12))
        )
    }
}

// MARK: - Original
extension Workout: Original {
    func asOriginal() throws -> HKWorkout {
        guard let activityType = HKWorkoutActivityType(rawValue: UInt(harmonized.value)) else {
            throw SDKError.invalidType(
                message: "Workout type: \(harmonized.value) could not be formatted"
            )
        }
        
        if #available(iOS 16.0, *) {
            // Use HKWorkoutBuilder for iOS 16.0 and later
            let configuration = HKWorkoutConfiguration()
            configuration.activityType = activityType
            
            let builder = HKWorkoutBuilder(healthStore: HKHealthStore(), configuration: configuration, device: device?.asOriginal())
            
            var builderError: Error?
            
            // Begin collection
            builder.beginCollection(withStart: startTimestamp.asDate) { success, error in
                if let error = error {
                    builderError = error
                }
            }
            
            // Add workout events
            for event in workoutEvents {
                do {
                    let originalEvent = try event.asOriginal()
                    builder.addWorkoutEvents([originalEvent]) { success, error in
                        if let error = error {
                            builderError = error
                        }
                    }
                } catch {
                    builderError = error
                    break
                }
            }
            
            // Add quantities if available
            if let totalEnergyBurned = harmonized.totalEnergyBurned {
                let quantity = HKQuantity(unit: HKUnit(from: harmonized.totalEnergyBurnedUnit), doubleValue: totalEnergyBurned)
                let sample = HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!, quantity: quantity, start: startTimestamp.asDate, end: endTimestamp.asDate)
                builder.add([sample]) { success, error in
                    if let error = error {
                        builderError = error
                    }
                }
            }
            
            if let totalDistance = harmonized.totalDistance {
                let quantity = HKQuantity(unit: HKUnit(from: harmonized.totalDistanceUnit), doubleValue: totalDistance)
                let sample = HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!, quantity: quantity, start: startTimestamp.asDate, end: endTimestamp.asDate)
                builder.add([sample]) { success, error in
                    if let error = error {
                        builderError = error
                    }
                }
            }
            
            if let totalSwimmingStrokeCount = harmonized.totalSwimmingStrokeCount {
                let quantity = HKQuantity(unit: HKUnit(from: harmonized.totalSwimmingStrokeCountUnit), doubleValue: totalSwimmingStrokeCount)
                let sample = HKQuantitySample(type: HKQuantityType.quantityType(forIdentifier: .swimmingStrokeCount)!, quantity: quantity, start: startTimestamp.asDate, end: endTimestamp.asDate)
                builder.add([sample]) { success, error in
                    if let error = error {
                        builderError = error
                    }
                }
            }
            
            // End collection
            builder.endCollection(withEnd: endTimestamp.asDate) { success, error in
                if let error = error {
                    builderError = error
                }
            }
            
            // If we encountered any error during the building process, throw it
            if let builderError = builderError {
                throw builderError
            }
            
            // Finish workout
            var workoutResult: HKWorkout?
            var finishError: Error?
            builder.finishWorkout { workout, error in
                if let error = error {
                    finishError = error
                } else {
                    workoutResult = workout
                }
            }
            
            // Wait for the workout to be finished
            // Note: In a real-world scenario, you might want to handle this asynchronously
            while workoutResult == nil && finishError == nil {
                RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
            }
            
            // If we encountered an error while finishing the workout, throw it
            if let finishError = finishError {
                throw finishError
            }
            
            // If we somehow don't have a workout at this point, throw an error
            guard let finalWorkout = workoutResult else {
                throw SDKError.invalidValue(message: "Failed to create workout")
            }
            
            return finalWorkout
            
        } else {
            // Fallback for iOS versions prior to 16.0
            return HKWorkout(
                activityType: activityType,
                start: startTimestamp.asDate,
                end: endTimestamp.asDate,
                workoutEvents: try workoutEvents.map { try $0.asOriginal() },
                totalEnergyBurned: harmonized.totalEnergyBurned != nil
                    ? HKQuantity(
                        unit: HKUnit(from: harmonized.totalEnergyBurnedUnit),
                        doubleValue: harmonized.totalEnergyBurned!
                    )
                    : nil,
                totalDistance: harmonized.totalDistance != nil
                    ? HKQuantity(
                        unit: HKUnit(from: harmonized.totalDistanceUnit),
                        doubleValue: harmonized.totalDistance!
                    )
                    : nil,
                totalSwimmingStrokeCount: harmonized.totalSwimmingStrokeCount != nil
                    ? HKQuantity(
                        unit: HKUnit(from: harmonized.totalSwimmingStrokeCountUnit),
                        doubleValue: harmonized.totalSwimmingStrokeCount!
                    )
                    : nil,
                device: device?.asOriginal(),
                metadata: harmonized.metadata?.original
            )
        }
    }
}

// MARK: - Payload

extension Workout: Payload {
	public static func make(from dictionary: [String: Any]) throws -> Workout {
		guard
			let identifier = dictionary["identifier"] as? String,
			let startTimestamp = dictionary["startTimestamp"] as? NSNumber,
			let endTimestamp = dictionary["endTimestamp"] as? NSNumber,
			let duration = dictionary["duration"] as? NSNumber,
			let sourceRevision = dictionary["sourceRevision"] as? [String: Any],
			let harmonized = dictionary["harmonized"] as? [String: Any] else {
			
			throw SDKError.invalidValue(message: "Invalid dictionary: \(dictionary)")
		}
		
		let device = dictionary["device"] as? [String: Any]
		let workoutEvents = dictionary["workoutEvents"] as? [[String: Any]]
		
		return Workout(identifier: identifier,
					   startTimestamp: Double(truncating: startTimestamp),
					   endTimestamp: Double(truncating: endTimestamp),
					   device: device != nil
					   ? try Device.make(from: device!)
					   : nil,
					   sourceRevision: try SourceRevision.make(from: sourceRevision),
					   duration: Double(truncating: duration),
					   workoutEvents: workoutEvents != nil
					   ? try workoutEvents!.map {
			try WorkoutEvent.make(from: $0)
		}
					   : [],
					   harmonized: try Harmonized.make(from: harmonized))
	}
    public static func collect(results: [HKSample]) -> [Workout] {
        var samples = [Workout]()
        if let workouts = results as? [HKWorkout] {
            for workout in workouts {
                do {
                    let sample = try Workout(
                        workout: workout
                    )
                    samples.append(sample)
                } catch {
                    continue
                }
            }
        }
		
        return samples
    }
}

// MARK: - Payload
extension Workout.Harmonized: Payload {
	public static func make(from dictionary: [String: Any]) throws -> Workout.Harmonized {
		guard
			let value = dictionary["value"] as? Int,
			let description = dictionary["description"] as? String,
			let totalEnergyBurnedUnit = dictionary["totalEnergyBurnedUnit"] as? String,
			let totalDistanceUnit = dictionary["totalDistanceUnit"] as? String,
			let totalSwimmingStrokeCountUnit = dictionary["totalSwimmingStrokeCountUnit"] as? String,
			let totalFlightsClimbedUnit = dictionary["totalFlightsClimbedUnit"] as? String else {
			
			throw SDKError.invalidValue(message: "Invalid dictionary: \(dictionary)")
		}
		
		let totalEnergyBurned = dictionary["totalEnergyBurned"] as? NSNumber
		let totalDistance = dictionary["totalDistance"] as? NSNumber
		let totalSwimmingStrokeCount = dictionary["totalSwimmingStrokeCount"] as? NSNumber
		let totalFlightsClimbed = dictionary["totalFlightsClimbed"] as? NSNumber
		let metadata = dictionary["metadata"] as? [String: Any]
		return Workout.Harmonized(value: value,
								  description: description,
								  totalEnergyBurned: totalEnergyBurned != nil
								  ? Double(truncating: totalEnergyBurned!)
								  : nil,
								  totalEnergyBurnedUnit: totalEnergyBurnedUnit,
								  totalDistance:  totalDistance != nil
								  ? Double(truncating: totalDistance!)
								  : nil,
								  totalDistanceUnit: totalDistanceUnit,
								  totalSwimmingStrokeCount:  totalSwimmingStrokeCount != nil
								  ? Double(truncating: totalSwimmingStrokeCount!)
								  : nil,
								  totalSwimmingStrokeCountUnit: totalSwimmingStrokeCountUnit,
								  totalFlightsClimbed:  totalFlightsClimbed != nil
								  ? Double(truncating: totalFlightsClimbed!)
								  : nil,
								  totalFlightsClimbedUnit: totalFlightsClimbedUnit,
								  metadata: metadata?.asMetadata)
	}
}

//
//  HeartbeatSeries.swift
//  DigiMeSDK
//
//  Created on 12.10.21.
//

import CryptoKit
import DigiMeCore
import HealthKit

public struct HeartbeatSeries: PayloadIdentifiable, Sample, Identifiable {
    public struct Measurement: Codable, Hashable {
        public let timeSinceSeriesStart: Double
        public let precededByGap: Bool
        public let done: Bool

        public init(
            timeSinceSeriesStart: Double,
            precededByGap: Bool,
            done: Bool
        ) {
            self.timeSinceSeriesStart = timeSinceSeriesStart
            self.precededByGap = precededByGap
            self.done = done
        }
    }

    public struct Harmonized: Codable, Hashable {
        public let count: Int
        public let measurements: [Measurement]
        public let metadata: Metadata?

        public init(count: Int, measurements: [Measurement], metadata: Metadata?) {
            self.count = count
            self.measurements = measurements
            self.metadata = metadata
        }

        public func copyWith(count: Int? = nil,
                             measurements: [Measurement]? = nil,
                             metadata: Metadata? = nil) -> Harmonized {
            return Harmonized(count: count ?? self.count,
                              measurements: measurements ?? self.measurements,
                              metadata: metadata ?? self.metadata)
        }
    }

    public let id: String
    public let identifier: String
    public let startTimestamp: Double
    public let endTimestamp: Double
    public let device: Device?
    public let sourceRevision: SourceRevision
    public let harmonized: Harmonized
    
	public init(identifier: String,
				startTimestamp: Double,
				endTimestamp: Double,
				device: Device?,
				sourceRevision: SourceRevision,
				harmonized: Harmonized) {
        self.identifier = identifier
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.device = device
        self.sourceRevision = sourceRevision
        self.harmonized = harmonized
        self.id = Self.generateHashId(
            identifier: identifier,
            startTimestamp: startTimestamp,
            endTimestamp: endTimestamp,
            device: device,
            sourceRevision: sourceRevision,
            harmonized: harmonized
        )
    }

    init(sample: HKHeartbeatSeriesSample, measurements: [Measurement]) {
        self.identifier = sample.sampleType.identifier
        self.startTimestamp = sample.startDate.timeIntervalSince1970
        self.endTimestamp = sample.endDate.timeIntervalSince1970
        self.device = Device(device: sample.device)
        self.sourceRevision = SourceRevision(sourceRevision: sample.sourceRevision)
        self.harmonized = sample.harmonize(measurements: measurements)
        self.id = Self.generateHashId(
            identifier: self.identifier,
            startTimestamp: self.startTimestamp,
            endTimestamp: self.endTimestamp,
            device: self.device,
            sourceRevision: self.sourceRevision,
            harmonized: self.harmonized
        )
    }

    private static func generateHashId(identifier: String,
                                       startTimestamp: Double,
                                       endTimestamp: Double,
                                       device: Device?,
                                       sourceRevision: SourceRevision,
                                       harmonized: Harmonized) -> String {
        let deviceId = device?.id ?? "no_device"
        let idString = "\(identifier)_\(startTimestamp)_\(endTimestamp)_\(deviceId)_\(sourceRevision.id)_\(harmonized.count)_\(harmonized.measurements.hashValue)"
        let inputData = Data(idString.utf8)
        let hashed = SHA256.hash(data: inputData)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()

        // Format the hash string as a UUID
        return String(format: "%@-%@-%@-%@-%@",
                      String(hashString.prefix(8)),
                      String(hashString.dropFirst(8).prefix(4)),
                      String(hashString.dropFirst(12).prefix(4)),
                      String(hashString.dropFirst(16).prefix(4)),
                      String(hashString.dropFirst(20).prefix(12))
        )
    }
}

// MARK: - Payload
extension HeartbeatSeries: Payload {
	public static func make(from dictionary: [String: Any]) throws -> HeartbeatSeries {
		guard
			let identifier = dictionary["identifier"] as? String,
			let startTimestamp = dictionary["startTimestamp"] as? NSNumber,
			let endTimestamp = dictionary["endTimestamp"] as? NSNumber,
			let sourceRevision = dictionary["sourceRevision"] as? [String: Any],
			let harmonized = dictionary["harmonized"] as? [String: Any]
		else {
			throw SDKError.invalidValue(message: "Invalid dictionary: \(dictionary)")
		}
		let device = dictionary["device"] as? [String: Any]
		return HeartbeatSeries(identifier: identifier,
							   startTimestamp: Double(truncating: startTimestamp),
							   endTimestamp: Double(truncating: endTimestamp),
							   device: device != nil
							   ? try Device.make(from: device!)
							   : nil,
							   sourceRevision: try SourceRevision.make(from: sourceRevision),
							   harmonized: try Harmonized.make(from: harmonized))
	}
}

// MARK: - Payload
extension HeartbeatSeries.Harmonized: Payload {
    public static func make(from dictionary: [String: Any]) throws -> HeartbeatSeries.Harmonized {
        guard
            let count = dictionary["count"] as? Int,
            let measurements = dictionary["measurements"] as? [Any] else {
			throw SDKError.invalidValue(message: "Invalid dictionary: \(dictionary)")
        }
		
        let metadata = dictionary["metadata"] as? [String: Any]
        return HeartbeatSeries.Harmonized(
            count: count,
            measurements: try HeartbeatSeries.Measurement.collect(from: measurements),
            metadata: metadata?.asMetadata
        )
    }
}

// MARK: - Payload
extension HeartbeatSeries.Measurement: Payload {
    public static func make(from dictionary: [String: Any]) throws -> HeartbeatSeries.Measurement {
        guard
            let timeSinceSeriesStart = dictionary["timeSinceSeriesStart"] as? NSNumber,
            let precededByGap = dictionary["precededByGap"] as? Bool,
            let done = dictionary["done"] as? Bool else {
			
			throw SDKError.invalidValue(message: "Invalid dictionary: \(dictionary)")
        }
		
		return HeartbeatSeries.Measurement(timeSinceSeriesStart: Double(truncating: timeSinceSeriesStart),
										   precededByGap: precededByGap,
										   done: done)
    }
	
    public static func collect(from array: [Any]) throws -> [HeartbeatSeries.Measurement] {
        var measurements = [HeartbeatSeries.Measurement]()
        for element in array {
            if let dictionary = element as? [String: Any] {
                let measurement = try HeartbeatSeries.Measurement.make(from: dictionary)
                measurements.append(measurement)
            }
        }
        return measurements
    }
}

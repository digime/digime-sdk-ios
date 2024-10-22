//
//  Extensions+HKWorkoutEventType.swift
//  DigiMeHealthKit
//
//  Created on 05/09/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import HealthKit

extension HKWorkoutEventType {
    public var description: String {
        switch self {
        case .pause:
            return "Pause"
        case .resume:
            return "Resume"
        case .lap:
            return "Lap"
        case .marker:
            return "Marker"
        case .motionPaused:
            return "Motion paused"
        case .motionResumed:
            return "Motion Resumed"
        case .segment:
            return "Segment"
        case .pauseOrResumeRequest:
            return "Pause on resume request"
        @unknown default:
            fatalError()
        }
    }
}

//
//  KeyframeAnimation.swift
//  DigiMeSDKExample
//
//  Created on 12/03/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct KeyframeAnimation: AnimatableModifier {
	typealias OnCompleteHandler = (Int) -> Void
	
	private let keyframe: Int
	private var progressiveKeyframe: Double
	private let onComplete: OnCompleteHandler
	
	init(keyframe: Double, onComplete: @escaping OnCompleteHandler) {
		self.keyframe = Int(keyframe)
		self.progressiveKeyframe = keyframe
		self.onComplete = onComplete
	}
	
	var animatableData: Double {
		get { progressiveKeyframe }
		set {
			progressiveKeyframe = newValue
			if Int(progressiveKeyframe) == keyframe {
				onComplete(keyframe)
			}
		}
	}
	
	func body(content: Content) -> some View {
		content
	}
}

enum TimingFunction {
	case timingCurve(c0x: Double, c0y: Double, c1x: Double, c1y: Double)
	case linear
	case easeInOut
	
	func animation(duration: Double) -> Animation {
		switch self {
		case let .timingCurve(c0x, c0y, c1x, c1y):
			return .timingCurve(c0x, c0y, c1x, c1y, duration: duration)
		case .linear:
			return .linear(duration: duration)
		case .easeInOut:
			return .easeInOut(duration: duration)
		}
	}
}

class KeyframeIterator: IteratorProtocol {
    struct Element {
        var keyframe: Int
        var keyframeTracker: Animation
        var animation: Animation?
        var isLast: Bool
    }
	
	private let beginTime: Double
	private let duration: Double
	private let timingFunctions: [TimingFunction]
	private let keyTimes: [Double]
	private let durations: [Double]
	private let animations: [Animation]
	private var keyframe: Int = 0
	private var isRepeating = false
	
	init(beginTime: Double, duration: Double, timingFunctions: [TimingFunction], keyTimes: [Double]) {
		self.beginTime = beginTime
		self.duration = duration
		self.timingFunctions = timingFunctions
		self.keyTimes = keyTimes
		
		assert(keyTimes.count - timingFunctions.count == 1)
		
		let keyPercents = zip(keyTimes[0..<keyTimes.count - 1], keyTimes[1...])
			.map { $1 - $0 }
		let durations = keyPercents.map { duration * $0 }
		
		self.durations = durations + [0]
		animations = zip(durations, timingFunctions).map { duration, timingFunction in
			timingFunction.animation(duration: duration)
		}
	}
	
	func next() -> Element? {
		let isFirst = keyframe == 0
		let isLast = keyframe == keyTimes.count - 1
		let delay = isFirst && !isRepeating ? beginTime : 0
		let keyframeTracker = Animation.linear(duration: durations[keyframe]).delay(delay)
		let animation = isLast ? nil : animations[keyframe].delay(delay)
		let nextKeyframe = isLast ? 0 : keyframe + 1
        let element = Element(keyframe: nextKeyframe, keyframeTracker: keyframeTracker, animation: animation, isLast: isLast)
        
		if isLast {
			isRepeating = true
		}
		keyframe = nextKeyframe
		
		return element
	}
}

struct KeyframeAnimationController<T: View>: View {
	typealias Content = (Int) -> T
	
	@State private var keyframe: Double = 0
	@State private var animation: Animation?
	private let beginTime: Double
	private let duration: Double
	private let timingFunctions: [TimingFunction]
	private let keyTimes: [Double]
	private let keyframeIterator: KeyframeIterator
	private var content: Content
	
	var body: some View {
		content(Int(keyframe))
			.animation(animation, value: 0)
			.modifier(KeyframeAnimation(keyframe: self.keyframe, onComplete: handleComplete))
			.onAppear {
				self.nextKeyframe()
			}
	}
	
	init(beginTime: Double, duration: Double, timingFunctions: [TimingFunction], keyTimes: [Double], content: @escaping Content) {
		self.beginTime = beginTime
		self.duration = duration
		self.timingFunctions = timingFunctions
		self.keyTimes = keyTimes
		keyframeIterator = KeyframeIterator(beginTime: beginTime, duration: duration, timingFunctions: timingFunctions, keyTimes: keyTimes)
		self.content = content
	}
	
	private func handleComplete(_ keyframe: Int) {
		nextKeyframe()
	}
	
	private func nextKeyframe() {
		DispatchQueue.main.async {
			guard let data = self.keyframeIterator.next() else {
				return
			}
			
            let keyframe = data.keyframe
            let keyframeTracker = data.keyframeTracker
            let animation = data.animation

			self.animation = animation
			withAnimation(keyframeTracker) {
				self.keyframe = Double(keyframe)
			}
		}
	}
}

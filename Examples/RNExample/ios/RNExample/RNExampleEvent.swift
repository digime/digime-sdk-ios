//
//  RNExampleEvent.swift
//  RNExample
//
//  Created on 18/04/2022.
//  Copyright © 2022 digi.me. All rights reserved.
//

import Foundation
import React

@objc(RNExampleEvent)
class RNExampleEvent: RCTEventEmitter {
  
  public static var shared: RNExampleEvent?
  
  override private init() {
    super.init()
    RNExampleEvent.shared = self
  }
  
  @objc
  override static func requiresMainQueueSetup() -> Bool {
    return false
  }
  
  override func supportedEvents() -> [String]! {
    return ["error", "result", "log"]
  }
  
  func error(error: Any) {
    self.sendEvent(withName: "error", body: error)
  }
  
  func result(result: Any) {
    self.sendEvent(withName: "result", body: result)
  }
  
  func log(message: String) {
    self.sendEvent(withName: "log", body: message)
  }
}


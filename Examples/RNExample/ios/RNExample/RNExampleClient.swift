//
//  RNExampleClient.swift
//  RNExample
//
//  Created on 18/04/2022.
//  Copyright © 2022 digi.me. All rights reserved.
//

import Foundation
import React
import DigiMeSDK
import HealthKit

@objc(RNExampleClient)
class RNExampleClient: NSObject {
#if DEBUG
  private var records = [FitnessActivity]()
  private var sections = [(date: Date, records: [FitnessActivity])]()
#endif
  
  private let eventEmitter = RNExampleEvent.shared
  private var digiMe: DigiMe!
  private let contract = Contracts.appleHealth
  private var readOptions: ReadOptions?
  
  private var resultCompletion: RCTResponseSenderBlock?
  private var errorCompletion: RCTResponseErrorBlock?
  private var resolverCompletion: RCTPromiseResolveBlock?
  private var rejecterCompletion: RCTPromiseRejectBlock?
  
  @objc
  static func requiresMainQueueSetup() -> Bool {
    return false
  }
  
  // MARK: - Public
  
  @objc(retrieveData)
  public func retrieveData() -> Void {
    guard Thread.isMainThread else {
      DispatchQueue.main.async {
        self.retrieveData()
      }
      return
    }
    
    configureClient()
  }
  
  @objc(retrieveDataWithEventsFrom:to:)
  public func retrieveData(timeinterval from: TimeInterval, to: TimeInterval) {
    guard Thread.isMainThread else {
      DispatchQueue.main.async {
        self.retrieveData(timeinterval: from, to: to)
      }
      return
    }

    configureOptions(timeinterval: from, to: to)
    configureClient()
  }
  
  @objc(retrieveDataWithCompletionFrom:to:resultCompletion:errorCompletion:)
  public func retrieveData(timeinterval from: TimeInterval, to: TimeInterval, resultCompletion: @escaping RCTResponseSenderBlock, errorCompletion: @escaping RCTResponseErrorBlock) {
    guard Thread.isMainThread else {
      DispatchQueue.main.async {
        self.retrieveData(timeinterval: from, to: to, resultCompletion: resultCompletion, errorCompletion: errorCompletion)
      }
      return
    }
    
    self.resultCompletion = resultCompletion
    self.errorCompletion = errorCompletion
    configureOptions(timeinterval: from, to: to)
    configureClient()
  }
  
  @objc(retrieveDataWithPromisesFrom:to:successCallback:errorCallback:)
  public func retrieveData(timeinterval from: TimeInterval, to: TimeInterval, successCallback: @escaping RCTPromiseResolveBlock, errorCallback: @escaping RCTPromiseRejectBlock) {
    guard Thread.isMainThread else {
      DispatchQueue.main.async {
        self.retrieveData(timeinterval: from, to: to, successCallback: successCallback, errorCallback: errorCallback)
      }
      return
    }
    
    resolverCompletion = successCallback
    rejecterCompletion = errorCallback
    configureOptions(timeinterval: from, to: to)
    configureClient()
  }
  
#if targetEnvironment(simulator)
  /// iOS Simulator doesn't have any health data by default.
  /// Here we create random data for all time for demo purposes.
  @objc(addTestData)
  public func addTestData() {
    eventEmitter?.log(message: "Adding test data...")
    DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) { [self] in
      var dataToWrite: [HKQuantitySample] = []
      let startDate = Date(timeIntervalSince1970: 0)
      let endDate = Date().endOfTomorrow
      let dayDurationInSeconds: TimeInterval = 60 * 60 * 24
      var counter: Int = 0
      for date in stride(from: startDate, to: endDate, by: dayDurationInSeconds) {
        let end = Calendar.utcCalendar.date(byAdding: .day, value: -1, to: date)!.endOfDay
        let start = Calendar.utcCalendar.startOfDay(for: end)
        self.eventEmitter?.log(message: "Start: \(start) End: \(end)")
        // steps data
        let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let stepsQuantity = HKQuantity(unit: .count(), doubleValue: Double.random(in: 1...5000))
        let steps = HKQuantitySample(type: stepsType, quantity: stepsQuantity, start: start, end: end)
        dataToWrite.append(steps)
        
        // distance walking & running
        let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let distanceQuantity = HKQuantity(unit: .meter(), doubleValue: Double.random(in: 1...3000))
        let walk = HKQuantitySample(type: distanceType, quantity: distanceQuantity, start: start, end: end)
        dataToWrite.append(walk)
        counter += 1
      }
      
      digiMe.saveHealthData(dataToSave: dataToWrite) { result in
        DispatchQueue.main.async {
          var message = String()
          switch result {
            case .success(let success):
              message = "Data is \(success ? "saved" : "NOT saved"), \(counter) samples added."
            case .failure(let error):
              message = "An error occured saving test data: \(error)"
          }
          
          let alert = UIAlertController(title: "digi.me SDK", message: message, preferredStyle: .alert)
          alert.addAction(.init(title: "OK", style: .cancel) { _ in
            self.fetchData(readOptions: self.readOptions)
          })
          UIViewController.topMost()?.present(alert, animated: true)
        }
      }
    }
  }
#endif

  // MARK: - Private
  
  private func configureOptions(timeinterval from: TimeInterval, to: TimeInterval) {
    /// In this version of the SDK, the only supported object type is 'Fitness Activity'.
    /// This example is for demonstration purposes only.
    let objectType = ServiceObjectType(identifier: 300, name: "Fitness Activity")
    let services = [ServiceType(identifier: 28, objectTypes: [objectType])]
    let groups = [ServiceGroupScope(identifier: 4, serviceTypes: services)]
    /// Time ranges allow you to narrow down the contract's time scope.
    /// For example: if your contract allows you to gather data within one year
    /// then using the scope object you can get data for a month or for one day only, etc.
    /// Check 'TimeRange' class for options.
    let timeRange = TimeRange.between(from: Date(timeIntervalSince1970: from), to: Date(timeIntervalSince1970: to))
    let scope = Scope(serviceGroups: groups, timeRanges: [timeRange])
    self.readOptions = ReadOptions(limits: nil, scope: scope)
  }
  
  private func configureClient() {
    do {
      /// On initialization create a configuration object with digi.me contract details.
      let config = try Configuration(appId: Contracts.appId, contractId: contract.identifier, privateKey: contract.privateKey)
      digiMe = DigiMe(configuration: config)
      
      /// Fetch fitness data. Use read options to narrow down the fetch request.
      /// Options have to include the date range shorter than your digi.me contract.
      /// Options are optional parameters. If not present it will return data for the whole date range of the contract.
      fetchData(readOptions: readOptions)
    }
    catch {
      self.showPopUp(error: error)
    }
  }
  
  private func fetchData(readOptions: ReadOptions? = nil) {
    eventEmitter?.log(message: "Fetching data...")
    
    digiMe.retrieveAppleHealth(for: contract.identifier, readOptions: readOptions) { _ in
    } completion: { result in
      
      switch result {
        case .success(let healthResult):
          
#if DEBUG
          /// For debugging purpose only.
          /// Debugging account data.
          if
            let account = healthResult.account,
            let jsonData = try? account.encoded(dateEncodingStrategy: .millisecondsSince1970, keyEncodingStrategy: .convertToSnakeCase) {
            
            FilePersistentStorage(with: .documentDirectory).store(data: jsonData, fileName: "account.json")
            
            /// return Account data
            DispatchQueue.main.async { [weak self] in
              self?.eventEmitter?.result(result: account.dictionary as Any)
            }
          }
          
          /// For debugging purposes only.
          /// Group data to monthly time shard
          self.records = healthResult.data
          self.updateSections()
          
          /// Store the data content locally. Use iTunes file sharing to review JFS data saved under the Documents folder.
          self.saveToJFS()
#endif
          /// return Account data
          DispatchQueue.main.async { [weak self] in
            let steps = Int(healthResult.data.map({ $0.steps }).reduce(0, +))
            let meters = Int(healthResult.data.map({ $0.distance }).reduce(0, +))
            let result = "Total steps count: \(steps), Total distance in meters: \(meters)"
            
            self?.eventEmitter?.result(result: result as Any)
//            self?.resultCompletion?([result])
//            self?.resolverCompletion?(result)
            
            let error = SDKError.healthDataError(message: "My error message")
//            self?.rejecterCompletion?(nil, error.description, error)
            self?.errorCompletion?(error)
          }
          
        case .failure(let error):
              self.showPopUp(error: error)
      }
    }
  }
  
#if DEBUG
  private func saveToJFS() {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYYMM"
    for month in self.sections {
      
      if
        let endDate = month.records.last?.endDate,
        let jsonData = try? month.records.encoded(dateEncodingStrategy: .millisecondsSince1970, keyEncodingStrategy: .convertToSnakeCase) {
        let filename = "18_4_28_3_300_D\(formatter.string(from: endDate))_0.json"
        FilePersistentStorage(with: .documentDirectory).store(data: jsonData, fileName: filename)
      }
    }
  }

  private func updateSections() {
    sections = records
      .sorted { $0.endDate > $1.endDate }
      .groupedBy(dateComponents: [.year, .month])
      .map { ($0, $1) }
      .sorted { $0.0 > $1.0 }
  }
#endif
  
  private func showPopUp(error: Error) {
    DispatchQueue.main.async {
      self.eventEmitter?.error(error: error.localizedDescription)
      self.errorCompletion?(error)
      self.rejecterCompletion?(nil, error.localizedDescription, error)
      
      let alert = UIAlertController(title: "digi.me SDK", message: error.localizedDescription, preferredStyle: .alert)
      alert.addAction(.init(title: "OK", style: .cancel))
      UIViewController.topMost()?.present(alert, animated: true)
    }
  }
}

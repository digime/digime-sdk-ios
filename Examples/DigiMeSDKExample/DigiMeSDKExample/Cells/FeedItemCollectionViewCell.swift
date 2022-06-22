//
//  FeedItemCollectionViewCell.swift
//  DigiMeSDKExample
//
//  Created on 09/03/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import CareKitUI
import DigiMeSDK
import HealthKit
import UIKit

class DataTypeCollectionViewCell: UICollectionViewCell {
        
    var statisticalValues: [FitnessActivity] = []
    
    var chartView: OCKCartesianChartView = {
        let chartView = OCKCartesianChartView(type: .bar)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        return chartView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(chartView)
        
        setUpConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    func updateChartView(with values: [FitnessActivity]) {
        statisticalValues = values.sorted { $0.startDate < $1.startDate }
        
        // Update headerView
        chartView.headerView.titleLabel.text = "Fitness Activity"
        chartView.headerView.detailLabel.text = createChartWeeklyDateRangeLabel(total: values.count, lastDate: self.statisticalValues.last?.startDate ?? Date())
        
        // Update graphView
        chartView.applyDefaultConfiguration()
        chartView.graphView.horizontalAxisMarkers = createHorizontalAxisMarkers(total: values.count, lastDate: self.statisticalValues.last?.startDate ?? Date())
        
        let steps = statisticalValues.map { CGFloat($0.steps) }
        let distance = statisticalValues.map { CGFloat($0.distance) }
		let energy = statisticalValues.map { CGFloat($0.activeEnergyBurned) }
		
        guard
            let unitSteps = HKUnit.preferredUnit(for: "HKQuantityTypeIdentifierStepCount"),
            let unitDistance = HKUnit.preferredUnit(for: "HKQuantityTypeIdentifierDistanceWalkingRunning"),
			let unitEnergy = HKUnit.preferredUnit(for: "HKQuantityTypeIdentifierActiveEnergyBurned"),
            let unitTitleSteps = getUnitDescription(for: unitSteps),
            let unitTitleDistance = getUnitDescription(for: unitDistance),
			let unitTitleEnergy = getUnitDescription(for: unitEnergy) else {
            return
        }
        
        chartView.graphView.dataSeries = [
            OCKDataSeries(values: steps, title: unitTitleSteps, color: .systemBlue),
            OCKDataSeries(values: distance, title: unitTitleDistance, color: .systemGreen),
			OCKDataSeries(values: energy, title: unitTitleEnergy, color: .systemRed),
        ]
    }
    
    // MARK: - Private
    
    private func setUpConstraints() {
        var constraints: [NSLayoutConstraint] = []
        constraints += createChartViewConstraints()
        NSLayoutConstraint.activate(constraints)
    }
    
    private func createChartViewConstraints() -> [NSLayoutConstraint] {
        let leading = chartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        let top = chartView.topAnchor.constraint(equalTo: contentView.topAnchor)
        let trailing = chartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        let bottom = chartView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        
        trailing.priority -= 1
        bottom.priority -= 1

        return [leading, top, trailing, bottom]
    }
}

// MARK: - UI helper functions

private extension DataTypeCollectionViewCell {
    func getUnitDescription(for unit: HKUnit) -> String? {
        switch unit {
        case HKUnit.count():
            return "steps"
        case HKUnit.meter():
            return "meter"
		case HKUnit.mile():
			return "mile"
		case HKUnit.inch():
			return "inch"
		case HKUnit.kilocalorie():
			return "kcal"
        default:
            return nil
        }
    }
    
    func createChartWeeklyDateRangeLabel(total: Int, lastDate: Date = Date()) -> String {
        let calendar = Calendar.utcCalendar
        let endOfWeekDate = lastDate
        let startOfWeekDate = calendar.date(byAdding: .day, value: -(min(total, 7) - 1), to: endOfWeekDate)!
    
        let monthDayDateFormatter = DateFormatter()
        monthDayDateFormatter.dateFormat = "MMM d"
        let monthDayYearDateFormatter = DateFormatter()
        monthDayYearDateFormatter.dateFormat = "MMM d, yyyy"
    
        var startDateString = monthDayDateFormatter.string(from: startOfWeekDate)
        var endDateString = monthDayYearDateFormatter.string(from: endOfWeekDate)
    
        // If the start and end dates are in the same month.
        if calendar.isDate(startOfWeekDate, equalTo: endOfWeekDate, toGranularity: .month) {
            let dayYearDateFormatter = DateFormatter()
    
            dayYearDateFormatter.dateFormat = "d, yyyy"
            endDateString = dayYearDateFormatter.string(from: endOfWeekDate)
        }
    
        // If the start and end dates are in different years.
        if !calendar.isDate(startOfWeekDate, equalTo: endOfWeekDate, toGranularity: .year) {
            startDateString = monthDayYearDateFormatter.string(from: startOfWeekDate)
        }
    
        return String(format: "%@–%@", startDateString, endDateString)
    }
    
    func createHorizontalAxisMarkers(total: Int, lastDate: Date = Date()) -> [String] {
        let calendar = Calendar.utcCalendar
        
        var titles: [String] = []
        
        let endDate = lastDate
        let startDate = calendar.date(byAdding: DateComponents(day: -(min(total, 7) - 1)), to: endDate)!
        var date = startDate
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        
        while date <= endDate {
            titles.append(formatter.string(from: date))
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        return titles
    }
}

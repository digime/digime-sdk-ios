//
//  ResultsSummaryTableViewCell.swift
//  TFP
//
//  Created on 11/06/2019.
//  Copyright © 2019 digi.me. All rights reserved.
//

import UIKit

class ResultsSummaryTableViewCell: UITableViewCell {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    
    enum State {
        case reviewNeeded // There are words to action
        case reviewFinished // All words have been actioned
        case reviewNotNeeded // There were no words to action
    }
    
    func configure(postCount: Int, state: State, oldestPost: Date) {
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: oldestPost, to: Date())
        let timePeriod: String = {
            if let years = dateComponents.year, years > 0 {
                let period = years == 1 ? " year" : "years"
                return "going back \(years) \(period)"
            }
            else if let months = dateComponents.month, months > 0 {
                let period = months == 1 ? " month" : "months"
                return "going back \(months) \(period)"
            }
            else if let days = dateComponents.day, days > 0 {
                let period = days == 1 ? " day" : "days"
                return "going back \(days) \(period)"
            }
            
            return ""
        }()
        let posts = postCount > 1 ? "posts" : "post"
        titleLabel.text = "Analysed \(postCount) \(posts) \(timePeriod)"
        
        switch state {
        case .reviewNeeded:
            subtitleLabel.text = "Tap rows to review the offending posts"
        case .reviewFinished:
            subtitleLabel.text = "No more vulgar or offensive words found!"
        case .reviewNotNeeded:
            subtitleLabel.text = "No vulgar or offensive words found!"
        }
    }
    
}

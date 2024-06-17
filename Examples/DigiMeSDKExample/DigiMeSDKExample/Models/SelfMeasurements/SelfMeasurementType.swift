//
//  SelfMeasurementType.swift
//  DigiMeSDKExample
//
//  Created on 13/06/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import Foundation

enum SelfMeasurementType: Int, CaseIterable, Codable {
    case none = 0
    case heartRate = 1
    case weight = 2
    case height = 3
    case bloodPressure = 4
    case bloodGlucose = 5
    
    var loincCode: String {
        switch self {
        case .heartRate:
            return "8867-4"
        case .weight:
            return "29463-7"
        case .height:
            return "8302-2"
        case .bloodPressure:
            return "85354-9"
        case .bloodGlucose:
            return "14760-3"
        default:
            return ""
        }
    }
    
    var display: String {
        switch self {
        case .heartRate:
            return "Heart Rate"
        case .weight:
            return "Lichaamsgewicht [massa] in ^patiënt"
        case .height:
            return "Body Height"
        case .bloodPressure:
            return "Blood pressure panel with all children optional"
        case .bloodGlucose:
            return "Blood Glucose"
        default:
            return ""
        }
    }
}

extension SelfMeasurementType: CustomStringConvertible {
    var description: String {
        switch self {
        case .none:
            return ""
            
        case .heartRate:
            return "Heart Rate"
            
        case .weight:
            return "Weight"
            
        case .height:
            return "Height"
            
        case .bloodPressure:
            return "Blood Pressure"
            
        case .bloodGlucose:
            return "Blood Glucose"
        }
    }

    var unitDisplayValue: String {
        switch self {
        case .none:
            return ""
            
        case .heartRate:
            return "BPM"
            
        case .weight:
            return "kg"
            
        case .height:
            return "cm"
            
        case .bloodPressure:
            return "Sys (mmHG)"
            
        case .bloodGlucose:
            return "mmol/l"
        }
    }
    
    var unitDisplayValueSecondary: String {
        switch self {
        case .bloodPressure:
            return "Dia (mmHG)"
            
        default:
            return ""
        }
    }
    
    var unitValue: String {
        switch self {
        case .none:
            return ""
            
        case .heartRate:
            return "/min"
            
        case .weight:
            return "kg"
            
        case .height:
            return "cm"
            
        case .bloodPressure:
            return "mmHG"
            
        case .bloodGlucose:
            return "mmol/l"
        }
    }
    
    var unitValueSecondary: String {
        switch self {
        case .bloodPressure:
            return "mmHG"
            
        default:
            return ""
        }
    }
    
    var unitCode: String {
        switch self {
        case .heartRate:
            return "/min"
        case .weight:
            return "kg"
        case .height:
            return "cm"
        case .bloodPressure:
            return "mm[Hg]"
        case .bloodGlucose:
            return "mmol/L"
            
        default:
            return ""
        }
    }
    
    var unitCodeSecondary: String {
        switch self {
        case .bloodPressure:
            return "mm[Hg]"
            
        default:
            return ""
        }
    }
}

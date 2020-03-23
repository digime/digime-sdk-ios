//
//  CustomKolodaView.swift
//  TFP
//
//  Created on 05/09/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Koloda
import UIKit

class CustomKolodaView: KolodaView {
    
    static let xRange = 10
    static let yRange = 10
    
    var xOrigins: [CGFloat] = {
        var origins = [CGFloat]()
        
        for i in 0..<10 {
            let sign = arc4random_uniform(101) > 50 ? 1 : -1
            let xOrigin = CGFloat(Int(arc4random_uniform(UInt32(xRange + 1))) * sign)
            origins.append(xOrigin)
        }
        
        return origins
    }()
    
    var yOrigins: [CGFloat] = {
        var origins = [CGFloat]()
        
        for i in 0..<10 {
            let sign = arc4random_uniform(101) > 50 ? 1 : -1
            let yOrigin = CGFloat(Int(arc4random_uniform(UInt32(yRange + 1))) * sign)
            origins.append(yOrigin)
        }
        
        return origins
    }()

    override func frameForCard(at index: Int) -> CGRect {
        
        
        var insetFrame = CGRect(origin: .zero, size: self.frame.size).insetBy(dx: 10, dy: 10)
        
        let originIndex = index % xOrigins.count
        
        insetFrame.origin = CGPoint(x: insetFrame.origin.x - xOrigins[originIndex], y: insetFrame.origin.y - yOrigins[originIndex])
        
        return insetFrame
    }
}

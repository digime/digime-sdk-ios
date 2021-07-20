//
//  Coordinated.swift
//  Genrefy
//
//  Created on 20/07/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation

/// Interface that any coordinated view controller should implement if it needs to make
/// callbacks to it's coordinator. A protocol should be defined for this, deriving itself from
/// the `CoordinatingDelegate` protocol. This should be provided to the associated type when requested.
protocol Coordinated: AnyObject {
    associatedtype GenericCoordinatingDelegate: CoordinatingDelegate
    var coordinatingDelegate: GenericCoordinatingDelegate? { get set }
}

/// Base abstraction of `CoordinatingDelegate`.
/// To be derived from on a basis of one per coordinated view controller.
protocol CoordinatingDelegate: AnyObject { }

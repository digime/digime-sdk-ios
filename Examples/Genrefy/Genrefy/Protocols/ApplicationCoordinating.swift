//
//  ApplicationCoordinating.swift
//  Genrefy
//
//  Created on 20/07/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit

protocol ApplicationCoordinatorDelegate {
    func reset()
}

/// Interface for the app coordinator. This extends the base coordinating protocol with
/// app specific things such as a reference to the application's window.
protocol ApplicationCoordinating: Coordinating {
    
    /// The application's key window.
    var window: UIWindow? { get set }
    
    /// Designated initialiser for the app coordinator.
    ///
    /// - Parameter navigationController: The app's navigation controller.
    /// Likely the root view controller of the key window.
    init(navigationController: UINavigationController)
    
    var delegate: ApplicationCoordinatorDelegate? { get set }
}

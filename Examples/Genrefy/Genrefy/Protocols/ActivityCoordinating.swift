//
//  ActivityCoordinating.swift
//  Genrefy
//
//  Created on 20/07/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit

/// Interface for any coordinators driving activity flows. This extends the base coordinating
/// protocol with activity specific things such as a reference to the key view controller.
protocol ActivityCoordinating: Coordinating {
    
    /// The activity coordinator's parent coordinator; be it another activity coordinator
    /// or the app coordinator.
    var parentCoordinator: Coordinating { get set }
    
    /// The key view controller for the activity. This is usually the view controller that
    /// is currently visible and can change as the user moves through the flow.
    var keyViewController: UIViewController? { get set }
    
    /// Designated initialiser for activity coordinators.
    ///
    /// - Parameters:
    ///   - navigationController: The coordinator's navigation controller. This is usually
    ///   that of the parent coordinator but can sometimes be a new one, if the flow is
    ///   to be presented modally.
    ///   - parentCoordinator: The coordinator's parent; be it another activity coordinator
    ///   or the app coordinator.
    init(navigationController: UINavigationController, parentCoordinator: Coordinating)
}

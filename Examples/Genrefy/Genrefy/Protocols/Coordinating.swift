//
//  Coordinating.swift
//  DigiMe
//
//  Created on 06/04/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

import Foundation
import UIKit

/// Root coordinator protocol. All coordinators must conform to this as a bare minimum.
protocol Coordinating: NSObjectProtocol {
    
    /// An arbitrary string that is used to compare coordinator objects.
    ///
    /// - Note: This should be generated on initialisation with `UUID().uuidString`.
    var identifier: String { get }
    
    /// The navigation controller which the coordinator uses to control flow.
    /// This is usually inheirited from it's parent but in some cases where
    /// the coordinator's flow is presented as a modal, a new one may be used.
    ///
    /// - Note: The app coordinator will always create a new instance.
    var navigationController: UINavigationController { get }
    
    /// The coordinator's child coordninators. Objects are added to this array when
    /// the coordinator delegates control to them and removed when the child informs
    /// it's parent that it is complete and ready to be destroyed.
    ///
    /// - Important: This must contain the only reference to each coordinator.
    /// Any delegate properties or other references must be `weak` in order for
    /// ARC to run the garbage collector properly.
    var childCoordinators: [ActivityCoordinating] { get set }
    
    /// Invoked by the child on it's parent to inform it that it has completed it's
    /// activity and that it's ready to be destroyed, or, in some cases, inform it to
    /// delegate to another coordinator whilst retaining the instance of this one as a child.
    ///
    /// - Parameter child: Effectively `self` when `self`'s parent is the receiver.
    /// - Parameter result: Optional result to be passed to parent.
    func childDidFinish(child: ActivityCoordinating, result: Any?)
    
    /// This method start's the coordinator's flow. It is generally invoked by the parent
    /// after the coordinator is created. The coordinator is effectively
    /// the 'active coordinator' after this method is called.
    ///
    /// - Note: This should be used to determine the first view controller in the flow
    /// and push it onto the navigation stack.
    func begin()
}

extension Coordinating {
    
    /// Call to remove a child if it exists.
    ///
    /// - Parameter child: The child to remove.
    func removeChild(_ child: ActivityCoordinating) {
        for (index, element) in childCoordinators.enumerated() where element.identifier == child.identifier {
            childCoordinators.remove(at: index)
            return
        }
    }
}

//
//  IntroPageViewController.swift
//  TFP
//
//  Created on 12/11/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation
import UIKit

class IntroPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, Coordinated {
    
    typealias GenericCoordinatingDelegate = CoordinatingDelegate
    weak var coordinatingDelegate: GenericCoordinatingDelegate?
        
    var shouldNotify = false

    private var userDefaults = UserDefaults.standard
    private let cache = TFPCache()

    var pageControl: UIPageControl = {
        let control = UIPageControl(frame: .zero)
        control.currentPage = 0
        control.isUserInteractionEnabled = false
        control.pageIndicatorTintColor = #colorLiteral(red: 0.3607843137, green: 0.3607843137, blue: 0.3607843137, alpha: 0.5)
        control.currentPageIndicatorTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.7)
        return control
    }()
    
    @objc init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        dataSource = self
        delegate = self
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        guard let onboardingViewControllers = (coordinatingDelegate as? IntroFlowDelegate)?.onboardingViewControllers else {
            return
        }
        
        if cache.didShowOnboarding() {
            setViewControllers([onboardingViewControllers.last!], direction: .forward, animated: false, completion: nil)
        } else {
            setViewControllers([onboardingViewControllers.first!], direction: .forward, animated: false, completion: nil)
        }

        pageControl.numberOfPages = onboardingViewControllers.count
        view.addSubview(pageControl)
        setupConstraints()
        
        (coordinatingDelegate as? IntroFlowDelegate)?.updatePageControl(for: self)
    }
    
    func skipOnboarding() {
        guard let onboardingViewControllers = (coordinatingDelegate as? IntroFlowDelegate)?.onboardingViewControllers else {
            return
        }
        setViewControllers([onboardingViewControllers.last!], direction: .forward, animated: false, completion: nil)
        (coordinatingDelegate as? IntroFlowDelegate)?.updatePageControl(for: self)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let introVC = viewController as? IntroViewController {
            return (coordinatingDelegate as? IntroFlowDelegate)?.viewController(before: introVC)
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let introVC = viewController as? IntroViewController {
            return (coordinatingDelegate as? IntroFlowDelegate)?.viewController(after: introVC)
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        (coordinatingDelegate as? IntroFlowDelegate)?.updatePageControl(for: self)
    }
}

// MARK :- Constraints
extension IntroPageViewController {
    private func setupConstraints() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
}

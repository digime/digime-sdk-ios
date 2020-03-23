//
//  SwearDetailsViewController.swift
//  TFP
//
//  Created on 24/08/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation
import Koloda
import UIKit

class SwearDetailsViewController: UIViewController, Storyboarded, Coordinated {
    
    static var storyboardName = "Analysis"
    
    typealias GenericCoordinatingDelegate = DetailCoordinatingDelegate
    weak var coordinatingDelegate: GenericCoordinatingDelegate?
    
    @IBOutlet var kolodaView: CustomKolodaView!
    @IBOutlet var titleLabel: UILabel!
    
    var posts = [TFPost]()
    
    private let cache = TFPCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kolodaView.delegate = self
        kolodaView.dataSource = self
        self.titleLabel.text = posts.first?.matchedWord.capitalized
    }
    
    @IBAction func goBackToResults(_ sender: UIButton) {
        coordinatingDelegate?.goBack()
    }
}

extension SwearDetailsViewController: KolodaViewDelegate {
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        let post = posts[index]
        
        if direction == .left {
            post.action = .ignore
        }
        else if direction == .right {
            post.action = .delete
            coordinatingDelegate?.didUpdateFlagged()
        }
        
        cache.addItem(identifier: post.postObject.identifier, action: post.action)
    }
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        coordinatingDelegate?.goBack()
    }
}

extension SwearDetailsViewController: KolodaViewDataSource {
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        
        let post = posts[index]
        let view = PostView(withPost: post)
        return view
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return posts.count
    }
}

//
//  FlaggedViewController.swift
//  TFP
//
//  Created on 06/09/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit
import PopItUp

class FlaggedViewController: UIViewController, Storyboarded, Coordinated {
    
    static var storyboardName = "Analysis"
    private let cellIdentifier = "PostCellIdentifier"
    
    typealias GenericCoordinatingDelegate = DetailCoordinatingDelegate
    weak var coordinatingDelegate: GenericCoordinatingDelegate?

    @IBOutlet var tableView: UITableView!
    
    var postsToDelete = [TFPost]() {
        didSet {
            tableView.reloadData()
            coordinatingDelegate?.didUpdateFlagged()
        }
    }
    
    var texts = [
        "Lorem dorem maca lorem sit amet, consectetur adipiscing elit. Etiam risus lorem, suscipit sit amet urna in, lacinia egestas sem. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.",
        "ed a faucibus tortor, nec tincidunt dolor. Cras vitae justo ligula. Aliquam sagittis neque elit, mattis egestas tortor sollicitudin vel.",
        "Aliquam condimentum et diam vel pulvinar. Phasellus massa neque",
        "Aenean ante mi, bibendum at sapien nec, eleifend ullamcorper quam. Nunc non libero tortor. Phasellus commodo sollicitudin elit, at elementum tortor tempus vitae. Integer vitae arcu sit amet ligula efficitur condimentum. Vivamus vitae mauris nisi. Nulla venenatis, tellus vitae tempor tincidunt, urna tellus lacinia enim, a feugiat dui enim eget enim. Fusce sit amet nulla odio.",
        "Sed lorem ligula, suscipit quis dui eget",
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam risus orci, suscipit sit amet urna in, lacinia egestas sem. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.",
        "ed a faucibus tortor, nec tincidunt dolor. Cras vitae justo ligula. Aliquam sagittis neque elit, mattis egestas tortor sollicitudin vel.",
        "Aliquam condimentum et diam vel pulvinar. Phasellus massa neque",
        "Aenean ante mi, bibendum at sapien nec, eleifend ullamcorper quam. Nunc non libero tortor. Phasellus commodo sollicitudin elit, at elementum tortor tempus vitae. Integer vitae arcu sit amet ligula efficitur condimentum. Vivamus vitae mauris nisi. Nulla venenatis, tellus vitae tempor tincidunt, urna tellus lacinia enim, a feugiat dui enim eget enim. Fusce sit amet nulla odio.",
        "Sed lorem ligula, suscipit quis dui eget",
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam risus orci, suscipit sit amet urna in, lacinia egestas sem. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.",
        "ed a faucibus tortor, nec tincidunt dolor. Cras vitae justo ligula. Aliquam sagittis neque elit, mattis egestas tortor sollicitudin vel.",
        "Aliquam condimentum et diam vel pulvinar. Phasellus massa neque",
        "Aenean ante mi, bibendum at sapien nec, eleifend ullamcorper quam. Nunc non libero tortor. Phasellus commodo sollicitudin elit, at elementum tortor tempus vitae. Integer vitae arcu sit amet ligula efficitur condimentum. Vivamus vitae mauris nisi. Nulla venenatis, tellus vitae tempor tincidunt, urna tellus lacinia enim, a feugiat dui enim eget enim. Fusce sit amet nulla odio.",
        "Sed lorem ligula, suscipit quis dui eget",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension FlaggedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let post = postsToDelete[indexPath.row]
        
        coordinatingDelegate?.didSelectPost(post: post)
        
        self.postsToDelete.remove(at: indexPath.row)
    }
}

extension FlaggedViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsToDelete.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? PostCell else {
            return UITableViewCell()
        }
        
        let post = postsToDelete[indexPath.row].postObject
        let matchedWord = postsToDelete[indexPath.row].matchedWord
        
        cell.setDate(post.createdDate)
        
        if let service = post.serviceType {
            cell.setService(service)
        }
        
        cell.setText(post.text, highlightWord: matchedWord)
        
        return cell
    }
}

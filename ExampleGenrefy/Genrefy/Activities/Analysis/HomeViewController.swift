//
//  HomeViewController.swift
//  Genrefy
//
//  Created on 18/07/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit

@objc protocol HomeViewCoordinatingDelegate: CoordinatingDelegate {
    func didSelect(word: String)
}

class HomeViewController: UIViewController, Storyboarded, Coordinated {
    
    static var storyboardName = "Analysis"
    
    private enum CellIdentifiers {
        static let swearCell = "SwearCellIdentifier"
        static let summaryCell = "ResultsSummaryCell"
    }
    
    typealias GenericCoordinatingDelegate = HomeViewCoordinatingDelegate
    weak var coordinatingDelegate: GenericCoordinatingDelegate?
    
    var allPosts: [CAResponseObject]?
    var swearPosts: [TFPost]?
    private var swearWords = [String]()
    private var counts = [String: Int]()
    private let swearRanker = ProfanityRanker()
    private var topSwearCount = 0
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private lazy var warningView: WarningView = {
        let view = WarningView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var didLoad = false
    private let cache = TFPCache()
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        reload()
        
        didLoad = true
        
        cache.setExistingUser(value: true)

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 600
    }
    
    func reload() {
        let prevSwearWordsCount = swearWords.count
        let prevCountsDict = counts
        
        process(posts: swearPosts)
        
        if !didLoad {
            showSwearWarning()
        }
        
        if prevSwearWordsCount != swearWords.count || prevCountsDict != counts {
            tableView.reloadData()
        }
    }
    
    func hideActivityIndicator() {

        DispatchQueue.main.async {
            
            self.activityIndicator.hidesWhenStopped = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - Private
    
    private func process(posts: [TFPost]?) {
        
        guard let posts = posts else {
            counts = [:]
            swearWords = [String]()
            return
        }
        
        var swearsCount = [String: Int]()
        
        for i in 0..<posts.count {
            guard
                posts[i].action == .undecided,
                swearRanker.rankOf(posts[i].matchedWord) > 0 //ignore rank 0 (harmless words)
            else {
                continue
            }
            
            let word = posts[i].matchedWord
            swearsCount[word] = (swearsCount[word] ?? 0) + 1
            
            if swearsCount[word]! > topSwearCount {
                topSwearCount = swearsCount[word]!
            }
        }
        
        counts = swearsCount
        
        let keys = Array(swearsCount.keys)
        
        // sorted by rank (descending) then count (descending) then alphabetically (ascending)
        swearWords = keys.sorted(by: { (swear1, swear2) -> Bool in
            
            let rank1 = self.swearRanker.rankOf(swear1)
            let rank2 = self.swearRanker.rankOf(swear2)
            
            if rank1 == rank2 {
                let count1 = swearsCount[swear1]!
                let count2 = swearsCount[swear2]!
                if count1 == count2 {
                    return swear1.compare(swear2) == .orderedAscending
                }
                
                return count1 > count2
            }
            
            return rank1 > rank2
        })
    }
    
    private func showNoMessagesWarning() {
        view.addSubview(warningView)
        addWarningViewConstraints()
        
        warningView.textLabel.text = "Congratulations! Your profile looks clean!\rTap to continue"
        warningView.warningImageView.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handle(tap:)))
        view.addGestureRecognizer(tap)
    }
    
    private func showLetsCleanWarning() {
        view.addSubview(warningView)
        addWarningViewConstraints()
        
        warningView.textLabel.text = "Awesome, time to go and clean up those posts!\rTap to continue"
        warningView.warningImageView.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handle(tap:)))
        view.addGestureRecognizer(tap)
    }
    
    private func showSwearWarning() {
        view.addSubview(warningView)
        addWarningViewConstraints()
        
        let headerText = "Warning!"
        let bodyText = "You might not like what you’re about to see."
        let footerText = "Tap here to reveal"
        let attributedString = NSMutableAttributedString(string: String(format:"%@\n\n%@\n\n%@", headerText, bodyText, footerText))
        let headerRange = (attributedString.string as NSString).range(of: headerText)
        let bodyRange = (attributedString.string as NSString).range(of: bodyText)
        let footerRange = (attributedString.string as NSString).range(of: footerText)
        attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 40.0, weight: .heavy), range: headerRange)
        attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 24.0, weight: .medium), range: bodyRange)
        attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 20.0, weight: .heavy), range: footerRange)
        warningView.textLabel.attributedText = attributedString

        let tap = UITapGestureRecognizer(target: self, action: #selector(handle(tap:)))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func handle(tap: UIGestureRecognizer) {
        view.removeGestureRecognizer(tap)
        UIView.animate(withDuration: 0.75, delay: 0, options: .curveEaseInOut, animations: {
            self.warningView.alpha = 0
        }, completion: { _ in
            self.warningView.removeFromSuperview()
            self.warningView.alpha = 1
        })
    }
    
    private func addWarningViewConstraints() {
        warningView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        warningView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        warningView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        warningView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else {
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let swearWord = swearWords[indexPath.row]
        coordinatingDelegate?.didSelect(word: swearWord)
    }
}

extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 2:
            return 1
        case 1:
            return swearWords.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.summaryCell) as? ResultsSummaryTableViewCell else {
                return UITableViewCell()
            }
            
            let oldestPost = allPosts?.map { $0.createdDate }.min { $0.timeIntervalSinceReferenceDate < $1.timeIntervalSinceReferenceDate }
            let state: ResultsSummaryTableViewCell.State = {
                if !swearWords.isEmpty {
                    return .reviewNeeded
                }
                
                let decidedPostsCount = swearPosts?.filter { $0.action == .delete  || $0.action == .ignore || $0.action == .confirmed}.count ?? 0
                if decidedPostsCount > 0 {
                    return .reviewFinished
                }
                
                return .reviewNotNeeded
            }()
            cell.configure(postCount: allPosts?.count ?? 0, state: state, oldestPost: oldestPost ?? Date())
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.swearCell) as? SwearCell else {
                return UITableViewCell()
            }
            
            let swear = swearWords[indexPath.row]
            let swearCount = counts[swear] ?? 0
            cell.swearLabel.text = swear.uppercased()
            cell.countLabel.text = "\(counts[swear] ?? 0)"
            cell.amount = CGFloat(swearCount) / CGFloat(topSwearCount)
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0, 2:
            return UITableViewAutomaticDimension
        default:
            return 60
        }
    }
}

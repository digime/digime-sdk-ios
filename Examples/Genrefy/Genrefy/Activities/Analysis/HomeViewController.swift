//
//  HomeViewController.swift
//  Genrefy
//
//  Created on 18/07/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit

protocol HomeViewControllerDelegate: CoordinatingDelegate {
    func refreshData()
}

class HomeViewController: UIViewController, Storyboarded {
    
    var coordinatingDelegate: HomeViewControllerDelegate?
    
    static var storyboardName = "Analysis"
    
    private enum CellIdentifiers {
        static let genreCell = "GenreCellIdentifier"
    }
    
    var genreSummaries = [GenreSummary]() {
        didSet {
            totalGenreCount = self.genreSummaries.reduce(0) { $0 + $1.count }
            if let tableView = tableView {
                tableView.reloadData()
            }
        }
    }
    private var totalGenreCount: Int = 0
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var refreshButton: UIButton!
    
    private let barColors = [
        #colorLiteral(red: 0.8431372549, green: 0.1176470588, blue: 0.7254901961, alpha: 1), // #D71EB9
        #colorLiteral(red: 0.1254901961, green: 0.8705882353, blue: 0.8705882353, alpha: 1), // #20DEDE
        #colorLiteral(red: 0.8274509804, green: 0.8431372549, blue: 0.1176470588, alpha: 1), // #D3D71E
        #colorLiteral(red: 0.05882352941, green: 0.8549019608, blue: 0.2823529412, alpha: 1), // #0FDA48
        #colorLiteral(red: 0.1176470588, green: 0.4941176471, blue: 0.8431372549, alpha: 1), // #1E7ED7
        #colorLiteral(red: 0.8705882353, green: 0.3058823529, blue: 0.1254901961, alpha: 1), // #DE4E20
        #colorLiteral(red: 0.5254901961, green: 0.1176470588, blue: 0.8431372549, alpha: 1), // #861ED7
        #colorLiteral(red: 0.8549019608, green: 0.2039215686, blue: 0.05882352941, alpha: 1), // #DA340F
        #colorLiteral(red: 0.7490196078, green: 0.9490196078, blue: 0.168627451, alpha: 1), // #BFF22B
        #colorLiteral(red: 1, green: 0.9176470588, blue: 0.6274509804, alpha: 1), // #FFEAA0
        #colorLiteral(red: 1, green: 0.5019607843, blue: 0.8, alpha: 1), // #FF80CC
        #colorLiteral(red: 0.1764705882, green: 0.9294117647, blue: 0.7019607843, alpha: 1), // #2DEDB3
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        imageView.image = #imageLiteral(resourceName: "service_19").withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .white
        activityIndicator.hidesWhenStopped = true
        
        if activityIndicator.isAnimating {
            imageView.isHidden = true
            refreshButton.isHidden = true
        }
    }
    
    func hideActivityIndicator() {
        self.imageView.isHidden = false
        self.refreshButton.isHidden = false
        self.activityIndicator.stopAnimating()
    }
    
    func showNoResults() {
        let alert = UIAlertController(title: "No data", message: "Looks like you have not listened to any songs in last 24 hours.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func refresh() {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        imageView.isHidden = true
        refreshButton.isHidden = true
        coordinatingDelegate?.refreshData()
    }
}

extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return genreSummaries.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.genreCell) as? GenreCell else {
                return UITableViewCell()
            }
            
            let genreSummary = genreSummaries[indexPath.row]
            cell.swearLabel.text = genreSummary.title
            cell.countLabel.text = "\(genreSummary.count) songs"
            cell.amount = CGFloat(genreSummary.count) / CGFloat(totalGenreCount)
            cell.barColor = barColors[indexPath.row % barColors.count]
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return UITableView.automaticDimension
        default:
            return 60
        }
    }
}

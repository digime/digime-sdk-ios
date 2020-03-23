//
//  ManualSearchViewController.swift
//  TFP
//
//  Created on 10/12/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit
import WebKit

@objc protocol ManualSearchCoordinatingDelegate: CoordinatingDelegate {
    func goBack()
    func didEnterUsername(_ username: String)
    func didTapInstall()
}

class ManualSearchViewController: UIViewController, Storyboarded, Coordinated {

    static var storyboardName = "Onboarding"
    
    typealias GenericCoordinatingDelegate = ManualSearchCoordinatingDelegate
    weak var coordinatingDelegate: GenericCoordinatingDelegate?
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var webView: WKWebView!
    @IBOutlet var bottomWebViewConstraint: NSLayoutConstraint!
    @IBOutlet var heightWebViewConstraints: NSLayoutConstraint!
    @IBOutlet var bottomInstallButtonConstraint: NSLayoutConstraint!
    @IBOutlet var topInstallLabelConstraint: NSLayoutConstraint!
    @IBOutlet var installLabel: UILabel!
    
    
    private let swearWords = ["ass", "shit", "dick", "piss", "fuck", "bitch", "whore", "pussy"]
    private let twitterBase = "https://twitter.com/search?l=&q="
    
    private let highlightWord = "ALL"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUsernameTextField()
        
        let text = installLabel.text
        let boldFont = UIFont.systemFont(ofSize: installLabel.font.pointSize, weight: .bold)
        installLabel.attributedText = text?.makeBold(words: [highlightWord], font: boldFont)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !usernameTextField.isFirstResponder {
            usernameTextField.becomeFirstResponder()
        }
    }
    
    private func setupUsernameTextField() {
        
        let fontSize = usernameTextField.font!.pointSize
        
        let atLabel = UILabel(frame: .zero)
        atLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        atLabel.textColor = UIColor.white
        atLabel.textAlignment = .center
        atLabel.text = "@"
        atLabel.frame = CGRect(x: 0, y: 0, width: 30, height: usernameTextField.frame.height)
        
        usernameTextField.leftView = atLabel
        usernameTextField.leftViewMode = .always
        usernameTextField.borderStyle = .none
        usernameTextField.layer.masksToBounds = true
        usernameTextField.layer.cornerRadius = 23.0
        usernameTextField.layer.borderColor = UIColor.white.cgColor
        usernameTextField.layer.borderWidth = 1
        usernameTextField.textColor = UIColor.white
        usernameTextField.tintColor = UIColor.white
        usernameTextField.textContentType = UITextContentType("") //disable keychain
        usernameTextField.returnKeyType = .done
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        coordinatingDelegate?.goBack()
    }
    
    @IBAction func installDigiMe(_ sender: UIButton) {
        coordinatingDelegate?.didTapInstall()
    }
}

extension ManualSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        if let text = textField.text {
            
            //max username length is 15 on Twitter
            if
                text.count > 0 && text.count < 15  && !text.contains("@") {
                coordinatingDelegate?.didEnterUsername(text)
            }
        }
        
        return true
    }
}

extension ManualSearchViewController {
    func performSearchForUsername(_ username: String) {
        
        let urlString = twitterBase + swearWords.joined(separator: " OR ") + " from:" + username
        
        guard
            let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: encodedUrl) else {
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        webView.isHidden = false

        heightWebViewConstraints.isActive = false
        topInstallLabelConstraint.isActive = false
        bottomWebViewConstraint.isActive = true
        bottomInstallButtonConstraint.isActive = true
        
        
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

//
//  LogViewController.swift
//  DigiMeSDKExample
//
//  Created on 21/07/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import UIKit

class Logger {
    
    weak var textView: UITextView?
    
    enum Defaults {
        static let font = UIFont(name: "Courier-Bold", size: 12)
    }
    
    init(textView: UITextView) {
        self.textView = textView
        textView.backgroundColor = .black
        textView.textColor = .white
        textView.isEditable = false
        textView.font = Defaults.font
        textView.text = ""
    }
    
    func log(message: String) {
        DispatchQueue.main.async {
            guard !message.isEmpty, let textView = self.textView else {
                return
            }
            
            let now = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            let dateString = formatter.string(from: now)
            textView.text += "\n" + dateString + " " + message + "\n"
            self.scrollToBottom()
        }
    }
    
    func reset() {
        DispatchQueue.main.async {
            self.textView?.text = ""
        }
    }
    
    private func scrollToBottom() {
        guard let textLength = textView?.text.count, textLength > 0 else {
            return
        }

        textView?.scrollRangeToVisible(NSRange(location: textLength - 1, length: 1))
    }
}

class LogViewController: UIView {
  
  var textView: UITextView!
  var currentFontSize: CGFloat = 10
  
  fileprivate let loggingViewMaxFontSize: CGFloat = 28
  fileprivate let loggingViewMinFontSize: CGFloat = 2
  fileprivate let loggingViewDefaultFont: String = "Courier-Bold"
  
  override init(frame: CGRect) {
    
    super.init(frame: frame)
    generateTextView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func increaseFontSize() {
    guard currentFontSize < loggingViewMaxFontSize else {
        return
    }
    
    currentFontSize = currentFontSize + 1
    textView.font = UIFont (name: loggingViewDefaultFont, size: currentFontSize)
  }
  
  func decreaseFontSize() {
    guard currentFontSize > loggingViewMinFontSize else {
        return
    }
    
    currentFontSize = currentFontSize - 1
    textView.font = UIFont (name: loggingViewDefaultFont, size: currentFontSize)
  }
  
  func reset() {
    
    if let textView = textView {
      textView.removeFromSuperview()
    }
    generateTextView()
  }
  
  func generateTextView() {
    
    textView = UITextView(frame: frame)
    textView.backgroundColor = .black
    textView.isEditable = false
    textView.font = UIFont (name: loggingViewDefaultFont, size: currentFontSize)
    textView.textColor = .white
    textView.text = ""
    textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    addSubview(textView)
    bringSubviewToFront(textView)
  }
  
  func scrollToBottom() {
    
    let stringLength:Int = textView.text.count
    textView.scrollRangeToVisible(NSMakeRange(stringLength-1, 1))
  }
  
    func log(message: String) {
        DispatchQueue.main.async {
            guard !message.isEmpty else {
                return
            }
            
            let now = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            let dateString = formatter.string(from: now)
            self.textView.text = self.textView.text + "\n" + dateString + " " + message
            self.scrollToBottom()
        }
    }
}

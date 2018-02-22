//
//  LogViewController.swift
//  DigiMeSDKExampleSwift
//
//  Created on 22/02/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import UIKit

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
    
    if (self.currentFontSize >= loggingViewMaxFontSize) {
      return
    }
    self.currentFontSize = self.currentFontSize + 1
    self.textView.font = UIFont (name: loggingViewDefaultFont, size: self.currentFontSize)
  }
  
  func decreaseFontSize() {
    
    if (self.currentFontSize <= loggingViewMinFontSize) {
      return
    }
    self.currentFontSize = self.currentFontSize - 1
    self.textView.font = UIFont (name: loggingViewDefaultFont, size: self.currentFontSize)
  }
  
  func reset() {
    
    if let textView = self.textView {
      textView.removeFromSuperview()
    }
    self.generateTextView()
  }
  
  func generateTextView() {
    
    self.textView = UITextView(frame: frame)
    self.textView.backgroundColor = .black
    self.textView.isEditable = false
    self.textView.font = UIFont (name: loggingViewDefaultFont, size: self.currentFontSize)
    self.textView.textColor = .white
    self.textView.text = ""
    self.textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.addSubview(textView)
    self.bringSubview(toFront: textView)
  }
  
  func scrollToBottom() {
    
    let stringLength:Int = self.textView.text.count
    self.textView.scrollRangeToVisible(NSMakeRange(stringLength-1, 1))
  }
  
  func log(message: String) {
    
    if message.isEmpty {
      return
    }
    let now = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    let dateString = formatter.string(from: now)
    self.textView.text = self.textView.text + "\n" + dateString + " " + message
//    scrollToBottom()
  }
}

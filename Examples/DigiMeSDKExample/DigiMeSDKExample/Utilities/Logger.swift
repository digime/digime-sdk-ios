//
//  Logger.swift
//  DigiMeSDKExample
//
//  Created on 21/07/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import Foundation
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
		guard Thread.isMainThread else {
			DispatchQueue.main.async {
				self.log(message: message)
			}
			
			return
		}
		
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

//
//  String+Helper.swift
//  DigiMeSDKExample
//
//  Created on 13/12/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import Foundation

extension String {
   static func random(length: Int) -> String {
		let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		var randomString = String()

		while randomString.utf8.count < length {
			let randomLetter = letters.randomElement()
			randomString += randomLetter?.description ?? String()
		}
	   
		return randomString
	}
}

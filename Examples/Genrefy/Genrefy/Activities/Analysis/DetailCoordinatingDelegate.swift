//
//  DetailCoordinatingDelegate.swift
//  TFP
//
//  Created by Alex Robinson  on 06/09/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation

@objc protocol DetailCoordinatingDelegate: CoordinatingDelegate {
    func goBack()
    func didUpdateFlagged()
    func didSelectPost(post: TFPost)
}

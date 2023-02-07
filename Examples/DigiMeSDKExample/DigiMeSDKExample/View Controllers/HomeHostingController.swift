//
//  HomeHostingController.swift
//  DigiMeSDKExample
//
//  Created on 30/01/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI
import UIKit

class HomeHostingController: UIHostingController<HomeView> {
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder, rootView: HomeView())
	}
}

struct ServiceDataViewControllerWrapper: UIViewControllerRepresentable {
	func makeUIViewController(context: Context) -> UIViewController {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let controller = storyboard.instantiateViewController(identifier: "ServiceDataViewController")
		return controller
	}
	
	func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
	}
}

struct WriteDataViewControllerWrapper: UIViewControllerRepresentable {
	func makeUIViewController(context: Context) -> UIViewController {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let controller = storyboard.instantiateViewController(identifier: "WriteDataViewController")
		return controller
	}
	
	func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
	}
}

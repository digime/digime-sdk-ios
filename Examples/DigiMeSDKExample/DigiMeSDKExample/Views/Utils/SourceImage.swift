//
//  SourceImage.swift
//  DigiMeSDKExample
//
//  Created on 24/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct SourceImage: View {
	let url: URL
	
	var body: some View {
		AsyncImage(
			url: url,
			transaction: Transaction(animation: .easeInOut)
		) { phase in
			switch phase {
			case .empty:
				ProgressView()
					.frame(width: 10, height: 10)
			case .success(let image):
				image
					.resizable()
					.transition(.scale(scale: 0.1, anchor: .center))
			case .failure:
				Image(systemName: "wifi.slash")
			@unknown default:
				EmptyView()
			}
		}
		.frame(width: 20, height: 20)
		.clipShape(Circle())
	}
}

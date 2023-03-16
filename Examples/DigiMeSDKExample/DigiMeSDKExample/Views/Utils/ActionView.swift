//
//  ActionView.swift
//  DigiMeSDKExample
//
//  Created on 13/03/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct ActionView: View {
	@State var title: String
	@State var actionTitle: String
	@State var dialogDetent = PresentationDetent.height(200)
	@State var actionHandler: (() -> Void)?
	
    var body: some View {
		VStack(alignment: .center) {
			Text(title)
				.padding(.top, 20)
			Spacer()
			if dialogDetent == .height(200) {
				BallScaleRippleMultiple()
					.frame(width: 75, height: 75)
					.foregroundColor(.blue)
					.padding(.trailing, 10)
				Spacer()
			}
			Button {
				self.actionHandler?()
			} label: {
				Text(actionTitle)
					.frame(minWidth: 0, maxWidth: .infinity)
					.foregroundColor(.primary)
					.padding(10)
					.background(
						RoundedRectangle(cornerRadius: 10, style: .continuous)
							.fill(Color(UIColor.systemGray4))
							.padding([.leading, .trailing], 20)
					)
			}
		}
		.presentationDetents( [.height(100), .height(200)], selection: $dialogDetent)
    }
}

struct ActionView_Previews: PreviewProvider {
    static var previews: some View {
		ActionView(title: "Waiting callback from your browser...", actionTitle: "Cancel Request")
    }
}

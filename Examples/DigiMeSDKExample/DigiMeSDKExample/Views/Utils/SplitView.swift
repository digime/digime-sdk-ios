//
//  SplitView.swift
//  DigiMeSDKExample
//
//  Created on 17/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct SplitView<PrimaryView: View, SecondaryView: View>: View {
	@GestureState private var offset: CGFloat = 0
	@State private var storedOffset: CGFloat = 0
	
	let primaryView: PrimaryView
	let secondaryView: SecondaryView

	init(@ViewBuilder top: @escaping () -> PrimaryView, @ViewBuilder bottom: @escaping () -> SecondaryView) {
		self.primaryView = top()
		self.secondaryView = bottom()
	}

	var body: some View {
		GeometryReader { proxy in
			VStack(spacing: 0) {
				self.primaryView
					.frame(height: max((proxy.size.height / 2) + self.totalOffset, 0))
					.zIndex(1)
				
				self.handle
					.gesture(
						DragGesture(coordinateSpace: .global)
							.updating(self.$offset) { value, state, _ in
								state = value.translation.height
							}
							.onEnded { value in
								self.storedOffset += value.translation.height
							}
					)
					.padding(5)
					.zIndex(0)
				
				self.secondaryView.zIndex(1)
			}
		}
	}
	
	var handle: some View {
		ZStack {
			Color.accentColor
				.frame(maxWidth: .infinity, maxHeight: 0.5)
			RoundedRectangle(cornerRadius: 5)
				.frame(width: 40, height: 8)
				.foregroundColor(Color.accentColor)
				.padding(2)
		}
	}
	
	var totalOffset: CGFloat {
		storedOffset + offset
	}
}

struct SplitView_Previews: PreviewProvider {
	static var previews: some View {
		SplitView(top: {
			Rectangle().foregroundColor(.red)
		}, bottom: {
			Rectangle().foregroundColor(.green)
		})
	}
}

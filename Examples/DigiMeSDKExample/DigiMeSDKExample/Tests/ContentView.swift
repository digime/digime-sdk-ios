//
//  ContentView.swift
//  DigiMeSDKExample
//
//  Created on 25/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct ContentView: View {
	@State private var isExpanded = false
	@AppStorage("timesClicked") private var timesClicked = 0

	var body: some View {
		ScrollView {
			CustomDisclosureGroup(animation: .easeInOut(duration: 0.2), isExpanded: $isExpanded) {
				isExpanded.toggle()
				timesClicked += 1
			} prompt: {
				HStack(spacing: 0) {
					Text("How to open an account in your application?")
					Spacer()
					Text("?")
						.fontWeight(.bold)
						.rotationEffect(isExpanded ? Angle(degrees: 180) : .zero)
				}
				.padding(.horizontal, 20)
			} expandedView: {
				Text("you can open an account by choosing between gmail or ICloud when opening the application")
					.font(.system(size: 16, weight: .semibold, design: .monospaced))
			}
		}
	}
}

struct CustomDisclosureGroup<Prompt: View, ExpandedView: View>: View {
	
	@Binding var isExpanded: Bool

	var actionOnClick: () -> Void
	var animation: Animation?
	
	let prompt: Prompt
	let expandedView: ExpandedView
	
	init(animation: Animation?, isExpanded: Binding<Bool>, actionOnClick: @escaping () -> Void, prompt: () -> Prompt, expandedView: () -> ExpandedView) {
		self.actionOnClick = actionOnClick
		self._isExpanded = isExpanded
		self.animation = animation
		self.prompt = prompt()
		self.expandedView = expandedView()
	}
	
	var body: some View {
		VStack(spacing: 0) {
			prompt
			
			if isExpanded {
				expandedView
			}
		}
		.clipped()
		.contentShape(Rectangle())
		.onTapGesture {
			withAnimation(animation) {
				actionOnClick()
			}
		}
	}
}

struct MyDisclosureStyle: DisclosureGroupStyle {
	func makeBody(configuration: Configuration) -> some View {
		VStack {
			Button {
				withAnimation {
					configuration.isExpanded.toggle()
				}
			} label: {
				HStack(alignment: .firstTextBaseline) {
					configuration.label
					Spacer()
					Text(configuration.isExpanded ? "hide" : "show")
						.foregroundColor(.accentColor)
						.font(.caption.lowercaseSmallCaps())
						.animation(nil, value: configuration.isExpanded)
				}
				.contentShape(Rectangle())
			}
			.buttonStyle(.plain)
			if configuration.isExpanded {
				configuration.content
			}
		}
	}
}

struct CustomDisclosureGroupStyle2: DisclosureGroupStyle {
  func makeBody(configuration: Configuration) -> some View {
	VStack(alignment: .leading) {
	  configuration.label
		.font(.headline)
		.padding()
	  if configuration.isExpanded {
		configuration.content
		  .padding()
		  .background(Color.gray.opacity(0.1))
	  }
	}
  }
}

struct MyDisclosureGroupStyle2: DisclosureGroupStyle {
	func makeBody(configuration: Configuration) -> some View {
		Group {
			if configuration.isExpanded {
				Image(systemName: "chevron.down")
					.rotationEffect(Angle(degrees: 90))
			}
			else {
				Image(systemName: "chevron.right")
			}
			
			configuration.label
				.font(.headline)
		}
		.onTapGesture {
			withAnimation {
				configuration.isExpanded.toggle()
			}
		}
	}
}

struct CustomDisclosureGroupStyle: DisclosureGroupStyle {
	var arrowImage: Image

	func makeBody(configuration: Configuration) -> some View {
		HStack {
			configuration.label
				.font(.headline)
				.foregroundColor(.primary)
			Spacer()
			arrowImage
				.resizable()
				.frame(width: 16, height: 16)
				.rotationEffect(configuration.isExpanded ? .degrees(90) : .degrees(0))
		}
		.onTapGesture {
			withAnimation {
				configuration.isExpanded.toggle()
			}
		}
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

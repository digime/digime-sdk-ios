//
//  CustomDisclosureView.swift
//  DigiMeSDKExample
//
//  Created on 25/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct CustomDisclosureView: View {
    @State var data: [CustomDisclosureItem]
    @State private var flags: [Bool] = []

    init(data: [CustomDisclosureItem]) {
        self.data = data
        _flags = State(initialValue: [Bool](repeating: false, count: data.count))
    }
    
    var body: some View {
        ScrollView {
            ForEach(Array(data.enumerated()), id: \.element.id) { index, item in
                CustomDisclosureGroup(animation: .easeInOut(duration: 0.2), isExpanded: $flags[index]) {
                    flags[index].toggle()
                } prompt: {
                    HStack(spacing: 0) {
                        Text(item.title)
                            .font(.headline)
                        Spacer()
                        Text("?")
                            .fontWeight(.bold)
                            .rotationEffect(flags[index] ? Angle(degrees: 180) : .zero)
                    }
                } expandedView: {
                    Text(item.subtitle)
                        .font(.body)
                        .padding()
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct CustomDisclosureItem: Codable, Identifiable {
    var id = UUID()
    var title: String
    var subtitle: String
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let data: [CustomDisclosureItem] = [
            CustomDisclosureItem(title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.", subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras sit amet lectus felis. Proin rutrum interdum fringilla. Proin arcu nulla, consectetur sed purus non, egestas semper dui. Proin ut nulla a enim lacinia accumsan. Nam in ex interdum, efficitur leo non, convallis lorem. Proin imperdiet venenatis dolor, sed tincidunt arcu. Cras vestibulum lacus nec gravida congue."),
            CustomDisclosureItem(title: "Cras sit amet lectus felis. Proin rutrum interdum fringilla.", subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras sit amet lectus felis. Proin rutrum interdum fringilla. Proin arcu nulla, consectetur sed purus non, egestas semper dui. Proin ut nulla a enim lacinia accumsan. Nam in ex interdum, efficitur leo non, convallis lorem. Proin imperdiet venenatis dolor, sed tincidunt arcu. Cras vestibulum lacus nec gravida congue.")
        ]
        CustomDisclosureView(data: data)
    }
}

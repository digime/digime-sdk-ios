//
//  ServicePickerView.swift
//  DigiMeSDKExample
//
//  Created on 23/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import Foundation
import SwiftUI

struct ServicePickerView: View {
	@Binding var sections: [ServiceSection]
	@Binding var showView: Bool
	@Binding var selectServiceCompletion: ((Service) -> Void)?
	
	@State private var selectedService: Service?
	@State private var flags: [Bool] = []
    @State private var searchText: String = ""

    var body: some View {
		ZStack {
			NavigationView {
				List {
                    
                    searchBar
                    
					ForEach(Array(sections.enumerated()), id: \.1.id) { i, section in
						Section {
							DisclosureGroup(isExpanded: $flags[i]) {
                                ForEach(searchText.isEmpty ? section.items : section.items.filter { $0.name.lowercased().contains(searchText.lowercased()) }) { service in
                                    Button {
                                        self.selectedService = service
                                    } label: {
                                        makeServiceRow(service: service)
                                    }
                                }
							} label: {
								HStack {
									Image(section.iconName)
										.resizable()
										.aspectRatio(contentMode: .fit)
										.frame(width: 20, height: 20, alignment: .center)
										
									Text(section.title)
								}
							}
						}
					}
				}
				.listStyle(InsetGroupedListStyle())
				.navigationBarTitle("Add a Source", displayMode: .inline)
				.navigationBarItems(leading: cancelButton, trailing: addServiceButton)
                .onChange(of: searchText) { newValue in
                    flags = Array(repeating: !newValue.isEmpty, count: sections.count)
                }
			}
			.navigationViewStyle(StackNavigationViewStyle())
			.onAppear {
				flags = sections.map { _ in false }
			}
		}
    }
	
	func makeServiceRow(service: Service) -> some View {
		HStack {
			if let resource = service.resources.optimalResource(for: CGSize(width: 20, height: 20)) {
				SourceImage(url: resource.url)
			}
			else {
				Image(systemName: "photo.circle.fill")
					.foregroundColor(.gray)
					.frame(width: 20, height: 20)
			}
			
			Text(service.name)
				.foregroundColor(.primary)
			Spacer()
			if
				let selected = self.selectedService,
				selected.identifier == service.identifier {
				
				Image(systemName: "checkmark")
			}
		}
	}
	
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search ...", text: $searchText)
                .padding(3)
            
            if !searchText.isEmpty {
                Image(systemName: "xmark.circle.fill")
                    .imageScale(.medium)
                    .foregroundColor(Color(.systemGray3))
                    .onTapGesture {
                        self.searchText = ""
                    }
            }
        }
    }
    
	private var cancelButton: some View {
		Button {
			showView = false
		} label: {
			Text("Cancel")
		}
	}
	
	private var addServiceButton: some View {
		Button {
			guard let service = selectedService else {
				return
			}
			selectServiceCompletion?(service)
			showView = false
		} label: {
			Text("Add Service")
				.font(.headline)
				.foregroundColor(selectedService == nil ? .gray : .accentColor)
		}
	}
}

struct ServicePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ServicePickerView(sections: .constant([]), showView: .constant(true), selectServiceCompletion: .constant(nil))
    }
}

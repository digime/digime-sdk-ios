//
//  ServicesView.swift
//  DigiMeSDKExample
//
//  Created on 21/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct ServicesView: View {
	@ObservedObject private var viewModel = ServicesViewModel()
	
    var body: some View {
		ZStack {
			SplitView(top: {
				VStack {
					List {
						Section("Contract") {
							if viewModel.isLoading {
								HStack {
									Image(systemName: "gear")
										.listRowIcon(color: .gray)
									Text(viewModel.currentContract.name)
										.foregroundColor(.gray)
								}
							}
							else {
								NavigationLink {
									ContractDetailsView(contract: $viewModel.currentContract)
								} label: {
									HStack {
										Image(systemName: "gear")
											.listRowIcon(color: .indigo)
										Text(viewModel.currentContract.name)
									}
								}
							}
						}
						
						if !viewModel.services.isEmpty {
							Section("Connected Accounts") {
								ForEach(viewModel.services) { service in
									HStack {
										if let resource = service.resources.optimalResource(for: CGSize(width: 20, height: 20)) {
											SourceImage(url: resource.url)
										}
										else {
											Image(systemName: "photo.circle.fill")
												.frame(width: 20, height: 20)
												.foregroundColor(.gray)
										}
										Text(service.name)
									}
								}
							}
						}
						
						Section("Read data") {
							if !viewModel.isAuthorised {
								Button {
									viewModel.authorizeWithService()
								} label: {
									HStack {
										Image("passIcon")
											.listRowIcon(color: viewModel.isLoading ? .gray : .green)
										Text("Authorise With Service")
											.foregroundColor(viewModel.isLoading ? .gray : .accentColor)
									}
								}
							}
							
							if viewModel.isAuthorised {
								Button {
									viewModel.addService()
								} label: {
									HStack {
										Image(systemName: "plus.circle")
											.listRowIcon(color: viewModel.isLoading ? .gray : .green)
										Text("Add Service")
											.foregroundColor(viewModel.isLoading ? .gray : .accentColor)
									}
								}
								
								Button {
									viewModel.refreshData()
								} label: {
									HStack {
										Image(systemName: "arrow.clockwise.circle")
											.listRowIcon(color: viewModel.isLoading ? .gray : .purple)
										Text("Refresh Data")
											.foregroundColor(viewModel.isLoading ? .gray : .accentColor)
									}
								}
							}
							
							Button {
								viewModel.showContractDetails()
							} label: {
								HStack {
									Image("certIcon")
										.listRowIcon(color: viewModel.isLoading ? .gray : .orange)
									Text("Request Contract Details")
										.foregroundColor(viewModel.isLoading ? .gray : .accentColor)
								}
							}
						}
						
						if viewModel.isAuthorised {
							Section("Reset") {
								Button {
									viewModel.deleteUser()
								} label: {
									HStack {
										Image("deleteIcon")
											.listRowIcon(color: .red)
										Text("Start Over")
											.foregroundColor(.red)
									}
								}
							}
						}
					}
					.navigationBarTitle("Service Data Example", displayMode: .inline)
					.toolbar {
						if viewModel.isLoading {
							ActivityIndicator()
								.frame(width: 20, height: 20)
								.foregroundColor(.gray)
								.padding(.trailing, 10)
						}
					}
				}
			}, bottom: {
				LogOutputView(logs: $viewModel.logs)
			})
		}
		.sheet(isPresented: $viewModel.presentSourceSelector) {
			withAnimation(.easeOut) {
				ServicePickerView(sections: $viewModel.sections, showView: $viewModel.presentSourceSelector, selectServiceCompletion: $viewModel.selectServiceCompletion)
					.transition(.slide)
			}
		}
    }
}

struct ServicesView_Previews: PreviewProvider {
    static var previews: some View {
		NavigationView {
			ServicesView()
		}
    }
}

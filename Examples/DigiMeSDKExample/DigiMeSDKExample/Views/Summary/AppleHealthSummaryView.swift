//
//  AppleHealthSummaryView.swift
//  DigiMeSDKExample
//
//  Created on 25/01/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import SwiftUI

struct AppleHealthSummaryView: View {
	@ObservedObject var viewModel: AppleHealthSummaryViewModel
    @ObservedObject var scopeViewModel = ScopeViewModel()
    
	@State private var dialogDetent = PresentationDetent.height(200)

	private let contract = Contracts.prodAppleHealth
	private var fromDate: Date {
		return Calendar.current.date(byAdding: .month, value: -1, to: Date())!
	}

	init?() {
		guard let config = try? Configuration(appId: contract.appId, contractId: contract.identifier, privateKey: contract.privateKey, authUsingExternalBrowser: true) else {
			return nil
		}
		
		viewModel = AppleHealthSummaryViewModel(config: config)
        scopeViewModel.objectTypes = [ServiceObjectType(identifier: 301, name: "Fitness Activity Summary")]
        scopeViewModel.selectedObjectTypes = [301]
        scopeViewModel.isObjectTypeEditingAllowed = false
	}
	
	var body: some View {
        let scopeFooterText = !scopeViewModel.isScopeModificationAllowed ? Text("Turn on the toggle to set the scope of mapped data using time ranges and narrow down the results.") : Text("To revert to the default contract's time range, turn off the scoping option and execute the query again.")
        let footerText = !scopeViewModel.isScopeModificationAllowed ? Text("You can try turning the Scoping option On to narrow down your next request.") : Text("")
		ZStack {
			List {
				Section(header: Text("Scope"), footer: scopeFooterText) {
					HStack {
						Image(systemName: "scope")
							.frame(width: 30, height: 30, alignment: .center)
						Text("Limit your query")
						Spacer()
                        Toggle("", isOn: $scopeViewModel.isScopeModificationAllowed)
                            .onChange(of: scopeViewModel.isScopeModificationAllowed) { value in
                                if !value {
                                    self.reset()
                                }
                            }
					}
					
                    if scopeViewModel.isScopeModificationAllowed {
						Button {
                            self.scopeViewModel.shouldDisplayModal = true
						} label: {
							HStack(spacing: 40) {
								VStack(alignment: .leading, spacing: 10) {
									Text("Your Scope time range. ")
										.foregroundColor(.primary)
										.font(.footnote) +
									Text("Tap to change:")
										.foregroundColor(.blue)
										.font(.footnote)
									
                                    Text("\(scopeViewModel.startDateFormatString) - \(scopeViewModel.endDateFormatString)")
                                        .foregroundColor(.gray)
                                        .font(.footnote)
                                        .onChange(of: scopeViewModel.startDate) { newValue in
                                            scopeViewModel.startDateFormatString = newValue == nil ? ScopeAddView.datePlaceholder : scopeViewModel.dateFormatter.string(from: newValue!)
                                        }
                                        .onChange(of: scopeViewModel.endDate) { newValue in
                                            scopeViewModel.endDateFormatString = newValue == nil ? ScopeAddView.datePlaceholder : scopeViewModel.dateFormatter.string(from: newValue!)
                                        }
                                    
                                    ScopeObjectTypeIconView(name: "Fitness Activity Summary", size: 30)
								}
								.padding(.vertical, 10)
							}
						}
					}
				}
				
				Section(header: Text("Access Your Records"), footer: Text("When you query for the first time, you will be prompted for Apple Health permissions.\n\nIf you blocked or ignored the permission request, you may need to open the iOS Settings and manually allow access to approve sharing data with the SDK Example App.")) {
					Button {
						queryData()
					} label: {
						HStack {
							Text("Read Apple Health Data")
							Spacer()
							if viewModel.isDataLoading {
								ActivityIndicator()
									.frame(width: 20, height: 20)
									.foregroundColor(.gray)
							}
						}
					}
				}
				
				if viewModel.isDataFetched && viewModel.errorMessage == nil {
					Section(header: Text("Result"), footer: footerText) {
						HStack {
							Image(systemName: "calendar.badge.clock")
								.rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
								.frame(width: 30, height: 30, alignment: .center)
							Text("Start:")
							Spacer()
							Text(viewModel.startDateFormattedString)
								.foregroundColor(.gray)
						}
						HStack {
							Image(systemName: "calendar.badge.clock")
								.frame(width: 30, height: 30, alignment: .center)
							Text("End:")
							Spacer()
							Text(viewModel.endDateFormattedString)
								.foregroundColor(.gray)
						}
						HStack {
							Image(systemName: "figure.walk")
								.frame(width: 30, height: 30, alignment: .center)
							Text("Steps:")
							Spacer()
							Text(viewModel.steps)
								.foregroundColor(.gray)
						}
						HStack {
							Image(systemName: "figure.walk.motion")
								.frame(width: 30, height: 30, alignment: .center)
							Text("Distance:")
							Spacer()
							Text(viewModel.distance)
								.foregroundColor(.gray)
						}
						HStack {
							Image(systemName: "bolt.ring.closed")
								.frame(width: 30, height: 30, alignment: .center)
							Text("Energy:")
							Spacer()
							Text(viewModel.calories)
								.foregroundColor(.gray)
						}
					}
				}
				else if viewModel.errorMessage != nil {
					errorBanner
				}
				else if viewModel.infoMessage != nil {
					infoBanner
				}
			}
			.navigationBarTitle("Apple Health", displayMode: .inline)
			.listStyle(InsetGroupedListStyle())
			.toolbar {
#if targetEnvironment(simulator)
				Button {
					viewModel.addTestData()
				} label: {
					Image(systemName: "plus.square.on.square")
				}
#endif
			}
            .sheet(isPresented: $scopeViewModel.shouldDisplayModal) {
                ScopeAddView(viewModel: scopeViewModel)
            }
		}
		.sheet(isPresented: $viewModel.showCancelOption) {
			withAnimation {
				ActionView(title: "Waiting callback from your browser...", actionTitle: "Cancel Request", dialogDetent: dialogDetent) {
					self.viewModel.cancel()
				}
			}
		}
	}
	
	private var errorBanner: some View {
		VStack(alignment: .leading, spacing: 2) {
			Text("Error")
				.font(.headline)
			Text(viewModel.errorMessage ?? "Error...")
				.font(.callout)
		}
		.foregroundColor(Color.red)
	}
	
	private var infoBanner: some View {
		VStack(alignment: .leading, spacing: 2) {
			Text("Info")
				.font(.headline)
			Text(viewModel.infoMessage ?? "Info...")
				.font(.callout)
		}
	}
	
	private func queryData() {
		viewModel.errorMessage = nil
		viewModel.infoMessage = nil
		viewModel.isDataLoading = true
        viewModel.authorize(readOptions: scopeViewModel.readOptions)
	}
	
	private func reset() {
        scopeViewModel.resetSettings()
	}
}

struct AppleHealthSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        AppleHealthSummaryView()
    }
}

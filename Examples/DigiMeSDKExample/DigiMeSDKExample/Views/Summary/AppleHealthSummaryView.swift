//
//  AppleHealthSummaryView.swift
//  DigiMeSDKExample
//
//  Created on 25/01/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeCore
import DigiMeSDK
import SwiftUI

struct AppleHealthSummaryView: View {
	@ObservedObject var viewModel: AppleHealthSummaryViewModel
    @ObservedObject var scopeViewModel = ScopeViewModel()
    
	@State private var dialogDetent = PresentationDetent.height(200)
    @State private var isPressedScope = false
    
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
        let scopeFooterText = !scopeViewModel.isScopeModificationAllowed ? "Turn on the toggle to set the scope of mapped data using time ranges and narrow down the results." : "To revert to the default contract's time range, turn off the scoping option and execute the query again."
        let footerText = !scopeViewModel.isScopeModificationAllowed ? "You can try turning the Scoping option On to narrow down your next request." : nil
		ZStack {
			ScrollView {
				SectionView(header: "Scope", footer: scopeFooterText) {
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
                            .disabled(viewModel.isLoadingData)
					}
					
                    if scopeViewModel.isScopeModificationAllowed {
                        GenericPressableButtonView(isPressed: $isPressedScope, action: {
                            if !viewModel.isLoadingData {
                                self.scopeViewModel.shouldDisplayModal = true
                            }
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Your Scope time range. ")
                                        .foregroundColor(isPressedScope ? .white : .primary)
                                        .font(.footnote) +
                                    Text("Tap to change:")
                                        .foregroundColor(isPressedScope ? .white : .accentColor)
                                        .font(.footnote)
                                    
                                    Text("\(scopeViewModel.startDateFormatString) - \(scopeViewModel.endDateFormatString)")
                                        .foregroundColor(isPressedScope ? .white : .gray)
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
                                
                                Spacer()
                            }
                            .padding(8)
                            .padding(.horizontal, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(isPressedScope ? .accentColor : Color(.secondarySystemGroupedBackground))
                            )
                            .disabled(viewModel.isLoadingData)
                        }
					}
				}
                
				SectionView(header: "Access Your Records", footer: "When you query for the first time, you will be prompted for Apple Health permissions.\n\nIf you blocked or ignored the permission request, you may need to open the iOS Settings and manually allow access to approve sharing data with the SDK Example App.") {
                    StyledPressableButtonView(text: "Read Apple Health Data",
                                       iconSystemName: "heart.circle",
                                       iconForegroundColor: viewModel.isLoadingData ? .gray : .red,
                                       textForegroundColor: viewModel.isLoadingData ? .gray : .accentColor,
                                       backgroundColor: Color(.secondarySystemGroupedBackground),
                                       action: {
                        queryData()
                    })
                    .disabled(viewModel.isLoadingData)
				}
				
				if viewModel.isDataFetched && viewModel.errorMessage == nil {
					SectionView(header: "Result", footer: footerText) {
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
				else if let error = viewModel.errorMessage {
                    SectionView(header: "Error") {
                        InfoMessageView(message: error, foregroundColor: .red)
                    }
				}
				else if let message = viewModel.infoMessage {
                    SectionView {
                        InfoMessageView(message: message, foregroundColor: .primary)
                    }
				}
			}
			
		}
        .navigationBarTitle("Apple Health", displayMode: .inline)
        .background(Color(.systemGroupedBackground))
        .toolbar {
            if viewModel.isLoadingData {
                ActivityIndicator()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.gray)
            }
#if targetEnvironment(simulator)
            Button {
                viewModel.addTestData()
            } label: {
                Image(systemName: "plus.square.on.square")
            }
            .disabled(viewModel.isLoadingData)
#endif
        }
        .sheet(isPresented: $scopeViewModel.shouldDisplayModal) {
            ScopeAddView(viewModel: scopeViewModel)
        }
		.sheet(isPresented: $viewModel.showCancelOption) {
            ActionView(title: "Waiting callback from your browser...", actionTitle: "Cancel Request", dialogDetent: dialogDetent) {
                self.viewModel.cancel()
            }
		}
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
        viewModel.authorize(readOptions: scopeViewModel.readOptions)
	}
	
	private func reset() {
        scopeViewModel.resetSettings()
	}
}

struct AppleHealthSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        AppleHealthSummaryView()
            .environment(\.colorScheme, .dark)
    }
}

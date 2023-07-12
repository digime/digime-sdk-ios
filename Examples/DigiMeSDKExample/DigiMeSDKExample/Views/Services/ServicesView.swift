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
    @ObservedObject private var scopeViewModel = ScopeViewModel()
    
	@State private var dialogDetent = PresentationDetent.height(200)
	@State private var showAccountOptions = false
    @State private var activeAccountName: String?
    @State private var presentPortabilityDateManager = false
    @State private var reportStartDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    @State private var reportEndDate = Date()
        
    var body: some View {
		ZStack {
			SplitView(top: {
				VStack {
					List {
						Section("Contract") {
							if viewModel.isLoadingData {
								HStack {
									Image(systemName: "gear")
										.listRowIcon(color: .gray)
									Text(viewModel.activeContract.name)
										.foregroundColor(.gray)
								}
							}
							else {
								NavigationLink {
                                    ContractDetailsView(selectedContract: $viewModel.activeContract, contracts: viewModel.contracts)
								} label: {
									HStack {
										Image(systemName: "gear")
											.listRowIcon(color: .indigo)
										Text(viewModel.activeContract.name)
									}
								}
							}
						}
						
						if !viewModel.linkedAccounts.isEmpty {
							Section("Connected Accounts") {
								ForEach(viewModel.linkedAccounts) { account in
									Button {
                                        if account.requiredReauth {
                                            viewModel.reauthorizeAccount(connectedAccount: account)
                                        }
                                        else {
                                            activeAccountName = account.service.name.lowercased()
                                            showAccountOptions = true
                                        }
									} label: {
										HStack {
											if let resource = account.service.resources.optimalResource(for: CGSize(width: 20, height: 20)) {
												SourceImage(url: resource.url)
											}
											else {
												Image(systemName: "photo.circle.fill")
													.frame(width: 20, height: 20)
													.foregroundColor(.gray)
											}
											
											Text(account.service.name)
											Spacer()
											if account.requiredReauth {
												Text("Reauthorize")
													.foregroundColor(.red)
											}
										}
									}
								}
							}
						}
						
						Section("Manage") {
							if !viewModel.isAuthorized {
								Button {
									viewModel.authorizeSelectedService()
								} label: {
									HStack {
										Image("passIcon")
											.listRowIcon(color: viewModel.isLoadingData ? .gray : .green)
										Text("Authorise With Service")
											.foregroundColor(viewModel.isLoadingData ? .gray : .accentColor)
									}
								}
							}

							if viewModel.isAuthorized {
								Button {
                                    viewModel.addNewService()
								} label: {
									HStack {
										Image(systemName: "plus.circle")
											.listRowIcon(color: viewModel.isLoadingData ? .gray : .green)
										Text("Add Service")
											.foregroundColor(viewModel.isLoadingData ? .gray : .accentColor)
									}
								}

								Button {
                                    viewModel.reloadServiceData(readOptions: scopeViewModel.readOptions)
								} label: {
									HStack {
										Image(systemName: "arrow.clockwise.circle")
											.listRowIcon(color: viewModel.isLoadingData ? .gray : .purple)
										Text("Refresh Data")
											.foregroundColor(viewModel.isLoadingData ? .gray : .accentColor)
									}
								}
							}

							Button {
								viewModel.displayContractDetails()
							} label: {
								HStack {
									Image("certIcon")
										.listRowIcon(color: viewModel.isLoadingData ? .gray : .orange)
									Text("Request Contract Details")
										.foregroundColor(viewModel.isLoadingData ? .gray : .accentColor)
								}
							}
						}
						
						if viewModel.isAuthorized {
							Section("Reset") {
								Button {
									viewModel.removeUser()
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
						if viewModel.isLoadingData {
							ActivityIndicator()
								.frame(width: 20, height: 20)
								.foregroundColor(.gray)
								.padding(.trailing, 10)
						}
					}
				}
			}, bottom: {
				LogOutputView(logs: $viewModel.logEntries)
			})
		}
		.sheet(isPresented: $viewModel.shouldDisplaySourceSelector) {
			withAnimation(.easeOut) {
                ServicePickerView(sections: $viewModel.serviceSections, showView: $viewModel.shouldDisplaySourceSelector, selectServiceCompletion: $viewModel.serviceSelectionCompletionHandler, scopeViewModel: scopeViewModel, allowScoping: viewModel.linkedAccounts.isEmpty)
					.transition(.slide)
			}
		}
		.sheet(isPresented: $viewModel.shouldDisplayCancelButton) {
			withAnimation {
				ActionView(title: "Waiting callback from your browser...", actionTitle: "Cancel Request", dialogDetent: dialogDetent) {
                    self.viewModel.stopFetchingData()
				}
			}
		}
        .actionSheet(isPresented: $showAccountOptions) {
            ActionSheet(title: Text(activeAccountName?.uppercased() ?? "EXPORT"),
                        message: Text("Choose an option"),
                        buttons: [
                            .cancel(),
                            .destructive(Text("Export Portability Report")) {
                                presentPortabilityDateManager = true
                            },
                        ])
        }
        .sheet(isPresented: $viewModel.shouldDisplayShareSheet) {
            ShareSheetView(shareItems: [viewModel.xmlReportURL as Any])
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $presentPortabilityDateManager) {
            ReportDateManagerView(presentViewModally: $presentPortabilityDateManager, startDate: $reportStartDate, endDate: $reportEndDate) {
                self.loadReport()
            }
        }
        .toolbar {
            if !viewModel.linkedAccounts.isEmpty {
                Button {
                    scopeViewModel.displayScopeEditor()
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
            }
        }
        .sheet(isPresented: $scopeViewModel.shouldDisplayModal) {
            ScopeEditView(viewModel: scopeViewModel)
        }
    }
    
    private func loadReport() {
        viewModel.fetchReport(for: "medmij", format: "xml", from: reportStartDate.timeIntervalSince1970, to: reportEndDate.timeIntervalSince1970)
    }
}

struct ServicesView_Previews: PreviewProvider {
    static var previews: some View {
		NavigationView {
			ServicesView()
		}
    }
}

//
//  ServicesView.swift
//  DigiMeSDKExample
//
//  Created on 21/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

enum ServicesNavigationDestination: Hashable {
    case contracts
}

struct ServicesView: View {
    @Binding var navigationPath: NavigationPath
    
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
                    ScrollView {
                        SectionView(header: "Contract") {
                            StyledPressableButtonView(text: viewModel.activeContract.name,
                                               iconSystemName: "gear",
                                               iconForegroundColor: viewModel.isLoadingData ? .gray : .indigo,
                                               textForegroundColor: viewModel.isLoadingData ? .gray : .accentColor,
                                               backgroundColor: Color(.secondarySystemGroupedBackground),
                                               disclosureIndicator: true,
                                               action: {
                                navigationPath.append(ServicesNavigationDestination.contracts)
                            })
                            .disabled(viewModel.isLoadingData)
                        }
                        
                        if !viewModel.linkedAccounts.isEmpty {
                            SectionView(header: "Connected Accounts") {
                                ForEach(viewModel.linkedAccounts) { account in
                                    StyledPressableButtonView(text: account.service.name,
                                                       iconName: "passIcon",
                                                       iconUrl: optimalResource(for: CGSize(width: 20, height: 20), from: account.service.resources)?.url,
                                                       iconForegroundColor: viewModel.isLoadingData ? .gray : .green,
                                                       textForegroundColor: viewModel.isLoadingData ? .gray : .accentColor,
                                                       backgroundColor: Color(.secondarySystemGroupedBackground),
                                                       requiredReauth: account.requiredReauth,
                                                       action: {
                                        if account.requiredReauth {
                                            viewModel.reauthorizeAccount(connectedAccount: account)
                                        }
                                        else {
                                            activeAccountName = account.service.name.lowercased()
                                            showAccountOptions = true
                                        }
                                    })
                                    .disabled(viewModel.isLoadingData)
                                }
                            }
                        }
                        
                        SectionView(header: "Manage") {
                            if !viewModel.isAuthorized {
                                StyledPressableButtonView(text: "Authorise With Service",
                                                   iconName: "passIcon",
                                                   iconForegroundColor: viewModel.isLoadingData ? .gray : .green,
                                                   textForegroundColor: viewModel.isLoadingData ? .gray : .accentColor,
                                                   backgroundColor: Color(.secondarySystemGroupedBackground),
                                                   action: {
                                    viewModel.authorizeSelectedService()
                                })
                                .disabled(viewModel.isLoadingData)
                            }
                            
                            if viewModel.isAuthorized {
                                StyledPressableButtonView(text: "Add Service",
                                                   iconSystemName: "plus.circle",
                                                   iconForegroundColor: viewModel.isLoadingData ? .gray : .green,
                                                   textForegroundColor: viewModel.isLoadingData ? .gray : .accentColor,
                                                   backgroundColor: Color(.secondarySystemGroupedBackground),
                                                   action: {
                                    viewModel.addNewService()
                                })
                                .disabled(viewModel.isLoadingData)
                                
                                StyledPressableButtonView(text: "Refresh Data",
                                                   iconSystemName: "arrow.clockwise.circle",
                                                   iconForegroundColor: viewModel.isLoadingData ? .gray : .purple,
                                                   textForegroundColor: viewModel.isLoadingData ? .gray : .accentColor,
                                                   backgroundColor: Color(.secondarySystemGroupedBackground),
                                                   action: {
                                    viewModel.reloadServiceData(readOptions: scopeViewModel.readOptions)
                                })
                                .disabled(viewModel.isLoadingData)
                            }
                            
                            StyledPressableButtonView(text: "Request Contract Details",
                                               iconName: "certIcon",
                                               iconForegroundColor: viewModel.isLoadingData ? .gray : .orange,
                                               textForegroundColor: viewModel.isLoadingData ? .gray : .accentColor,
                                               backgroundColor: Color(.secondarySystemGroupedBackground),
                                               action: {
                                viewModel.displayContractDetails()
                            })
                            .disabled(viewModel.isLoadingData)
                        }
                        
                        if viewModel.isAuthorized {
                            SectionView(header: "Reset") {
                                StyledPressableButtonView(text: "Delete Data and Clear Logs",
                                                   iconName: "deleteIcon",
                                                   iconForegroundColor: viewModel.isLoadingData ? .gray : .red,
                                                   textForegroundColor: viewModel.isLoadingData ? .gray : .red,
                                                   backgroundColor: Color(.secondarySystemGroupedBackground),
                                                   action: {
                                    viewModel.removeUser()
                                })
                                .disabled(viewModel.isLoadingData)
                            }
                        }
                    }
                }
            }, bottom: {
                LogOutputView(logs: $viewModel.logEntries)
            })
        }
        .navigationBarTitle("Service Data Example", displayMode: .inline)
        .background(Color(.systemGroupedBackground))
        .toolbar {
            if viewModel.isLoadingData {
                ActivityIndicator()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.gray)
                    .padding(.trailing, 10)
            }
        }
		.sheet(isPresented: $viewModel.shouldDisplaySourceSelector) {
            ServicePickerView(showView: $viewModel.shouldDisplaySourceSelector, selectServiceCompletion: $viewModel.serviceSelectionCompletionHandler, viewModel: viewModel, scopeViewModel: scopeViewModel, viewState: .sources, allowScoping: !viewModel.linkedAccounts.isEmpty)
		}
		.sheet(isPresented: $viewModel.shouldDisplayCancelButton) {
            ActionView(title: "Waiting callback from your browser...", actionTitle: "Cancel Request", dialogDetent: dialogDetent) {
                self.viewModel.stopFetchingData()
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
        .navigationDestination(for: ServicesNavigationDestination.self) { destination in
            switch destination {
            case .contracts:
                ContractDetailsView(selectedContract: $viewModel.activeContract, contracts: viewModel.contracts)
            }
        }
    }
    
    private func loadReport() {
        viewModel.fetchReport(for: "medmij", format: "xml", from: reportStartDate.timeIntervalSince1970, to: reportEndDate.timeIntervalSince1970)
    }
}

struct ServicesView_Previews: PreviewProvider {
    static var previews: some View {
        let mockNavigationPath = NavigationPath()
		NavigationView {
            ServicesView(navigationPath: .constant(mockNavigationPath))
                .environment(\.colorScheme, .dark)
		}
    }
}

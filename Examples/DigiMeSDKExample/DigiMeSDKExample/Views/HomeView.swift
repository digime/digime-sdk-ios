//
//  HomeView.swift
//  DigiMeSDKExample
//
//  Created on 30/01/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct HomeView: View {
	@State var showAddServices = false
	@State var showWriteRead = false
	@State var showAppleHealthCharts = false
	@State var showAppleHealthSummary = false
	
    var body: some View {
		ZStack {
			NavigationView {
				List {
					Section(header: Text("Services"), footer: Text("User can add services to digi.me and read data.")) {
						Button {
							self.showAddServices = true
						} label: {
							HStack {
								Text("Service Data Example")
									.foregroundColor(.blue)
								Spacer()
							}
						}
						.sheet(isPresented: $showAddServices) {
							self.showAddServices = false
						} content: {
							ServiceDataViewControllerWrapper()
						}
					}
					
					Section(header: Text("Push data"), footer: Text("Users can upload data to digi.me and then read that data back.")) {
						Button {
							self.showWriteRead = true
						} label: {
							HStack {
								Text("Write & Read Written Data Example")
									.foregroundColor(.blue)
								Spacer()
							}
						}
						.sheet(isPresented: $showWriteRead) {
							self.showWriteRead = false
						} content: {
							WriteDataViewControllerWrapper()
						}
					}

					Section(header: Text("Apple Health"), footer: Text("Presenting Apple Health statistics collection query in a daily interval for the entire period of the digi.me contract time range. Check the details view for the exact daily numbers.")) {
						Button {
							self.showAppleHealthCharts = true
						} label: {
							HStack {
								Text("Daily Data in a Weekly Chart Example")
									.foregroundColor(.blue)
								Spacer()
							}
						}
						.sheet(isPresented: $showAppleHealthCharts) {
							self.showAppleHealthCharts = false
						} content: {
							AppleHealthChartViewControllerWrapper()
						}
					}
					
					Section(footer: Text("Presenting Apple Health statistics collection query result as totals within the digi.me contract time range. You can limit your query by turning on Scoping.")) {
						
						NavigationLink {
							AppleHealthSummaryView()
						} label: {
							HStack {
								Text("Activity Summary Example")
									.foregroundColor(.blue)
								Spacer()
							}
						}
					}
				}
				.navigationBarTitle("digi.me SDK", displayMode: .large)
				.listStyle(InsetGroupedListStyle())
			}
			.navigationViewStyle(StackNavigationViewStyle())
		}
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

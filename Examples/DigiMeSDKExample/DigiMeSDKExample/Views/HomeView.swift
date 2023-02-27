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
						NavigationLink {
							ServicesView()
						} label: {
							HStack {
								Image(systemName: "arrow.down.circle")
									.foregroundColor(.purple)
									.frame(width: 30, height: 30, alignment: .center)
								Text("Service Data Example")
									.foregroundColor(.blue)
								Spacer()
							}
						}
					}
					
					Section(header: Text("Push data"), footer: Text("Users can upload data to digi.me and then read that data back.")) {
						NavigationLink {
							WriteDataView()
						} label: {
							HStack {
								Image(systemName: "arrow.up.arrow.down.circle")
									.foregroundColor(.green)
									.frame(width: 30, height: 30, alignment: .center)
								Text("Write & Read Written Data")
									.foregroundColor(.blue)
								Spacer()
							}
						}
					}

					Section(header: Text("Apple Health"), footer: Text("Presenting Apple Health statistics collection query in a daily interval for the entire period of the digi.me contract time range. Check the Statement view for the exact daily numbers.")) {
						NavigationLink {
							AppleHealthBarChartView()
						} label: {
							HStack {
								Image(systemName: "chart.bar")
									.foregroundColor(.orange)
									.frame(width: 30, height: 30, alignment: .center)
								Text("Activity Bar Chart")
									.foregroundColor(.blue)
								Spacer()
							}
						}
			
						NavigationLink {
							AppleHealthLineChartView()
						} label: {
							HStack {
								Image(systemName: "chart.xyaxis.line")
									.foregroundColor(.red)
									.frame(width: 30, height: 30, alignment: .center)
								Text("Activity Line Chart")
									.foregroundColor(.blue)
								Spacer()
							}
						}
					}
					
					Section(footer: Text("Presenting Apple Health statistics collection query result as totals within the digi.me contract time range. You can limit your query by turning on Scoping.")) {
						NavigationLink {
							AppleHealthSummaryView()
						} label: {
							HStack {
								Image(systemName: "sum")
									.foregroundColor(.brown)
									.frame(width: 30, height: 30, alignment: .center)
								Text("Activity Summary")
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

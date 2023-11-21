//
//  HomeView.swift
//  DigiMeSDKExample
//
//  Created on 30/01/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

enum HomeNavigationDestination: Hashable {
    case servicesView
    case writeReadView
    case barChartsView
    case lineChartsView
    case summaryView
}

struct HomeView: View {
    @State private var navigationPath = NavigationPath()
    
    @State private var isPressedAddServices = false
    @State private var isPressedWriteRead = false
    @State private var isPressedAppleHealthBarCharts = false
    @State private var isPressedAppleHealthLineCharts = false
    @State private var isPressedAppleHealthSummary = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                SectionView(header: "Services", footer: "User can add services to digi.me and read data.") {
                    makeCustomButton(imageName: "arrow.down.circle",
                                     buttonText: "Service Data Example",
                                     isPressed: $isPressedAddServices,
                                     destination: .servicesView,
                                     imageColor: .purple)
                }
                
                SectionView(header: "Push data", footer: "Users can upload data to digi.me and then read that data back.") {
                    makeCustomButton(imageName: "arrow.up.arrow.down.circle",
                                     buttonText: "Write & Read Written Data",
                                     isPressed: $isPressedWriteRead,
                                     destination: .writeReadView,
                                     imageColor: .green)
                }
                
                SectionView(header: "Apple Health", footer: "Presenting Apple Health statistics collection query in a daily interval for the entire period of the digi.me contract time range. Check the Statement view for the exact daily numbers.") {
                    makeCustomButton(imageName: "chart.bar",
                                     buttonText: "Activity Bar Chart",
                                     isPressed: $isPressedAppleHealthBarCharts,
                                     destination: .barChartsView,
                                     imageColor: .orange)
                    
                    makeCustomButton(imageName: "chart.xyaxis.line",
                                     buttonText: "Activity Line Chart",
                                     isPressed: $isPressedAppleHealthLineCharts,
                                     destination: .lineChartsView,
                                     imageColor: .red)
                }
                
                SectionView(header: nil, footer: "Presenting Apple Health statistics collection query result as totals within the digi.me contract time range. You can limit your query by turning on Scoping.") {
                    makeCustomButton(imageName: "sum",
                                     buttonText: "Activity Summary",
                                     isPressed: $isPressedAppleHealthSummary,
                                     destination: .summaryView,
                                     imageColor: .indigo)
                }
            }
            .navigationBarTitle("digi.me SDK", displayMode: .large)
            .background(Color(.systemGroupedBackground))
            .navigationDestination(for: HomeNavigationDestination.self) { destination in
                switch destination {
                case .servicesView:
                    ServicesView(navigationPath: $navigationPath)
                case .writeReadView:
                    WriteDataView()
                case .barChartsView:
                    AppleHealthBarChartView()
                case .lineChartsView:
                    AppleHealthLineChartView()
                case .summaryView:
                    AppleHealthSummaryView()
                }
            }
        }
    }
}

extension HomeView {
    @ViewBuilder
    func makeCustomButton(imageName: String, buttonText: String, isPressed: Binding<Bool>, destination: HomeNavigationDestination, imageColor: Color) -> some View {
        GenericPressableButtonView(isPressed: isPressed, action: {
            navigationPath.append(destination)
        }) {
            HStack {
                Image(systemName: imageName)
                    .foregroundColor(isPressed.wrappedValue ? .white : imageColor)
                    .frame(width: 30, height: 30, alignment: .center)
                Text(buttonText)
                    .foregroundColor(isPressed.wrappedValue ? .white : .accentColor)
                Spacer()
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .foregroundColor(isPressed.wrappedValue ? .white : .gray)
            }
            .padding(8)
            .padding(.horizontal, 10)
            .background(isPressed.wrappedValue ? .accentColor : Color(.secondarySystemGroupedBackground))
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environment(\.colorScheme, .dark)
    }
}

//
//  LogOutputView.swift
//  DigiMeSDKExample
//
//  Created on 17/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct LogOutputView: View {
	@Binding var logs: [LogEntry]
	
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			List {
				ForEach(logs.indices, id: \.self) { index in
					let entry = logs[index]
					NavigationLink {
						ScrollView {
							LogDetailsView(entry: entry)
						}
					} label: {
						getEntryRow(index: index, entry: entry)
					}
					.listRowBackground(index.isMultiple(of: 2) ? Color.secondary.opacity(0.2) : Color.clear)
				}
			}
			.listStyle(PlainListStyle())
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.font(.custom("Menlo", size: 14))
		.foregroundColor(.white)
		.background(Color.black)
	}
	
	private func getEntryRow(index: Int, entry: LogEntry) -> some View {
		Group {
			HStack(alignment: .top, spacing: 8) {
				Text(entry.date, style: .time)
				Image(systemName: entry.state.iconSystemName)
					.foregroundColor(entry.state.tintColor)
				Text(entry.message)
					.lineLimit(nil)
					.frame(maxWidth: .infinity, alignment: .topLeading)
					.foregroundColor(entry.state.tintColor)
			}
		}
	}
}

struct LogOutputView_Previews: PreviewProvider {
    static var previews: some View {
		LogOutputView(logs: .constant(TestLogs.dataset))
    }
}

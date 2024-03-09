//
//  LogOutputView.swift
//  DigiMeSDKExample
//
//  Created on 17/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftData
import SwiftUI

struct LogOutputView: View {
    @Query(sort: [
        SortDescriptor(\LogEntry.date, order: .reverse)
    ]) private var logs: [LogEntry]

	var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(logs.indices, id: \.self) { index in
                    let entry = logs[index]
                    NavigationLink {
                        LogDetailsView(entry: entry)
                    } label: {
                        getEntryRow(index: index, entry: entry)
                    }
                }
            }
            .padding(.vertical, 10)
        }
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.font(.custom("Menlo", size: 14))
		.foregroundColor(.white)
		.background(Color.black)
	}
	
    @ViewBuilder
    private func getEntryRow(index: Int, entry: LogEntry) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(entry.date, style: .time)
            Image(systemName: entry.iconSystemName)
                .foregroundColor(entry.tintColor)
            Text(entry.message)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .foregroundColor(entry.tintColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(index.isMultiple(of: 2) ? Color.gray.opacity(0.2) : Color.clear)
    }
}

#Preview {
    do {
        let previewer = try Previewer()

        return LogOutputView()
            .environmentObject(ServicesViewModel(modelContext: previewer.container.mainContext))
            .modelContainer(previewer.container)
    }
    catch {
        return Text("\(error.localizedDescription)")
    }
}
